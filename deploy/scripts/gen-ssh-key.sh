#!/usr/bin/env bash

# Generate ED25519 SSH key pair (more secure than RSA)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_cldsrv_phi -C "charles@cluodev.com"

# Set correct permissions
chmod 600 ~/.ssh/id_ed25519_cldsrv_phi
chmod 644 ~/.ssh/id_ed25519_cldsrv_phi.pub

# source ../.env
# Method 1: Using ssh-copy-id (easiest)
ssh-copy-id -i ~/.ssh/id_ed25519_cldsrv_phi.pub "${ADMIN_USER}@${SERVER_IP}"