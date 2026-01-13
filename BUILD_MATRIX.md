# SageAttention Build Matrix

This document describes all supported build combinations for SageAttention packages.

## 📦 Supported Packages

| Package | Version | Min Python | Min PyTorch | Min CUDA | GPU Support |
|---------|---------|------------|-------------|----------|-------------|
| **sageattention** | 2.2.0 | 3.9 | 2.6.0 | 12.0 | sm70-sm121 (all) |
| **sageattn3** | 1.0.0 | 3.9* | 2.8.0 | **12.8** | **sm100, sm120 only** |

*Note: SageAttention3 README recommends Python 3.13+, but setup.py allows 3.9+

---

## 🏗️ SageAttention 2/2++ Build Matrix

### Configured Builds (10 combinations)

| Target Name | Python | PyTorch | CUDA | Architectures | Wheel Example |
|-------------|--------|---------|------|---------------|---------------|
| `linux-sage2-pytorch26-cu126-python39` | 3.9 | 2.6.0 | 12.6.1 | sm70-sm121 | `sageattention-2.2.0-260.126-cp39-cp39-linux_x86_64.whl` |
| `linux-sage2-pytorch26-cu126-python310` | 3.10 | 2.6.0 | 12.6.1 | sm70-sm121 | `sageattention-2.2.0-260.126-cp310-cp310-linux_x86_64.whl` |
| `linux-sage2-pytorch26-cu126-python311` | 3.11 | 2.6.0 | 12.6.1 | sm70-sm121 | `sageattention-2.2.0-260.126-cp311-cp311-linux_x86_64.whl` |
| `linux-sage2-pytorch26-cu126-python312` | 3.12 | 2.6.0 | 12.6.1 | sm70-sm121 | `sageattention-2.2.0-260.126-cp312-cp312-linux_x86_64.whl` |
| `linux-sage2-pytorch27-cu128-python310` | 3.10 | 2.7.0 | 12.8.1 | sm70-sm121 | `sageattention-2.2.0-270.128-cp310-cp310-linux_x86_64.whl` |
| `linux-sage2-pytorch27-cu128-python311` | 3.11 | 2.7.0 | 12.8.1 | sm70-sm121 | `sageattention-2.2.0-270.128-cp311-cp311-linux_x86_64.whl` |
| `linux-sage2-pytorch27-cu128-python312` | 3.12 | 2.7.0 | 12.8.1 | sm70-sm121 | `sageattention-2.2.0-270.128-cp312-cp312-linux_x86_64.whl` |
| `linux-sage2-pytorch28-cu129-python310` | 3.10 | 2.8.0 | 12.9.1 | sm70-sm121 | `sageattention-2.2.0-280.129-cp310-cp310-linux_x86_64.whl` |
| `linux-sage2-pytorch28-cu129-python311` | 3.11 | 2.8.0 | 12.9.1 | sm70-sm121 | `sageattention-2.2.0-280.129-cp311-cp311-linux_x86_64.whl` |
| `linux-sage2-pytorch28-cu129-python312` | 3.12 | 2.8.0 | 12.9.1 | sm70-sm121 | `sageattention-2.2.0-280.129-cp312-cp312-linux_x86_64.whl` |

### GPU Architecture Support (Extended)

All SageAttention 2/2++ wheels include support for:

| Compute Capability | GPUs | SageAttention Version | Notes |
|-------------------|------|----------------------|-------|
| sm70 | V100 | SageAttention 1 (Triton) | Fallback kernel |
| sm75 | RTX 20xx, GTX 16xx | SageAttention 1 (Triton) | Fallback kernel |
| sm80 | A100, RTX 30xx | SageAttention 2 (CUDA) | FP16 PV, FP32 accumulation |
| sm86 | RTX 30xx | SageAttention 2 (CUDA) | Routes to sm80 kernels |
| sm87 | AGX Orin | SageAttention 2 (CUDA) | Routes to sm80 kernels |
| sm89 | RTX 40xx/50xx | SageAttention 2/2++ (CUDA) | FP8 PV, FP32+FP16 accum (CUDA 12.8+) |
| sm90 | H100/H200 | SageAttention 2 (CUDA) | FP8 PV, FP32 accumulation |
| sm100 | B100/B200 | SageAttention 2++ (CUDA) | Per-warp quantization |
| sm120 | B200 | SageAttention 2++ (CUDA) | Per-warp quant, FP32+FP16 accum (CUDA 12.8+) |
| sm121 | DGX Spark | SageAttention 2++ (CUDA) | Per-warp quantization |

**TORCH_CUDA_ARCH_LIST:** `7.0;7.5;8.0;8.6;8.7;8.9;9.0;10.0;12.0;12.1`

### SageAttention 2++ Features (CUDA 12.8+)

When using CUDA 12.8 or higher:
- **sm89** (RTX 40xx/50xx): Uses FP32+FP16 accumulation (faster than FP32+FP32)
- **sm120/sm121** (B200/DGX Spark): Uses FP32+FP16 accumulation with per-warp quantization

---

## 🚀 SageAttention3 Build Matrix

### Requirements (STRICT)

| Component | Minimum Version | Notes |
|-----------|----------------|-------|
| Python | 3.9+ (3.13+ recommended) | Setup allows 3.9+, docs recommend 3.13+ |
| PyTorch | **2.8.0+** | Hard requirement |
| CUDA | **12.8+** | Hard requirement (verified in setup.py) |
| GPUs | **Blackwell only** | sm100 (B100/B200) or sm120 (B200) |

### Potential Builds (Commented out in docker-bake.hcl)

To enable SageAttention3 builds, you would need to create `dockerfile.builder.sage3.linux` and uncomment targets:

