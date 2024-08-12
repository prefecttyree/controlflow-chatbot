#!/bin/bash

# Set your Docker Hub username
DOCKERHUB_USERNAME="tytheprefectionist"

# Get the git commit hash
GIT_HASH=$(git rev-parse --short HEAD)

# Build the Docker image
docker build -t controlflow-chatbot .

# Tag the image with the git hash
docker tag controlflow-chatbot $DOCKERHUB_USERNAME/gcr.io/$GCP_PROJECT_ID/k8s-streamlit:$GIT_HASH

# Log in to Docker Hub
echo "Please enter your Docker Hub password:"
docker login --username $DOCKERHUB_USERNAME

# Push the image to Docker Hub
docker push $DOCKERHUB_USERNAME/gcr.io/$GCP_PROJECT_ID/k8s-streamlit:$GIT_HASH

echo "Image pushed successfully to Docker Hub with tag: $GIT_HASH"

