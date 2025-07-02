#!/bin/bash

# Create the project directory and files
PROJECT_DIR="my_jupyter_project"
NOTEBOOK_FILE="my_notebook.ipynb"
REQUIREMENTS_FILE="requirements.txt"
DOCKERFILE_NAME="Dockerfile"

mkdir -p "$PROJECT_DIR"
echo "# Sample notebook" > "$PROJECT_DIR/$NOTEBOOK_FILE"
echo "pandas==2.2.2\nnumpy==1.26.4\nmatplotlib==3.8.4\njupyterlab==4.2.0" > "$PROJECT_DIR/$REQUIREMENTS_FILE"
echo -e "FROM jupyter/datascience-notebook:latest\nWORKDIR /home/jovyan/work\nCOPY $REQUIREMENTS_FILE .\nRUN pip install --no-cache-dir --upgrade pip && \\n    pip install --no-cache-dir -r $REQUIREMENTS_FILE\nCOPY . .\nEXPOSE 8888\nCMD [\"jupyter\", \"lab\", \"--ip=0.0.0.0\", \"--port=8888\", \"--no-browser\", \"--allow-root\"]" > "$PROJECT_DIR/$DOCKERFILE_NAME"
echo "Project files created in $PROJECT_DIR"
