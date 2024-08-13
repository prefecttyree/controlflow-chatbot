#!/bin/bash

# Set your Google Cloud project ID
PROJECT_ID="prefect-sbx-sales-engineering"

# Set your desired region
REGION="us-central1"

# Set your repository name
REPO_NAME="tyree-docker"

# Set your image name
IMAGE_NAME="controlflow-chatbot"

# Set the tag for your image
IMAGE_TAG="latest"

# Full image path
FULL_IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"

# Authenticate with Google Cloud
gcloud auth configure-docker ${REGION}-docker.pkg.dev

# Build the Docker image
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

# Tag the image for Google Cloud Artifact Registry
docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_PATH}

# Push the image to Artifact Registry
docker push ${FULL_IMAGE_PATH}

echo "Image pushed successfully to Google Cloud Artifact Registry!"