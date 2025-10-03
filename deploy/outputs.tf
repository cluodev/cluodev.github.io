# Outputs for the deployment

output "server_ip" {
  description = "IP address of the deployed server"
  value       = var.server_ip
}

output "site_url" {
  description = "URL of the deployed site"
  value       = var.ssl_enabled ? "https://${var.domain_name}" : "http://${var.domain_name}"
}

output "site_url_ip" {
  description = "Direct IP access URL"
  value       = var.ssl_enabled ? "https://${var.server_ip}" : "http://${var.server_ip}"
}

output "nginx_config_path" {
  description = "Path to Nginx configuration file on server"
  value       = "/etc/nginx/sites-available/${var.site_dir_name}.conf"
}

output "site_path" {
  description = "Path to site files on server"
  value       = "/var/www/${var.site_dir_name}"
}

output "deployment_commands" {
  description = "Useful commands for managing the deployment"
  value = {
    reload_nginx    = "sudo systemctl reload nginx"
    restart_nginx   = "sudo systemctl restart nginx"
    check_nginx     = "sudo nginx -t"
    view_logs       = "sudo tail -f /var/log/nginx/${var.domain_name}_access.log"
    view_error_logs = "sudo tail -f /var/log/nginx/${var.domain_name}_error.log"
    check_status    = "sudo systemctl status nginx"
  }
}