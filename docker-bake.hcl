# SageAttention Docker Bake Configuration - Comprehensive Build Matrix
# Supports SageAttention v2.2.0 (all GPUs) and SageAttention3 v1.0.0 (Blackwell only)
#
# Naming convention: {platform}-{package}-{pytorch}-{cuda}-{python}
#   - platform: linux
#   - package: sage2 (SageAttention 2/2++) or sage3 (SageAttention3)
#   - pytorch: pytorch26, pytorch27, pytorch28
#   - cuda: cu126, cu128, cu129
#   - python: python39, python310, python311, python312, python313
#
# Wheel naming (PEP 427):
#   sageattention-2.2.0-{torch}.{cuda}-cp{py}-cp{py}-linux_x86_64.whl
#   sageattn3-1.0.0-{torch}.{cuda}-cp{py}-cp{py}-linux_x86_64.whl

# ============================================================================
# Build Configuration Variables
# ============================================================================

variable "PYTHON_VERSION" {
  default = "3.12"
}

variable "CUDA_VERSION" {
  default = "12.9.1"
}

variable "TORCH_VERSION" {
  default = "2.8.0"
}

# Standard arch list for SageAttention 2/2++
# Covers: A100/RTX30xx (sm80/86), RTX40xx/50xx (sm89), H100 (sm90), B200 (sm120)
variable "TORCH_CUDA_ARCH_LIST" {
  default = "8.0;8.6;8.9;9.0;12.0"
}

# Extended arch list including older GPUs
# Adds: V100 (sm70), RTX20xx (sm75), AGX Orin (sm87), B100 (sm100), DGX Spark (sm121)
variable "TORCH_CUDA_ARCH_LIST_EXTENDED" {
  default = "7.0;7.5;8.0;8.6;8.7;8.9;9.0;10.0;12.0;12.1"
}

# Blackwell-only arch list for SageAttention3
variable "TORCH_CUDA_ARCH_LIST_BLACKWELL" {
  default = "10.0;12.0"
}

# ============================================================================
# SageAttention 2/2++ Builds (Main Package)
# ============================================================================

# ---------- PyTorch 2.6 + CUDA 12.6 ----------

target "linux-sage2-pytorch26-cu126-python39" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.6.1"
    PYTHON_VERSION = "3.9"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.6.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch26-cu126-python310" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.6.1"
    PYTHON_VERSION = "3.10"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.6.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch26-cu126-python311" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.6.1"
    PYTHON_VERSION = "3.11"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.6.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch26-cu126-python312" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.6.1"
    PYTHON_VERSION = "3.12"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.6.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# ---------- PyTorch 2.7 + CUDA 12.8 ----------

target "linux-sage2-pytorch27-cu128-python310" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.8.1"
    PYTHON_VERSION = "3.10"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.7.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch27-cu128-python311" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.8.1"
    PYTHON_VERSION = "3.11"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.7.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch27-cu128-python312" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.8.1"
    PYTHON_VERSION = "3.12"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.7.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# ---------- PyTorch 2.8 + CUDA 12.9 ----------

