# SageAttn3 Build Specification

This document outlines the specification for integrating the `sageattn3` build process into the existing SageAttention CI/CD pipeline.

## Overview
`sageattn3` is a new package located in the `sageattention3_blackwell` directory, targeting NVIDIA Blackwell architectures (Compute Capability 10.0, 12.0).

## Build Principles
We will adhere to the "Native Build" principles established for SageAttention 2.2.0:
1.  **No `cibuildwheel`**: We use native GitHub Actions runners (`ubuntu-latest`, `windows-latest`) and standard `python setup.py bdist_wheel` commands.
2.  **Explicit Dependency Management**: We explicitly install CUDA Toolkit and PyTorch via `pip` with correct index URLs, avoiding opaque build environments.
3.  **Matrix Strategy**: verification across supported Python, PyTorch, and CUDA combinations.
4.  **Orchestrated Release**: A central `ci.yml` orchestrates builds and creates a unified GitHub Release.

## Target Configuration

| Component | Specification | Notes |
|BC|---|---|
| **Package Name** | `sageattn3` | |
| **Source Dir** | `sageattention3_blackwell/` | |
| **Platforms** | Linux (`x86_64`), Windows (`amd64`) | |
| **Python** | 3.12 | Currently restricted to 3.12 by upstream preferences, but extensible. |
| **CUDA** | 12.8, 12.9, 13.0, 13.1 | Expanded support for future architectures. |
| **PyTorch** | 2.9.0 | Legacy support (2.7, 2.8) dropped to reduce build time. |
| **Architectures** | `10.0;12.0` | Blackwell specific. Upstream uses 12.0; we will support both if possible or default to 12.0. |

## Workflows

### 1. Specialize Reusable Workflows
We will create two new reusable workflows to handle the specific needs of `sageattn3` (e.g. `cutlass` submodule, different setup script location).

*   `.github/workflows/build-sageattn3-linux.yml`
*   `.github/workflows/build-sageattn3-windows.yml`

**Key Steps:**
1.  **Checkout**: Must include `submodules: recursive` to fetch `cutlass`.
2.  **Environment Setup**: Install Python 3.12, CUDA 12.8.
3.  **Dependencies**: Install PyTorch (via `index-url`), `numpy`, `packaging`, `ninja`.
4.  **Build**:
    *   `cd sageattention3_blackwell`
    *   Set `TORCH_CUDA_ARCH_LIST="12.0"` (or "10.0;12.0")
    *   python setup.py bdist_wheel
5.  **Artifacts**: Upload wheels with prefix `sageattn3-`.

### 2. Update Orchestrator (`ci.yml`)
The main `ci.yml` will be updated to:
1.  Call `build-sageattn3-linux.yml` strategy.
2.  Call `build-sageattn3-windows.yml` strategy.
3.  **Release Job**:
    *   Download `sageattn3` artifacts alongside `sageattention` artifacts.
    *   Publish all to the GitHub Release.

## Artifact Naming
Wheels will follow standard naming, e.g.:
`sageattn3-1.0.0+cu128torch2.9.0-cp312-cp312-linux_x86_64.whl`

We will ensure the `+cu...` local version identifier is correctly appended to distinguish builds, similar to the main package.
