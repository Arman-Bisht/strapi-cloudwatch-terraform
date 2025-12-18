#!/bin/bash
# Deployment Script for Strapi on EC2
# Task 5: Automated deployment helper

set -e

echo "==================================="
echo "Strapi EC2 Deployment Script"
echo "==================================="
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Get Docker Hub username
read -p "Enter your Docker Hub username: " DOCKER_USERNAME

# Build the Docker image
echo ""
echo "📦 Building Docker image..."
cd ../../
docker build -f examples/getstarted/Dockerfile.production -t strapi-app:latest .

# Tag the image
echo ""
echo "🏷️  Tagging image..."
docker tag strapi-app:latest $DOCKER_USERNAME/strapi-app:latest

# Login to Docker Hub
echo ""
echo "🔐 Logging in to Docker Hub..."
docker login

# Push the image
echo ""
echo "⬆️  Pushing image to Docker Hub..."
docker push $DOCKER_USERNAME/strapi-app:latest

echo ""
echo "✅ Docker image pushed successfully!"
echo ""
echo "Next steps:"
echo "1. Navigate to terraform directory: cd examples/getstarted/terraform"
echo "2. Copy terraform.tfvars.example to terraform.tfvars"
echo "3. Update terraform.tfvars with your values"
echo "4. Run: terraform init"
echo "5. Run: terraform plan"
echo "6. Run: terraform apply"
echo ""
echo "Your Docker image: $DOCKER_USERNAME/strapi-app:latest"
