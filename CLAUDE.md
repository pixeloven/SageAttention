# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

SageAttention is a high-performance PyTorch extension providing optimized CUDA attention mechanisms with multi-platform wheel builds. The project uses Docker-based build workflows to ensure consistent cross-platform compilation.

## Build System

### Docker-based Building (Primary)
Use Docker Bake for consistent builds with automatic wheel versioning:

```bash
# Build for current platform (Linux + PyTorch 2.8 + CUDA 12.9)
docker buildx bake --file docker-bake.hcl default

# Build specific configurations (wheels automatically include version info)
docker buildx bake --file docker-bake.hcl linux-pytorch28-cu129-python312
docker buildx bake --file docker-bake.hcl windows-pytorch28-cu129-python312

# Build all platforms and versions
docker buildx bake --file docker-bake.hcl all

# Convenience groups
docker buildx bake --file docker-bake.hcl linux    # All Linux builds
docker buildx bake --file docker-bake.hcl windows  # All Windows builds
docker buildx bake --file docker-bake.hcl pytorch28 # All PyTorch 2.8 builds
```

### Setup Multi-platform Builder
```bash
docker buildx create --name multiplatform --driver docker-container --use
docker buildx inspect --bootstrap
```

### Testing
```bash
# Test specific builds
docker buildx bake --file docker-bake.hcl test-linux-pytorch28-cu129-python312
docker buildx bake --file docker-bake.hcl test-all
```

### Local Development Setup
```bash
# Direct Python build (requires CUDA toolkit)
pip install -e .

# Run tests
python tests/test_sageattn.py
```

## Architecture

### Core Components
- **sageattention/core.py**: Main attention implementations with CUDA backend detection
- **sageattention/__init__.py**: Entry points for `sageattn`, `sageattn_varlen`, and specialized variants
- **csrc/**: CUDA/C++ extensions organized by compute capability (SM80/SM89/SM90)
- **sageattention/triton/**: Triton kernel implementations for different quantization schemes

### Build Matrix Support
- **Platforms**: Linux (manylinux_x86_64), Windows (win_amd64)
- **Python**: 3.9+ (primary testing on 3.12)
- **PyTorch**: 2.7.0, 2.8.0
- **CUDA**: 12.8.1, 12.9.1
- **Compute Capabilities**: 8.0, 8.6, 8.9, 9.0, 12.0

### Module Structure
- **Attention Variants**: 
  - `sageattn`: Main quantized attention (QK INT8, PV FP16/FP8)
  - `sageattn_varlen`: Variable length sequences
  - Triton and CUDA implementations with automatic backend selection
- **Quantization**: Per-block, per-thread, and per-channel quantization schemes
- **CUDA Extensions**: Separate modules for different SM architectures loaded conditionally

### Build Configuration
- **setup.py**: Main build script with CUDA capability detection and multi-SM support
- **pyproject.toml**: Modern Python packaging with build requirements
- **docker-bake.hcl**: Docker Buildx configuration with clear platform-pytorch-cuda naming
- **update_pyproject.py**: Utility to update PyTorch version requirements

## Development Notes

### CUDA Requirements
- CUDA 12.0+ required (12.3+ for SM 9.0, 12.4+ for SM 8.9, 12.8+ for SM 12.0)
- Automatic CUDA path detection in common locations
- Compute capability detection from available GPUs

### Optimized Docker Architecture
The project uses an optimized multi-stage Docker build system for efficient caching and reduced build times:

**Stage Hierarchy**:
- **runtime**: System dependencies + Python environment + PyTorch (highly cached)  
- **builder**: + SageAttention compilation (wheel stays embedded, rebuilds on source changes)
- **wheel**: Wheel extraction from builder using FROM scratch (minimal layer)
- **test**: Runtime verification (installs wheel from builder)

**Benefits**:
- **Aggressive caching**: System deps and PyTorch only rebuild when versions change
- **Space efficient**: No duplicate installations across stages
- **BuildKit cache mounts**: Linux builds use pip cache mounts for additional optimization
- **Dependency layering**: Dependencies copied before source code for optimal cache invalidation

### Platform-Specific Files
- **dockerfile.builder.linux**: Optimized Linux multi-stage build with cache mounts
- **dockerfile.builder.windows**: Optimized Windows multi-stage build with shared layers

### Testing
- Basic functionality test in `tests/test_sageattn.py`
- Compares SageAttention output against PyTorch SDPA math implementation
- Docker-based testing ensures consistent test environments

### Wheel Output
Built wheels are saved to `./dist/` directory (git-ignored) with version-specific naming:

**Naming Convention:**
- `sageattention-{version}-torch{pytorch}.cu{cuda}-{python}-{abi}-{platform}.whl`
- Example: `sageattention-2.2.0-torch280.cu129-cp312-cp312-linux_x86_64.whl`

**Benefits:**
- Multiple PyTorch/CUDA versions can coexist in same directory
- Clear version identification for deployment and testing
- No overwrites when building multiple configurations