| Target Name | Python | PyTorch | CUDA | Architectures | Wheel Example |
|-------------|--------|---------|------|---------------|---------------|
| `linux-sage3-pytorch28-cu128-python310` | 3.10 | 2.8.0 | 12.8.1 | sm100, sm120 | `sageattn3-1.0.0-280.128-cp310-cp310-linux_x86_64.whl` |
| `linux-sage3-pytorch28-cu128-python311` | 3.11 | 2.8.0 | 12.8.1 | sm100, sm120 | `sageattn3-1.0.0-280.128-cp311-cp311-linux_x86_64.whl` |
| `linux-sage3-pytorch28-cu128-python312` | 3.12 | 2.8.0 | 12.8.1 | sm100, sm120 | `sageattn3-1.0.0-280.128-cp312-cp312-linux_x86_64.whl` |
| `linux-sage3-pytorch28-cu129-python312` | 3.12 | 2.8.0 | 12.9.1 | sm100, sm120 | `sageattn3-1.0.0-280.129-cp312-cp312-linux_x86_64.whl` |

**TORCH_CUDA_ARCH_LIST:** `10.0;12.0`

### GPU Architecture Support

| Compute Capability | GPUs | Technology |
|-------------------|------|------------|
| sm100 | B100/B200 | FP4 Microscaling |
| sm120 | B200 | FP4 Microscaling with mxfp4/nvfp4 |

### Limitations

- ✅ **Works well:** Video generation (CogVideoX-2B, HunyuanVideo, Mochi), Image generation (Flux, SD3.5)
- ⚠️ **May need hybrid approach:** Other models (use SageAttention2++ at first/last timesteps, SageAttention3 for middle)

---

## 📋 Quick Build Commands

### Build Single Configuration
```bash
# Default (PyTorch 2.8.0 + CUDA 12.9.1 + Python 3.12)
docker buildx bake

# Specific configuration
docker buildx bake linux-sage2-pytorch27-cu128-python310
```

### Build by Group
```bash
# All PyTorch 2.6 builds (4 Python versions)
docker buildx bake pytorch26

# All PyTorch 2.7 builds (3 Python versions)
docker buildx bake pytorch27

# All PyTorch 2.8 builds (3 Python versions)
docker buildx bake pytorch28

# All Python 3.10 builds (3 PyTorch versions)
docker buildx bake python310

# All Python 3.11 builds (3 PyTorch versions)
docker buildx bake python311

# All Python 3.12 builds (3 PyTorch versions)
docker buildx bake python312

# Latest stable for each PyTorch version (3 wheels)
docker buildx bake stable

# All SageAttention 2/2++ wheels (10 wheels total)
docker buildx bake sage2-all
```

### Legacy Aliases
```bash
# Backward compatible (builds 2 wheels: PyTorch 2.7 + 2.8)
docker buildx bake all
docker buildx bake linux
```

### Test Builds
```bash
# Test specific build
docker buildx bake test-linux-sage2-pytorch28-cu129-python312

# Test all
docker buildx bake test-all
```

---

## 🎯 Complete Build Matrix Summary

### Total Wheel Combinations Available

| Package | Combinations | Python Versions | PyTorch Versions | CUDA Versions |
|---------|-------------|-----------------|------------------|---------------|
| **SageAttention 2/2++** | **10** | 3.9, 3.10, 3.11, 3.12 | 2.6.0, 2.7.0, 2.8.0 | 12.6, 12.8, 12.9 |
| **SageAttention3** | **0** (not configured) | 3.9+ (3.13+ rec) | 2.8.0+ | 12.8+ only |

### GPU Coverage

| GPU Generation | Compute Capability | SageAttention 2/2++ | SageAttention3 |
|----------------|-------------------|---------------------|----------------|
| Volta | sm70 | ✅ (Triton) | ❌ |
| Turing | sm75 | ✅ (Triton) | ❌ |
| Ampere | sm80, sm86, sm87 | ✅ (CUDA) | ❌ |
| Ada Lovelace | sm89 | ✅ (CUDA, 2++) | ❌ |
| Hopper | sm90 | ✅ (CUDA) | ❌ |
| Blackwell | sm100, sm120, sm121 | ✅ (CUDA, 2++) | ✅ (FP4) |

### Wheel Distribution Strategy

**Recommended distribution:**
1. **SageAttention 2/2++** (10 wheels): General purpose, all GPUs
2. **SageAttention3** (future): Blackwell-only, maximum performance

**File size optimization:**
- All wheels include 10 GPU architectures (sm70-sm121)
- Each architecture adds ~5-10 MB
- Total wheel size: ~50-100 MB per wheel

---

## 🔧 Adding New Combinations

To add new build combinations, edit `docker-bake.hcl`:

### Example: Add PyTorch 2.9 + CUDA 13.0 + Python 3.13

```hcl
target "linux-sage2-pytorch29-cu130-python313" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "13.0.0"
    PYTHON_VERSION = "3.13"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.9.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}
```

### Architecture List Options

- **TORCH_CUDA_ARCH_LIST**: Standard (5 archs) - `8.0;8.6;8.9;9.0;12.0`
- **TORCH_CUDA_ARCH_LIST_EXTENDED**: All GPUs (10 archs) - `7.0;7.5;8.0;8.6;8.7;8.9;9.0;10.0;12.0;12.1`
- **TORCH_CUDA_ARCH_LIST_BLACKWELL**: Blackwell only (2 archs) - `10.0;12.0`

---

## 📚 References

- [SageAttention Paper](https://arxiv.org/abs/2505.11594)
- [SageAttention3 README](sageattention3_blackwell/README.md)
- [Docker Bake Configuration](docker-bake.hcl)
- [PEP 427 - Wheel Binary Package Format](https://peps.python.org/pep-0427/)
