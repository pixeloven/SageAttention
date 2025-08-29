# [SageAttention](https://github.com/thu-ml/SageAttention) Fork - Build System Integration

This repository is a fork of the original SageAttention project that provides enhanced build system integration and automated CI/CD pipeline for distributing pre-built Python wheels across multiple Python, PyTorch, and CUDA versions.

## What is SageAttention?

SageAttention is an efficient and accurate attention mechanism that uses **low-bit quantization** to significantly reduce memory usage and increase speed while maintaining accuracy. It provides:

- **INT8 quantization** for Query and Key tensors
- **FP8/FP16 quantization** for Value tensors  
- **Hardware-optimized kernels** for different GPU architectures (SM80, SM89, SM90)
- **Plug-and-play integration** - easily replace `scaled_dot_product_attention` in existing models
- **Support for multiple tensor layouts** (HND, NHD)
- **Variable-length sequence support**

## What This Fork Adds

This fork extends the original SageAttention project with:

1. **Unified Build System** - Simple `python build.py` commands for all build needs
2. **Hybrid Build Approach** - Docker for consistency, cibuildwheel for performance
3. **Automated CI/CD Pipeline** - Builds wheels for multiple configurations automatically
4. **GitHub Packages Distribution** - Pre-built wheels available for easy installation
5. **Multi-platform Support** - Linux and Windows builds with Python 3.12 focus

## Build System

Our hybrid build system combines the best of both approaches:

- **Docker builds** for development and testing (consistent environment)
- **cibuildwheel builds** for CI/CD and production (faster builds)

The system automatically builds wheels for:
- **Platforms**: Linux and Windows
- **Python**: 3.12 (primary support)
- **PyTorch**: 2.6.0, 2.7.0, 2.8.0
- **CUDA**: 12.8, 12.9
- **GPU Architectures**: 8.0, 8.6, 8.9, 9.0, 12.0

### Supported Build Configurations

| PyTorch Version | CUDA Version | Platform | Package Name Example |
|----------------|--------------|----------|---------------------|
| 2.6.0 | 12.8 | Linux | `sageattention-2.2.0+cu128torch2.6.0-cp312-cp312-linux_x86_64.whl` |
| 2.6.0 | 12.8 | Windows | `sageattention-2.2.0+cu128torch2.6.0-cp312-cp312-win_amd64.whl` |
| 2.7.0 | 12.9 | Linux | `sageattention-2.2.0+cu129torch2.7.0-cp312-cp312-linux_x86_64.whl` |
| 2.7.0 | 12.9 | Windows | `sageattention-2.2.0+cu129torch2.7.0-cp312-cp312-win_amd64.whl` |
| 2.8.0 | 12.9 | Linux | `sageattention-2.2.0+cu129torch2.8.0-cp312-cp312-linux_x86_64.whl` |
| 2.8.0 | 12.9 | Windows | `sageattention-2.2.0+cu129torch2.8.0-cp312-cp312-win_amd64.whl` |

**Package Naming Convention:**
```
sageattention-{version}+cu{minor}torch{major}.{patch}-cp{python_version}-{platform}_{arch}.whl
```

**Components:**
- `{version}`: SageAttention version (e.g., 2.2.0)
- `cu{minor}`: CUDA minor version (128 for 12.8, 129 for 12.9)
- `torch{major}.{patch}`: PyTorch version (2.6.0, 2.7.0, 2.8.0)
- `cp{python_version}`: Python version (cp312 for Python 3.12)
- `{platform}_{arch}`: Platform and architecture (linux_x86_64, win_amd64)

### Quick Build Commands

```bash
# Development build (Docker - consistent)
python build.py docker

# Production build (cibuildwheel - fast)
python build.py cibuildwheel

# Test wheels
python build.py test
```

## Available Packages

Once the CI pipeline completes successfully, pre-built wheels are available in the [GitHub Packages](https://github.com/pixeloven/SageAttention/packages) section of this repository.

## Building Locally

### Prerequisites

- CUDA 12.0 or higher
- Python 3.12 (primary support)
- PyTorch with CUDA support
- Compatible GPU (compute capability 8.0+)

### Quick Build Options

#### Option 1: Docker Build (Recommended for Development)
```bash
# Build using Docker (consistent environment)
docker build -f dockerfile.builder -t sageattention-dev .

# Or use the unified build script
python build.py docker
```

#### Option 2: cibuildwheel Build (Recommended for Production)
```bash
# Install cibuildwheel
pip install cibuildwheel

# Build for current platform
python build.py cibuildwheel

# Build for specific platform
python build.py cibuildwheel --platform linux
```

#### Option 3: Direct Installation
```bash
# Install dependencies
pip install torch==2.7.0+cu129 --index-url https://download.pytorch.org/whl/cu129

# Install SageAttention
python setup.py install
```

### Environment Variables

Set these for custom builds:
```bash
export TORCH_CUDA_ARCH_LIST="8.0 8.6 8.9 9.0 12.0"
export CUDA_MINOR_VERSION="9"
export TORCH_MINOR_VERSION="8"
export TORCH_PATCH_VERSION="0"
```

### Testing Built Wheels

```bash
# Test wheels using Docker (maintains consistency)
python build.py test
```

### Troubleshooting

**Common Issues:**

1. **CUDA not found**: Ensure `CUDA_HOME` is set and CUDA toolkit is installed
2. **PyTorch version mismatch**: Install the correct PyTorch version for your CUDA
3. **Build failures on Windows**: Use Developer Command Prompt and ensure MSVC is in PATH
4. **Memory issues**: Reduce parallel builds with `export EXT_PARALLEL=2`

**Debug Commands:**
```bash
# Check environment
python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.version.cuda}')"
nvcc --version
nvidia-smi
```

## Using in Downstream Projects

### Installation from GitHub Packages

```bash
# Install from GitHub Packages
pip install sageattention --index-url https://github.com/pixeloven/SageAttention/packages/pypi/simple/
```
