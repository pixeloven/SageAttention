# SageAttention

SageAttention is an efficient and accurate attention mechanism that uses **low-bit quantization** to reduce memory usage and computational cost while maintaining high accuracy.

This fork extends the original SageAttention project with:

1. **Docker-based Build System** - Consistent builds across different environments
2. **Multi-platform Support** - Linux and Windows builds with Python 3.12 focus
3. **Automated CI/CD Pipeline** - Builds wheels for multiple configurations automatically
4. **GitHub Packages Distribution** - Pre-built wheels available for easy installation
5. **Unified Docker Bake Configuration** - Simple commands for all build needs

## Build System

Our Docker-based build system provides consistent, reproducible builds across platforms:

- **Linux containers**: Ubuntu 24.04 + CUDA 12.9.1 + cuDNN
- **Windows containers**: Windows Server Core 2022 + Chocolatey + Visual Studio Build Tools
- **Multi-platform support**: Build for both Linux and Windows simultaneously

The system automatically builds wheels for:
- **Platforms**: Linux and Windows
- **Python**: 3.12 (primary support)
- **PyTorch**: 2.7.0, 2.8.0
- **CUDA**: 12.9.1
- **GPU Architectures**: 8.0, 8.6, 8.9, 9.0, 12.0

### Supported Build Configurations

| PyTorch Version | CUDA Version | Platform | Package Name Example |
|----------------|--------------|----------|---------------------|
| 2.7.0 | 12.9.1 | Linux | `sageattention-2.2.0+cu9torch7.0-cp312-cp312-manylinux_x86_64.whl` |
| 2.7.0 | 12.9.1 | Windows | `sageattention-2.2.0+cu9torch7.0-cp312-cp312-win_amd64.whl` |
| 2.8.0 | 12.9.1 | Linux | `sageattention-2.2.0+cu9torch8.0-cp312-cp312-manylinux_x86_64.whl` |
| 2.8.0 | 12.9.1 | Windows | `sageattention-2.2.0+cu9torch8.0-cp312-cp312-win_amd64.whl` |

**Package Naming Convention:**
```
sageattention-{version}+cu{cuda_minor}torch{torch_minor}.{torch_patch}-cp{python_version}-cp{python_version}-{platform_suffix}.whl
```

**Components:**
- `{version}`: SageAttention version (e.g., 2.2.0)
- `cu{cuda_minor}`: CUDA minor version (9 for 12.9)
- `torch{torch_minor}.{torch_patch}`: PyTorch version (7.0, 8.0)
- `cp{python_version}`: Python version (cp312 for Python 3.12)
- `{platform_suffix}`: Platform suffix (manylinux_x86_64, win_amd64)

### Quick Build Commands

```bash
# Build Linux wheels
docker buildx bake --file docker-bake.hcl wheel-linux

# Build Windows wheels
docker buildx bake --file docker-bake.hcl wheel-windows

# Build for both platforms
docker buildx bake --file docker-bake.hcl multi-platform

# Test Linux wheels
docker buildx bake --file docker-bake.hcl test-linux

# Test Windows wheels
docker buildx bake --file docker-bake.hcl test-windows
```

## Available Packages

Once the CI pipeline completes successfully, pre-built wheels are available in the [GitHub Packages repository](https://github.com/pixeloven/SageAttention/packages).

### Prerequisites

- Docker with Buildx support
- Multi-platform builder configured
- CUDA 12.9.1 or higher
- Python 3.12
- PyTorch with CUDA support
- Compatible GPU (compute capability 8.0+)

### Setup Multi-platform Builder

```bash
# Create multi-platform builder
docker buildx create --name multiplatform --driver docker-container --use

# Bootstrap the builder
docker buildx inspect --bootstrap
```

### Build Options

#### Option 1: Docker Bake (Recommended)
```bash
# Build Linux wheels
docker buildx bake --file docker-bake.hcl wheel-linux

# Build Windows wheels
docker buildx bake --file docker-bake.hcl wheel-windows

# Build both platforms
docker buildx bake --file docker-bake.hcl multi-platform
```

#### Option 2: Direct Docker Build
```bash
# Build Linux image
docker build -f dockerfile.builder.linux -t sageattention-linux .

# Build Windows image
docker build -f dockerfile.builder.windows -t sageattention-windows .
```

### Environment Variables

Set these for custom builds:
```bash
export TORCH_CUDA_ARCH_LIST="8.0;8.6;8.9;9.0;12.0"
export CUDA_VERSION="12.9.1"
export PYTHON_VERSION="3.12"
export TORCH_MINOR_VERSION="7"
export TORCH_PATCH_VERSION="0"
```

### Testing Built Wheels

```bash
# Test Linux wheels
docker buildx bake --file docker-bake.hcl test-linux

# Test Windows wheels
docker buildx bake --file docker-bake.hcl test-windows
```

### Troubleshooting

**Common Issues:**

1. **Platform not supported**: Ensure you have a multi-platform builder
2. **Windows build fails**: Check that Windows containers are enabled
3. **Path issues**: Verify Dockerfile syntax for the target platform
4. **Cache issues**: Clear Docker build cache if builds are inconsistent

**Debug Commands:**
```bash
# Check available targets
docker buildx bake --file docker-bake.hcl --list targets

# Validate configuration
docker buildx bake --file docker-bake.hcl --print wheel-linux

# Build with verbose output
docker buildx bake --file docker-bake.hcl wheel-linux --progress=plain
```

## Using in Downstream Projects

### From GitHub Packages

```bash
# Install from GitHub Packages
pip install sageattention --index-url https://github.com/pixeloven/SageAttention/packages/pypi
```

### From Local Wheels

```bash
# Install from local wheel
pip install ./wheels/sageattention-2.2.0+cu9torch7.0-cp312-cp312-manylinux_x86_64.whl
```

## Development

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/pixeloven/SageAttention.git
cd SageAttention

# Install in development mode
pip install -e .

# Run tests
python -m pytest tests/
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker builds
5. Submit a pull request

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original SageAttention implementation
- NVIDIA CUDA toolkit and cuDNN
- PyTorch team for the excellent framework
- Docker community for containerization tools
