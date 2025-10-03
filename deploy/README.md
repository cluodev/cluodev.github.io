# Deployment Documentation

This directory contains Terraform configuration files to deploy Charles Luo's blog to a Linux server.

## Prerequisites

Before deploying, ensure you have:

1. **Terraform installed** (version >= 1.0)
   ```bash
   # On macOS with Homebrew
   brew install terraform
   ```

2. **SSH access** to your server
   - Configure server IP in `.env` file (see Configuration section)
   - User: `root` or `webadmin` with passwordless sudo
   - SSH key configured (update `ssh_private_key_path` variable if needed)

3. **Built site** in the `dist/` directory
   ```bash
   # From project root
   npm run build
   ```

4. **rsync installed** (usually pre-installed on macOS/Linux)

## Quick Start

1. **Navigate to the deploy directory:**
   ```bash
   cd deploy
   ```

2. **Run the deployment script:**
   ```bash
   ./deploy.sh
   ```

   This script will:
   - Build the site (if needed)
   - Initialize Terraform
   - Plan the deployment
   - Apply the changes (with confirmation)

## Manual Deployment

If you prefer to run Terraform commands manually:

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Plan the deployment:**
   ```bash
   terraform plan
   ```

3. **Apply the deployment:**
   ```bash
   terraform apply
   ```

4. **View outputs:**
   ```bash
   terraform output
   ```

## Configuration

### Environment Variables (.env file)

The deployment uses a `.env` file to store sensitive configuration. Create or edit `deploy/.env`:

```bash
# Server IP address for deployment
SERVER_IP=<server ip address>

# Admin password (optional, for scripts that need it)
ADMIN_PWD=your-admin-password
```

**Important**: The `.env` file is already in `.gitignore` and will NOT be committed to version control.

### Variables

You can customize the deployment by setting variables:

```bash
# Example: Deploy with SSL enabled
terraform apply -var="ssl_enabled=true"

# Example: Use different domain
terraform apply -var="domain_name=blog.example.com"

# Example: Use different SSH key
terraform apply -var="ssh_private_key_path=/path/to/your/key"
```

### Variable File (Optional)

You can also create a `terraform.tfvars` file for additional configuration:

```hcl
# Note: SERVER_IP is loaded from .env file automatically
# ssh_user is set to "webadmin" by deploy.sh
ssh_private_key_path = "~/.ssh/id_ed25519_cldsrv"
domain_name = "www.cluodev.com"
ssl_enabled = false
site_dir_name = "cluodev-blog"
```

## What This Deployment Does

1. **Server Setup:**
   - Installs and configures Nginx
   - Creates the site directory (`/var/www/cluodev-blog/`)
   - Sets proper permissions

2. **Nginx Configuration:**
   - Optimized for static sites
   - Gzip compression enabled
   - Security headers configured
   - Proper caching for static assets
   - Clean URLs for Astro routing

3. **Site Deployment:**
   - Syncs `dist/` directory to server
   - Sets proper file permissions
   - Reloads Nginx configuration

4. **Firewall Setup:**
   - Enables UFW firewall
   - Opens SSH, HTTP (and HTTPS if SSL enabled)

## File Structure

```
deploy/
├── main.tf              # Main Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf           # Output definitions
├── templates/
│   └── nginx.conf.tpl   # Nginx configuration template
├── deploy.sh            # Deployment script
└── README.md            # This file
```

## Troubleshooting

### Common Issues

1. **SSH Connection Failed:**
   - Verify server IP in `.env` file
   - Verify SSH key path in `variables.tf`
   - Test SSH connection manually: `ssh -i ~/.ssh/id_ed25519_cldsrv webadmin@<SERVER_IP>`

2. **Permission Denied:**
   - Ensure SSH key has correct permissions: `chmod 600 ~/.ssh/id_rsa`
   - Verify SSH user has sudo privileges

3. **Build Not Found:**
   - Run `npm run build` from project root first
   - Ensure `dist/` directory exists and contains files

4. **Nginx Configuration Error:**
   - Check Nginx syntax: `sudo nginx -t`
   - View error logs: `sudo tail -f /var/log/nginx/error.log`

### Useful Commands

After deployment, you can manage the server with these commands:

```bash
# Check Nginx status
sudo systemctl status nginx

# Reload Nginx configuration
sudo systemctl reload nginx

# View access logs
sudo tail -f /var/log/nginx/www.cluodev.com_access.log

# View error logs
sudo tail -f /var/log/nginx/www.cluodev.com_error.log

# Test Nginx configuration
sudo nginx -t
```

## SSL/HTTPS Setup

To enable SSL:

1. **Set SSL variable:**
   ```bash
   terraform apply -var="ssl_enabled=true"
   ```

2. **Obtain SSL certificates** (manual step):
   - Use Let's Encrypt with Certbot
   - Or upload your certificates to the server

3. **Update Nginx configuration** to include certificate paths

## Updating the Site

To deploy updates:

1. **Build the updated site:**
   ```bash
   npm run build
   ```

2. **Redeploy:**
   ```bash
   cd deploy
   terraform apply
   ```

The deployment will automatically sync only changed files and reload Nginx.

## Destroying the Deployment

To remove all deployed resources:

```bash
terraform destroy
```

**Warning:** This will remove Nginx configuration and site files but won't uninstall Nginx itself.

## Security Considerations

- Change default SSH port if needed
- Configure fail2ban for SSH protection
- Set up regular backups
- Keep server packages updated
- Configure SSL certificates for production use
- Review and customize firewall rules as needed

## Passwordless sudo for `webadmin`

This deployment includes a Terraform resource `enable_passwordless_sudo` that will create a sudoers drop-in file for the `webadmin` user and enable passwordless sudo. This resource connects as `root` (it uses `var.ssh_user = "root"` for the connection) and writes `/etc/sudoers.d/webadmin-nopasswd`.

Use caution:

- Only run this if you trust the `webadmin` user and the server environment.
- The resource will validate the created sudoers file using `visudo`.

To run only the sudoers-creation step manually (safe approach):

```bash
cd deploy
# initialize terraform if needed
terraform init
# apply only the resource that creates the sudoers file
terraform apply -target=null_resource.enable_passwordless_sudo
```

If you prefer not to run this resource, ensure your chosen `ssh_user` can run the necessary commands (either by connecting as `root` or by configuring passwordless sudo manually).