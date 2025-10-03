#!/bin/bash

# Deployment script for Charles Luo's blog
# This script builds the site and deploys it using Terraform

set -e

echo "🚀 Starting deployment process..."

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Error: package.json not found. Please run this script from the project root."
    exit 1
fi

# Check if dist directory exists and is not empty
if [ ! -d "dist" ] || [ -z "$(ls -A dist)" ]; then
    echo "📦 Building the site..."
    npm run build
    
    if [ $? -ne 0 ]; then
        echo "❌ Build failed. Please fix the issues and try again."
        exit 1
    fi
else
    echo "📦 Using existing build in dist/ directory"
    read -p "Do you want to rebuild? (y/N): " rebuild
    if [[ $rebuild =~ ^[Yy]$ ]]; then
        npm run build
    fi
fi

# Navigate to deploy directory
cd deploy

# Load environment variables from .env file
if [ -f ".env" ]; then
    echo "📝 Loading environment variables from .env..."
    export $(grep -v '^#' .env | xargs)
fi

echo "🔧 Initializing Terraform..."
terraform init

echo "📋 Planning deployment..."
export TF_VAR_ssh_user=webadmin
export TF_VAR_server_ip=${SERVER_IP}
echo "Using SSH user: $TF_VAR_ssh_user"
echo "Using server IP: $TF_VAR_server_ip"
terraform plan -var "ssh_user=$TF_VAR_ssh_user" -var "server_ip=$TF_VAR_server_ip"

echo "🚀 Applying deployment..."
read -p "Do you want to proceed with the deployment? (y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "Applying main resources (install_nginx, nginx_config, deploy_site, firewall_setup) and skipping enable_passwordless_sudo"
        terraform apply -auto-approve \
            -var "ssh_user=$TF_VAR_ssh_user" \
            -var "server_ip=$TF_VAR_server_ip" \
            -target=null_resource.install_nginx \
            -target=null_resource.nginx_config \
            -target=null_resource.deploy_site \
            -target=null_resource.firewall_setup
    
    if [ $? -eq 0 ]; then
        echo "✅ Deployment completed successfully!"
        echo ""
        echo "🌐 Your site should now be accessible at:"
        terraform output -raw site_url_ip
        echo ""
        echo "📊 Useful commands:"
        terraform output -json deployment_commands | jq -r 'to_entries[] | "\(.key): \(.value)"'
    else
        echo "❌ Deployment failed. Check the error messages above."
        exit 1
    fi
else
    echo "❌ Deployment cancelled."
    exit 1
fi