#!/bin/bash
# Python configuration files setup

echo "Setting up Python configuration files..."

# Create .netrc file
echo "Creating ~/.netrc..."
touch ~/.netrc
chmod 600 ~/.netrc
# Edit manually: gedit ~/.netrc

# Create pip configuration directory and file
echo "Creating ~/.pip/pip.conf..."
mkdir -p ~/.pip
touch ~/.pip/pip.conf
# Edit manually with pip configuration
# Example content:
# [global]
# extra-index-url =
#     https://gitlab.com/api/v4/groups/58977424/-/packages/pypi/simple

# Create .pypirc file
echo "Creating ~/.pypirc..."
touch ~/.pypirc
chmod 600 ~/.pypirc
# Edit manually with pypi configuration
# Example content:
# [distutils]
# index-servers =
#     gitlab
#
# [gitlab]
# repository = https://gitlab.com/api/v4/groups/58977424/-/packages/pypi

echo "✓ Configuration files created"
echo "Please manually edit the following files with your credentials:"
echo "  - ~/.netrc"
echo "  - ~/.pip/pip.conf"
echo "  - ~/.pypirc"
