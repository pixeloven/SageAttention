#!/bin/bash

# SageAttention Wheel Builder Script
# Ensures clean wheel output for both Docker and native builds

set -e

# Function to clean build directory
clean_build_dir() {
    echo "Cleaning build directory..."
    if [ -d "build" ]; then
        rm -rf build/*
    fi
    mkdir -p build
}

# Function to ensure only wheels in build directory  
cleanup_build_output() {
    echo "Ensuring build directory contains only wheels..."
    if [ -d "build" ]; then
        # Remove any non-wheel files
        find build/ -type f ! -name "*.whl" -delete 2>/dev/null || true
        # Remove any empty directories
        find build/ -type d -empty -delete 2>/dev/null || true
        
        echo "Final build directory contents:"
        ls -la build/ || echo "Build directory is empty"
    fi
}

# Parse arguments
COMMAND=${1:-help}

case $COMMAND in
    "docker")
        TARGET=${2:-default}
        echo "Building wheels using Docker with target: $TARGET"
        clean_build_dir
        docker buildx bake --file docker-bake.hcl $TARGET
        cleanup_build_output
        ;;
    "native")
        echo "Building wheels natively..."
        clean_build_dir
        python -m pip install --upgrade pip setuptools wheel packaging
        pip install numpy packaging pybind11
        python update_pyproject.py
        python setup.py bdist_wheel
        mv dist/*.whl build/
        cleanup_build_output
        ;;
    "clean")
        echo "Cleaning build directory only..."
        clean_build_dir
        ;;
    "help"|*)
        echo "Usage: $0 [docker|native|clean] [target]"
        echo ""
        echo "Commands:"
        echo "  docker [target]  - Build using Docker (default target: default)"
        echo "  native          - Build natively (requires CUDA toolkit)"
        echo "  clean           - Clean build directory"
        echo "  help            - Show this help"
        echo ""
        echo "Docker targets: default, linux, windows, all, pytorch27, pytorch28"
        ;;
esac