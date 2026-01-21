# Contributing to SageAttention (Fork)

## 📂 Project Structure & Tools

This repository is organized to support high-performance attention kernels with robust cross-platform build systems.

### Directory Layout

```text
SageAttention/
├── .github/                 # CI/CD workflows and actions
│   ├── workflows/           # GitHub Actions workflows
│   └── actions/             # Custom composite actions
├── assets/                  # Images and static assets
├── bench/                   # Benchmarking scripts
├── csrc/                    # C++/CUDA source code for kernels
├── example/                 # Example scripts and usage demos
├── sageattention/           # Main Python package source (SageAttention 2)
├── sageattention3_blackwell/# SageAttention 3 (Blackwell-optimized) source
├── tests/                   # Unit tests
├── docker-bake.hcl          # Docker Buildx Bake configuration
├── dockerfile.builder.linux # Main Dockerfile for Linux builds
├── pyproject.toml           # Project configuration and dependencies
├── setup.py                 # SageAttention 2 build script
└── update_pyproject.py      # Script to update version/dependencies
```

### Build Tools & Goals
*   **Docker (`docker-bake.hcl`)**: We use Docker Buildx Bake to orchestrate complex multi-platform builds. This ensures that our build environment is consistent and reproducible, regardless of the host machine.
*   **CI/CD (`.github/workflows`)**: Our GitHub Actions pipeline handles linting, testing, and wheel generation. It automates the release process, ensuring that every tag results in a verified set of artifacts.
*   **Dual-Version Support**: The repository houses both the standard `sageattention` and the next-gen `sageattention3_blackwell` for optimized performance on newer hardware.

This guide details the enhancements made in this fork, specifically regarding **Docker-based builds**, **CI/CD standards** and **Pre-built wheels**.

## 🚀 Quick Start for Developers

### Using Docker (Recommended)
We use `docker buildx bake` to manage complex multi-platform build configurations. This ensures reproducible environments for both Linux and Windows (cross-compilation) artifacts.

```bash
# Build default configuration (Linux + PyTorch 2.8 + CUDA 12.9)
docker buildx bake default

# Build all Linux wheels
docker buildx bake linux
```

**Note on Windows**: Windows wheels are currently built using **native GitHub Actions runners** (or locally via `pip`) rather than Docker, as cross-compilation for CUDA kernels is complex. See the "Windows Support" section below.

### Local Testing
You can run the CI workflows locally using [`act`](https://nektosact.com/installation/index.html) (requires Docker):
```bash
# Run the Linux wheel build workflow
gh act -W .github/workflows/build-wheels-linux.yml --container-architecture linux/amd64
```

## 📦 Releases

We provide pre-built wheels for Linux and Windows for the following configurations:

| PyTorch | CUDA | Python | Platform |
| :---: | :---: | :---: | :---: |
| 2.7.0 | 12.8 | 3.12 | Linux, Windows |
| 2.8.0 | 12.8 | 3.12 | Linux, Windows |
| 2.9.0 | 12.8 | 3.12 | Linux, Windows |

### Wheel Naming Convention
We enforce specific build tags to ensure wheels are strictly PEP 440 compliant while carrying dependency metadata:
*   **Format**: `sageattention-{version}-{build_tag}-...`
*   **Example**: `sageattention-2.2.0-280.128-cp312-cp312-linux_x86_64.whl`
    *   `280.128` represents **PyTorch 2.8** + **CUDA 12.8**.
    *   Format: `{torch_major}{torch_minor}{torch_patch}.{cuda_major}{cuda_minor}`.

### CI/CD Implementation
Our release process is automated via GitHub Actions, which orchestrates the build and verification of these artifacts.
*   **`build-wheels-linux.yml`**: Uses `setup-python` and native runners for speed.
*   **`build-wheels-windows.yml`**: Uses MSVC runners.
*   **Verification**: Both workflows verify the generated wheels by installing them and running a basic import check.