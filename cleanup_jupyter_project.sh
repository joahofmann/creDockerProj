#!/bin/bash

# Cleanup: stop/remove container, remove image, and delete project directory
IMAGE_NAME="my-jupyter-notebook-image"
CONTAINER_NAME="my-jupyter-container"
PROJECT_DIR="my_jupyter_project"

docker stop "$CONTAINER_NAME" > /dev/null 2>&1
docker rm "$CONTAINER_NAME" > /dev/null 2>&1
docker rmi "$IMAGE_NAME" > /dev/null 2>&1 || true
rm -rf "$PROJECT_DIR"
echo "Cleanup complete."