target "linux-sage2-pytorch28-cu129-python310" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.9.1"
    PYTHON_VERSION = "3.10"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.8.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch28-cu129-python311" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.9.1"
    PYTHON_VERSION = "3.11"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.8.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "linux-sage2-pytorch28-cu129-python312" {
  dockerfile = "dockerfile.builder.linux"
  target = "wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./dist"]
  args = {
    CUDA_VERSION = "12.9.1"
    PYTHON_VERSION = "3.12"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.8.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# ============================================================================
# SageAttention3 Builds (Blackwell-only, requires CUDA 12.8+, PyTorch 2.8+)
# ============================================================================
# Note: These would require a separate Dockerfile that builds from
# sageattention3_blackwell/ directory. Currently not implemented.

# target "linux-sage3-pytorch28-cu128-python310" {
#   dockerfile = "dockerfile.builder.sage3.linux"
#   target = "wheel"
#   platforms = ["linux/amd64"]
#   output = ["type=local,dest=./dist"]
#   args = {
#     CUDA_VERSION = "12.8.1"
#     PYTHON_VERSION = "3.10"
#     TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_BLACKWELL
#     TORCH_VERSION = "2.8.0"
#   }
#   cache-from = ["type=gha"]
#   cache-to = ["type=gha,mode=max"]
# }

# ============================================================================
# Test Targets
# ============================================================================

target "test-linux-sage2-pytorch27-cu128-python312" {
  dockerfile = "dockerfile.builder.linux"
  target = "test"
  platforms = ["linux/amd64"]
  args = {
    CUDA_VERSION = "12.8.1"
    PYTHON_VERSION = "3.12"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.7.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

target "test-linux-sage2-pytorch28-cu129-python312" {
  dockerfile = "dockerfile.builder.linux"
  target = "test"
  platforms = ["linux/amd64"]
  args = {
    CUDA_VERSION = "12.9.1"
    PYTHON_VERSION = "3.12"
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST_EXTENDED
    TORCH_VERSION = "2.8.0"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# ============================================================================
# Convenience Groups
# ============================================================================

group "default" {
  targets = ["linux-sage2-pytorch28-cu129-python312"]
}

# Build all SageAttention2/2++ wheels
group "sage2-all" {
  targets = [
    # PyTorch 2.6 + CUDA 12.6
    "linux-sage2-pytorch26-cu126-python39",
    "linux-sage2-pytorch26-cu126-python310",
    "linux-sage2-pytorch26-cu126-python311",
    "linux-sage2-pytorch26-cu126-python312",
    # PyTorch 2.7 + CUDA 12.8
    "linux-sage2-pytorch27-cu128-python310",
    "linux-sage2-pytorch27-cu128-python311",
    "linux-sage2-pytorch27-cu128-python312",
    # PyTorch 2.8 + CUDA 12.9
    "linux-sage2-pytorch28-cu129-python310",
    "linux-sage2-pytorch28-cu129-python311",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}

# By PyTorch version
group "pytorch26" {
  targets = [
    "linux-sage2-pytorch26-cu126-python39",
    "linux-sage2-pytorch26-cu126-python310",
    "linux-sage2-pytorch26-cu126-python311",
    "linux-sage2-pytorch26-cu126-python312",
  ]
}

group "pytorch27" {
  targets = [
    "linux-sage2-pytorch27-cu128-python310",
    "linux-sage2-pytorch27-cu128-python311",
    "linux-sage2-pytorch27-cu128-python312",
  ]
}

group "pytorch28" {
  targets = [
    "linux-sage2-pytorch28-cu129-python310",
    "linux-sage2-pytorch28-cu129-python311",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}

# By Python version
group "python310" {
  targets = [
    "linux-sage2-pytorch26-cu126-python310",
    "linux-sage2-pytorch27-cu128-python310",
    "linux-sage2-pytorch28-cu129-python310",
  ]
}

group "python311" {
  targets = [
    "linux-sage2-pytorch26-cu126-python311",
    "linux-sage2-pytorch27-cu128-python311",
    "linux-sage2-pytorch28-cu129-python311",
  ]
}

group "python312" {
  targets = [
    "linux-sage2-pytorch26-cu126-python312",
    "linux-sage2-pytorch27-cu128-python312",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}

# Latest stable combination for each PyTorch version
group "stable" {
  targets = [
    "linux-sage2-pytorch26-cu126-python312",
    "linux-sage2-pytorch27-cu128-python312",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}

# All tests
group "test-all" {
  targets = [
    "test-linux-sage2-pytorch27-cu128-python312",
    "test-linux-sage2-pytorch28-cu129-python312",
  ]
}

# Legacy aliases (backward compatibility)
group "linux" {
  targets = [
    "linux-sage2-pytorch27-cu128-python312",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}

group "all" {
  targets = [
    "linux-sage2-pytorch27-cu128-python312",
    "linux-sage2-pytorch28-cu129-python312",
  ]
}
