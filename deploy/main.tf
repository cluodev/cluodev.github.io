# Main Terraform configuration for deploying the Astro blog

# Data source to read local built files
locals {
  dist_path = "${path.module}/../dist"
  nginx_config_path = "/etc/nginx/sites-available/${var.site_dir_name}.conf"
  site_path = "/var/www/${var.site_dir_name}"
  # If connecting as root, no sudo prefix is needed. Otherwise prefix commands with sudo.
  sudo_prefix = var.ssh_user == "root" ? "" : "sudo "
}

# Install Nginx and setup the server
resource "null_resource" "install_nginx" {
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "${local.sudo_prefix}apt-get update -qq",
      "${local.sudo_prefix}apt-get install -y -qq nginx",
      "${local.sudo_prefix}systemctl enable nginx",
      "${local.sudo_prefix}systemctl start nginx || true",
      "${local.sudo_prefix}mkdir -p '${local.site_path}'",
      "${local.sudo_prefix}chown -R ${var.ssh_user}:www-data '${local.site_path}'",
      "${local.sudo_prefix}chmod -R 775 '${local.site_path}'"
    ]
  }

  triggers = {
    server_ip = var.server_ip
  }
}

# Create Nginx configuration
resource "null_resource" "nginx_config" {
  depends_on = [null_resource.install_nginx]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/nginx.conf.tpl", {
      domain_name = var.domain_name
      site_path   = local.site_path
      nginx_port  = var.nginx_port
      ssl_enabled = var.ssl_enabled
    })
    destination = "/tmp/${var.site_dir_name}.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.sudo_prefix}mv '/tmp/${var.site_dir_name}.conf' '${local.nginx_config_path}'",
      "${local.sudo_prefix}chown root:root '${local.nginx_config_path}'",
      "${local.sudo_prefix}chmod 644 '${local.nginx_config_path}'",
      "${local.sudo_prefix}ln -sf '${local.nginx_config_path}' '/etc/nginx/sites-enabled/${var.site_dir_name}.conf'",
      "${local.sudo_prefix}rm -f /etc/nginx/sites-enabled/default",
      "${local.sudo_prefix}nginx -t",
      "${local.sudo_prefix}systemctl reload nginx"
    ]
  }

  triggers = {
    config_hash = filemd5("${path.module}/templates/nginx.conf.tpl")
  }
}

# Deploy the static site files
resource "null_resource" "deploy_site" {
  depends_on = [null_resource.nginx_config]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  # Upload the dist directory contents
  provisioner "local-exec" {
    command = "rsync -avz --delete -e 'ssh -i ${var.ssh_private_key_path} -o StrictHostKeyChecking=no' '${local.dist_path}/' ${var.ssh_user}@${var.server_ip}:'${local.site_path}/'"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.sudo_prefix}chown -R ${var.ssh_user}:www-data '${local.site_path}'",
      "${local.sudo_prefix}chmod -R 755 '${local.site_path}'",
      "${local.sudo_prefix}find '${local.site_path}' -type f -exec chmod 644 {} \\;",
      "${local.sudo_prefix}systemctl reload nginx"
    ]
  }

  triggers = {
    # Trigger deployment on manual apply or when any file timestamp changes
    always_run = "${timestamp()}"
  }
}

# Optional: Setup firewall rules
resource "null_resource" "firewall_setup" {
  depends_on = [null_resource.deploy_site]

  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "${local.sudo_prefix}ufw --force enable",
      "${local.sudo_prefix}ufw allow OpenSSH",
      "${local.sudo_prefix}ufw allow ${var.nginx_port}",
      var.ssl_enabled ? "${local.sudo_prefix}ufw allow 443" : "echo 'SSL not enabled, skipping HTTPS port'",
      "${local.sudo_prefix}ufw status verbose"
    ]
  }

  triggers = {
    firewall_config = "${var.nginx_port}-${var.ssl_enabled}"
  }
}


# Configure passwordless sudo for webadmin (run as root)
resource "null_resource" "enable_passwordless_sudo" {
  # This resource should be run with a connection as root. If you normally connect
  # to the server as a non-root SSH user, either set var.ssh_user to "root" or
  # run this resource separately with root credentials.
  connection {
    type        = "ssh"
    host        = var.server_ip
    user        = "root"
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      # Create sudoers drop-in for webadmin
      "echo 'webadmin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/webadmin-nopasswd",
      "chmod 0440 /etc/sudoers.d/webadmin-nopasswd",
      # Validate the sudoers file
      "visudo -cf /etc/sudoers.d/webadmin-nopasswd || (echo 'visudo check failed' && exit 1)",
      "echo 'Passwordless sudo configured for webadmin'"
    ]
  }

  # Only attempt to apply once per unique server
  triggers = {
    server = var.server_ip
  }
}