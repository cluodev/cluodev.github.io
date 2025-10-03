# Terraform configuration for deploying Charles Luo's blog
# This deployment sets up the infrastructure on a Linux server

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Variables for configuration
variable "server_ip" {
  description = "IP address of the target server (can be set via TF_VAR_server_ip env var or .env file)"
  type        = string
  default     = ""
}

variable "ssh_user" {
  description = "SSH user for server access (use 'root' or a sudo user configured for passwordless sudo)"
  type        = string
  default     = "root"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "~/.ssh/id_ed25519_cldsrv"
}

variable "domain_name" {
  description = "Domain name for the blog"
  type        = string
  default     = "www.cluodev.com"
}

variable "site_name" {
  description = "Human-friendly name of the site (for display)"
  type        = string
  default     = "Charles Luo Tech Blog"
}

variable "site_dir_name" {
  description = "Filesystem-safe directory name for the site (used for /var/www and nginx filenames). Use only letters, numbers, dashes and underscores."
  type        = string
  default     = "cluodev-blog"
}

variable "nginx_port" {
  description = "Port for Nginx to listen on"
  type        = number
  default     = 80
}

variable "ssl_enabled" {
  description = "Enable SSL/HTTPS"
  type        = bool
  default     = false
}