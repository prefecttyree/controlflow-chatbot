#!/bin/bash
chmod +x ./push_to_docker.sh
chmod +x ./push_to_gcp.sh
chmod +x ./run.sh
# Set your Docker Hub username
DOCKERHUB_USERNAME="tytheprefectionist"

# Get the git commit hash
GIT_HASH=$(git rev-parse --short HEAD)

# Build the Docker image
docker buildx build --platform linux/amd64 -t  tytheprefectionist/controlflow-chatbot:arm64 .

# Tag the image with the git hash
docker tag controlflow-chatbot $DOCKERHUB_USERNAME/controlflow-chatbot:$GIT_HASH

# Log in to Docker Hub
echo "Please enter your Docker Hub password:"
docker login --username $DOCKERHUB_USERNAME

# Push the image to Docker Hub
docker push $DOCKERHUB_USERNAME/controlflow-chatbot:$GIT_HASH

echo "Image pushed successfully to Docker Hub with tag: $GIT_HASH"

