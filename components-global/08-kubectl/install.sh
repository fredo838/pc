#!/bin/bash
# kubectl installation

set -e

echo "Installing kubectl v1.35..."

# Update package list
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

# Add Kubernetes GPG key
sudo install -d -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.35/deb/Release.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.35/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list

# Install kubectl
sudo apt-get update
sudo apt-get install -y kubectl

echo "✓ kubectl installed successfully"
kubectl version --client
