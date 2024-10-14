#!/bin/bash

# Set AWS region and account ID
AWS_REGION="eu-west-1"
AWS_ACCOUNT_ID="171055612566"
ECR_REPOSITORY_NAME="h-project-ecr-backend-image"

# Authenticate Docker to the Amazon ECR registry
echo "Authenticating Docker to Amazon ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build the Docker images
echo "Building Docker images..."
docker build -t frontend-image ./frontend
docker build -t backend-image ./backend

# Tag the Docker images with the ECR repository URI
echo "Tagging Docker images..."
docker tag backend-image $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPOSITORY_NAME}:backend
docker tag frontend-image $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${ECR_REPOSITORY_NAME}:frontend

# Push the Docker images to Amazon ECR
echo "Pushing Docker images to Amazon ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${BACKEND_ECR_REPOSITORY_NAME}:backend
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${FRONTEND_ECR_REPOSITORY_NAME}:frontend

echo "Script execution completed."
