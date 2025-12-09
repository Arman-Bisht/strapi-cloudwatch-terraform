#!/bin/bash
# User Data Script for EC2 Instance
# Installs Docker and runs official Strapi image (much smaller!)

set -e

# Update system
echo "Updating system packages..."
dnf update -y

# Install EC2 Instance Connect for AWS Console SSH access
echo "Installing EC2 Instance Connect..."
dnf install -y ec2-instance-connect

# Create swap file (2GB) for better memory management
echo "Creating swap space..."
dd if=/dev/zero of=/swapfile bs=1M count=2048
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab

# Install Docker
echo "Installing Docker..."
dnf install -y docker

# Start and enable Docker service
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Wait for Docker to be ready
echo "Waiting for Docker to be ready..."
sleep 10

# Pull official Strapi Docker image (much smaller - ~500MB)
echo "Pulling official Strapi Docker image..."
docker pull strapi/strapi:latest

# Run Strapi container
echo "Starting Strapi container..."
docker run -d \
  --name strapi-app \
  --restart unless-stopped \
  -p 1337:1337 \
  -p 80:1337 \
  -e APP_KEYS=toBeModified1,toBeModified2 \
  -e API_TOKEN_SALT=tobemodified \
  -e ADMIN_JWT_SECRET=tobemodified \
  -e TRANSFER_TOKEN_SALT=tobemodified \
  -e JWT_SECRET=tobemodified \
  -v strapi-app:/srv/app \
  strapi/strapi:latest

# Wait for container to start
echo "Waiting for Strapi to start..."
sleep 30

# Check if container is running
if docker ps | grep -q strapi-app; then
  echo "Strapi container is running successfully!"
  docker logs strapi-app | tail -50
else
  echo "Failed to start Strapi container"
  docker logs strapi-app
  exit 1
fi

echo "Deployment completed!"
echo "Swap space: $(free -h | grep Swap)"
echo "Container status: $(docker ps --filter name=strapi-app --format 'table {{.Names}}\t{{.Status}}')"
echo "EC2 Instance Connect is enabled for AWS Console SSH access"
