#!/bin/bash
# Python 3.13 installation

echo "Installing Python 3.13..."

# Add deadsnakes PPA for Python versions
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.13

echo "✓ Python 3.13 installed successfully"
python3.13 --version
