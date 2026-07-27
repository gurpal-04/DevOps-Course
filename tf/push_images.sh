#!/usr/bin/env bash
set -euo pipefail

TF_OUT=$(terraform output -json)

BACKEND_REPO=$(echo "$TF_OUT" | jq -r '.backend_ecr_repo_url.value')
FRONTEND_REPO=$(echo "$TF_OUT" | jq -r '.frontend_ecr_repo_url.value')

REGION="us-east-1"

echo "🔹 Backend repo  : $BACKEND_REPO"
echo "🔹 Frontend repo : $FRONTEND_REPO"

# Login to ECR
aws ecr get-login-password --region "$REGION" | \
docker login --username AWS --password-stdin "${BACKEND_REPO%/*}"

# Build backend
echo "🚀 Building backend..."
docker build -t backend-image ../Docker/backend
docker tag backend-image:latest "$BACKEND_REPO:latest"
docker push "$BACKEND_REPO:latest"

# Build frontend
echo "🚀 Building frontend..."
docker build -t frontend-image ../Docker/frontend
docker tag frontend-image:latest "$FRONTEND_REPO:latest"
docker push "$FRONTEND_REPO:latest"

echo "✅ Images pushed successfully"