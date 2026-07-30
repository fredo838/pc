#!/bin/bash
# Go (Golang) installation

echo "Installing Go..."

sudo apt-get update
sudo apt-get install -y golang-go

echo "✓ Go installed successfully"
go version
