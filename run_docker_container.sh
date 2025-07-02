#!/bin/bash

# Run the Docker container for the Jupyter project
IMAGE_NAME="my-jupyter-notebook-image"
CONTAINER_NAME="my-jupyter-container"
JUPYTER_PORT="8888"

docker run -p "${JUPYTER_PORT}:${JUPYTER_PORT}" --name "$CONTAINER_NAME" "$IMAGE_NAME"
