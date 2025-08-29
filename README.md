# SageAttention

High-performance attention mechanisms for PyTorch with CUDA support.

## 🚀 Quick Start

### Using Docker (Recommended)

Build wheels for your platform and PyTorch version:

```bash
# Build for Linux + PyTorch 2.8 + CUDA 12.9 + Python 3.12
docker buildx bake --file docker-bake.hcl linux-pytorch28-cu129-python312

# Build for Linux + PyTorch 2.7 + CUDA 12.8 + Python 3.12  
docker buildx bake --file docker-bake.hcl linux-pytorch27-cu128-python312

# Build for Windows + PyTorch 2.8 + CUDA 12.9 + Python 3.12
docker buildx bake --file docker-bake.hcl windows-pytorch28-cu129-python312

# Build all platforms and versions
docker buildx bake --file docker-bake.hcl all
```

### Wheel Naming Convention

Wheels follow the standard pip naming convention:
```
sageattention-{version}-cp{python}-cp{python}-{platform}.whl
```

**Examples:**
- `sageattention-0.1.0-cp312-cp312-manylinux_x86_64.whl` - Linux + Python 3.12
- `sageattention-0.1.0-cp312-cp312-win_amd64.whl` - Windows + Python 3.12

**Build Matrix:**
- **Platforms:** Linux (manylinux_x86_64), Windows (win_amd64)
- **Python:** 3.12
- **PyTorch:** 2.7.0, 2.8.0
- **CUDA:** 12.8.1, 12.9.1

### Testing Built Wheels

Test wheels using Docker:

```bash
# Test Linux + PyTorch 2.7 + CUDA 12.8
docker buildx bake --file docker-bake.hcl test-linux-pytorch27-cu128-python312

# Test Linux + PyTorch 2.8 + CUDA 12.9
docker buildx bake --file docker-bake.hcl test-linux-pytorch28-cu129-python312
```

### Convenience Groups

```bash
# Build all Linux wheels
docker buildx bake --file docker-bake.hcl linux

# Build all Windows wheels  
docker buildx bake --file docker-bake.hcl windows

# Build all PyTorch 2.7 wheels
docker buildx bake --file docker-bake.hcl pytorch27

# Build all PyTorch 2.8 wheels
docker buildx bake --file docker-bake.hcl pytorch28

# Test all Linux builds
docker buildx bake --file docker-bake.hcl test-all
```

## 🔧 Local Development

### Prerequisites

- Docker with Buildx support
- Multi-platform builder instance

```bash
# Create multi-platform builder
docker buildx create --name multiplatform --driver docker-container --use
docker buildx inspect --bootstrap
```

### Building Locally

```bash
# Build wheel for current platform
docker buildx bake --file docker-bake.hcl default

# Build specific target
docker buildx bake --file docker-bake.hcl linux-pytorch28-cu129-python312
```

Wheels are saved to the `./builder/` directory (git-ignored).

## 📦 CI/CD

The GitHub Actions workflow automatically builds and tests wheels for all supported configurations using Docker Bake.

## 🏗️ Architecture

- **Multi-stage builds** for efficient wheel creation
- **Platform-specific Dockerfiles** (Linux/Windows)
- **CUDA version compatibility** (12.8, 12.9)
- **PyTorch version support** (2.7, 2.8)
- **Python 3.12** support

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.
