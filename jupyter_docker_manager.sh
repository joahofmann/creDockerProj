#!/bin/bash

# --- Configuration ---
PROJECT_DIR="my_jupyter_project"
NOTEBOOK_FILE="my_notebook.ipynb"
REQUIREMENTS_FILE="requirements.txt"
DOCKERFILE_NAME="Dockerfile"
IMAGE_NAME="my-jupyter-notebook-image"
CONTAINER_NAME="my-jupyter-container"
JUPYTER_PORT="8888"
BASE_JUPYTER_IMAGE="jupyter/datascience-notebook:latest" # You can choose other images like jupyter/scipy-notebook

# --- Notebook Content (minimal example) ---
# This uses a heredoc to define the notebook JSON content.
# In a real scenario, you'd likely have this file already created.
read -r -d '' NOTEBOOK_CONTENT << EOM
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import pandas as pd\n",
    "import numpy as np\n",
    "import matplotlib.pyplot as plt\n",
    "\n",
    "# Create some sample data\n",
    "data = {\n",
    "    'Category': ['A', 'B', 'C', 'D', 'E'],\n",
    "    'Value': np.random.randint(10, 100, 5)\n",
    "}\n",
    "df = pd.DataFrame(data)\n",
    "\n",
    "print(\"DataFrame created:\")\n",
    "print(df)\n",
    "\n",
    "# Plotting the data (optional, but shows full functionality)\n",
    "plt.figure(figsize=(8, 5))\n",
    "plt.bar(df['Category'], df['Value'], color='skyblue')\n",
    "plt.xlabel('Category')\n",
    "plt.ylabel('Value')\n",
    "plt.title('Sample Data Visualization in Jupyter')\n",
    "plt.grid(axis='y', linestyle='--', alpha=0.7)\n",
    "plt.show()\n",
    "\n",
    "# Simple calculation\n",
    "sum_value = df['Value'].sum()\n",
    "print(f\"\\nSum of values: {sum_value}\")"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3 (ipykernel)",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.11.9"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOM

# --- Requirements Content ---
read -r -d '' REQUIREMENTS_CONTENT << EOM
pandas==2.2.2
numpy==1.26.4
matplotlib==3.8.4
jupyterlab==4.2.0
EOM

# --- Dockerfile Content ---
read -r -d '' DOCKERFILE_CONTENT << EOM
FROM ${BASE_JUPYTER_IMAGE}

WORKDIR /home/jovyan/work

COPY ${REQUIREMENTS_FILE} .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r ${REQUIREMENTS_FILE}

COPY . .

EXPOSE ${JUPYTER_PORT}

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=${JUPYTER_PORT}", "--no-browser", "--allow-root"]
EOM

# --- Functions ---

create_project_files() {
    echo "--- Creating project directory and files ---"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR" || exit

    echo "$NOTEBOOK_CONTENT" > "$NOTEBOOK_FILE"
    echo "Created $NOTEBOOK_FILE"

    echo "$REQUIREMENTS_CONTENT" > "$REQUIREMENTS_FILE"
    echo "Created $REQUIREMENTS_FILE"

    echo "$DOCKERFILE_CONTENT" > "$DOCKERFILE_NAME"
    echo "Created $DOCKERFILE_NAME"

    echo "Project files are ready in: $(pwd)"
}

build_docker_image() {
    echo "--- Building Docker image: ${IMAGE_NAME} ---"
    docker build -t "$IMAGE_NAME" .
    if [ $? -ne 0 ]; then
        echo "Error: Docker image build failed."
        exit 1
    fi
    echo "Docker image '${IMAGE_NAME}' built successfully."
}

run_docker_container() {
    echo "--- Running Docker container: ${CONTAINER_NAME} ---"
    # Stop and remove existing container if it's running/exists
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo "Existing container '${CONTAINER_NAME}' found. Stopping and removing..."
        docker stop "$CONTAINER_NAME" > /dev/null 2>&1
        docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    fi

    echo "Starting container. Look for the URL with a token in the output."
    echo "Access JupyterLab via: http://localhost:${JUPYTER_PORT}/lab?token=..."
    echo "Press Ctrl+C in this terminal to stop the container."
    docker run -p "${JUPYTER_PORT}:${JUPYTER_PORT}" --name "$CONTAINER_NAME" "$IMAGE_NAME"
}

cleanup() {
    echo "--- Cleaning up ---"
    echo "Stopping and removing container '${CONTAINER_NAME}' (if running/exists)..."
    docker stop "$CONTAINER_NAME" > /dev/null 2>&1
    docker rm "$CONTAINER_NAME" > /dev/null 2>&1
    echo "Removing Docker image '${IMAGE_NAME}'..."
    # rmi might fail if image is still in use by a stopped container or doesn't exist
    docker rmi "$IMAGE_NAME" > /dev/null 2>&1 || true
    cd ..
    echo "Removing project directory '${PROJECT_DIR}'..."
    rm -rf "$PROJECT_DIR"
    echo "Cleanup complete."
}

# --- Main Script Execution ---

# Check for Docker installation
if ! command -v docker &> /dev/null
then
    echo "Error: Docker is not installed. Please install Docker Desktop first."
    exit 1
fi

case "$1" in
    build)
        create_project_files
        build_docker_image
        echo "Build complete. You can now run the container with: ./$(basename "$0") run"
        ;;
    run)
        # Ensure we are in the correct directory if running 'run' directly
        if [ ! -d "$PROJECT_DIR" ]; then
            echo "Error: Project directory '$PROJECT_DIR' not found. Please run 'build' first."
            exit 1
        fi
        cd "$PROJECT_DIR" || exit
        # Check if image exists before trying to run
        if ! docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
            echo "Error: Docker image '${IMAGE_NAME}' not found. Please run 'build' first."
            exit 1
        fi
        run_docker_container
        ;;
    all)
        create_project_files
        build_docker_image
        run_docker_container
        ;;
    cleanup)
        cleanup
        ;;
    *)
        echo "Usage: $(basename "$0") {build|run|all|cleanup}"
        echo "  build: Creates project files and builds the Docker image."
        echo "  run:   Runs the Docker container (requires image to be built)."
        echo "  all:   Performs build and then runs the container."
        echo "  cleanup: Stops/removes container, deletes image, and project directory."
        exit 1
        ;;
esac

echo "Script finished."