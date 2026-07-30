#!/bin/bash
# Google Cloud SDK installation

echo "Installing Google Cloud SDK..."

# Add Google Cloud GPG key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# Add Google Cloud repository
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Install gcloud CLI
sudo apt-get update
sudo apt-get install -y google-cloud-cli
sudo apt-get install -y google-cloud-cli-docker-credential-gcr

echo "✓ Google Cloud SDK installed successfully"
gcloud --version

echo ""
echo "Optional: Configure Docker credentials for GCR"
echo "Create/update ~/.docker/config.json:"
echo "{"
echo '    "credHelpers": {'
echo '        "europe-west1-docker.pkg.dev": "gcr"'
echo '    }'
echo "}"
