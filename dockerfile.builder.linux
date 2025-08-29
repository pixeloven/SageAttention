# SageAttention Builder - Multi-platform multi-stage build for SageAttention wheels
# Supports Linux and Windows with multiple PyTorch versions

# Build arguments for version flexibility
ARG CUDA_VERSION=12.9.1
ARG PYTHON_VERSION=3.12
ARG TORCH_MINOR_VERSION=7
ARG TORCH_PATCH_VERSION=0
ARG TORCH_CUDA_ARCH_LIST="7.0;7.5;8.0;8.6;8.9;9.0"

# Stage 1: SageAttention Builder
FROM nvidia/cuda:${CUDA_VERSION}-cudnn-devel-ubuntu24.04 AS sageattention-builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV CUDA_HOME=/usr/local/cuda-${CUDA_VERSION}
ENV PATH=$CUDA_HOME/bin:$PATH
ENV LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH
ENV PYTHONUNBUFFERED=1
ENV TORCH_CUDA_ARCH_LIST=${TORCH_CUDA_ARCH_LIST}
ENV TORCH_MINOR_VERSION=${TORCH_MINOR_VERSION}
ENV TORCH_PATCH_VERSION=${TORCH_PATCH_VERSION}
ENV PYTHON_VERSION=${PYTHON_VERSION}
ENV CUDA_VERSION=${CUDA_VERSION}

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-dev \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    build-essential \
    git \
    wget \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python${PYTHON_VERSION} -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip and install build tools
RUN pip install --upgrade pip setuptools wheel packaging

# Install PyTorch with appropriate CUDA support
ARG CUDA_SUFFIX
RUN if [ -z "$CUDA_SUFFIX" ]; then \
        pip install torch==2.${TORCH_MINOR_VERSION}.${TORCH_PATCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_VERSION//./} ; \
    else \
        pip install torch==2.${TORCH_MINOR_VERSION}.${TORCH_PATCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_SUFFIX} ; \
    fi

# Copy the local SageAttention source code
WORKDIR /build
COPY . /build/SageAttention/
WORKDIR /build/SageAttention

# Update pyproject.toml with correct PyTorch version
RUN python update_pyproject.py

# Install SageAttention build dependencies
RUN pip install -e .

# Build SageAttention wheel
RUN python setup.py bdist_wheel

# Stage 2: Wheel extraction
FROM scratch AS sageattention-wheel
COPY --from=sageattention-builder /build/SageAttention/dist/*.whl /wheels/

# Stage 3: Runtime verification
FROM nvidia/cuda:${CUDA_VERSION}-base-ubuntu24.04 AS sageattention-test

# Install Python and PyTorch for testing
RUN apt-get update && apt-get install -y --no-install-recommends \
    python${PYTHON_VERSION} \
    python${PYTHON_VERSION}-venv \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python${PYTHON_VERSION} -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Install PyTorch and test the built wheel
RUN pip install torch==2.${TORCH_MINOR_VERSION}.${TORCH_PATCH_VERSION} torchvision --index-url https://download.pytorch.org/whl/cu${CUDA_VERSION//./}

# Copy and install the built wheel
COPY --from=sageattention-builder /build/SageAttention/dist/*.whl /tmp/
RUN pip install /tmp/*.whl

# Test SageAttention import
RUN python -c "import sageattention; print('SageAttention imported successfully')" 