#!/bin/bash
# AWS VPN Client installation

echo "Installing AWS VPN Client..."

# Add AWS VPN Client GPG key
wget -qO- https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo/awsvpnclient_public_key.asc | sudo tee /etc/apt/trusted.gpg.d/awsvpnclient_public_key.asc > /dev/null

# Add AWS VPN Client repository
echo "deb [arch=amd64] https://d20adtppz83p9s.cloudfront.net/GTK/latest/debian-repo ubuntu main" | sudo tee /etc/apt/sources.list.d/aws-vpn-client.list > /dev/null

# Install AWS VPN Client
sudo apt-get update
sudo apt-get install -y awsvpnclient

echo "✓ AWS VPN Client installed successfully"
