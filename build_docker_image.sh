#!/bin/bash

# Build the Docker image for the Jupyter project
PROJECT_DIR="my_jupyter_project"
IMAGE_NAME="my-jupyter-notebook-image"
cd "$PROJECT_DIR" || exit 1
docker build -t "$IMAGE_NAME" .
echo "Docker image '$IMAGE_NAME' built."
