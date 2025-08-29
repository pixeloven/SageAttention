variable "CUDA_VERSION" {
  default = "12.9.1"
}

variable "PYTHON_VERSION" {
  default = "3.12"
}

variable "TORCH_CUDA_ARCH_LIST" {
  default = "7.0;7.5;8.0;8.6;8.9;9.0"
}

variable "BUILD_PLATFORM" {
  default = "linux/amd64"
}

variable "TORCH_MINOR_VERSION" {
  default = "7"
}

variable "TORCH_PATCH_VERSION" {
  default = "0"
}

variable "CUDA_MINOR_VERSION" {
  default = "9"
}

variable "PLATFORM" {
  default = "linux"
}

group "default" {
  targets = ["wheel"]
}

# Build wheel for Linux
target "wheel-linux" {
  dockerfile = "dockerfile.builder"
  target = "sageattention-wheel"
  platforms = ["linux/amd64"]
  output = ["type=local,dest=./wheels"]
  args = {
    CUDA_VERSION = CUDA_VERSION
    PYTHON_VERSION = PYTHON_VERSION
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST
    TORCH_MINOR_VERSION = TORCH_MINOR_VERSION
    TORCH_PATCH_VERSION = TORCH_PATCH_VERSION
    CUDA_SUFFIX = "129"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# Default wheel target (builds for current platform)
target "wheel" {
  dockerfile = "dockerfile.builder"
  target = "sageattention-wheel"
  platforms = [BUILD_PLATFORM]
  output = ["type=local,dest=./wheels"]
  args = {
    CUDA_VERSION = CUDA_VERSION
    PYTHON_VERSION = PYTHON_VERSION
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST
    TORCH_MINOR_VERSION = TORCH_MINOR_VERSION
    TORCH_PATCH_VERSION = TORCH_PATCH_VERSION
    CUDA_SUFFIX = "129"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# Test the built wheel for Linux
target "test-linux" {
  dockerfile = "dockerfile.builder"
  target = "sageattention-test"
  platforms = ["linux/amd64"]
  args = {
    CUDA_VERSION = CUDA_VERSION
    PYTHON_VERSION = PYTHON_VERSION
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST
    TORCH_MINOR_VERSION = TORCH_MINOR_VERSION
    TORCH_PATCH_VERSION = TORCH_PATCH_VERSION
    CUDA_SUFFIX = "129"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# Default test target
target "test" {
  dockerfile = "dockerfile.builder"
  target = "sageattention-test"
  platforms = [BUILD_PLATFORM]
  args = {
    CUDA_VERSION = CUDA_VERSION
    PYTHON_VERSION = PYTHON_VERSION
    TORCH_CUDA_ARCH_LIST = TORCH_CUDA_ARCH_LIST
    TORCH_MINOR_VERSION = TORCH_MINOR_VERSION
    TORCH_PATCH_VERSION = TORCH_PATCH_VERSION
    CUDA_SUFFIX = "129"
  }
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
}

# Multi-platform build group
group "multi-platform" {
  targets = ["wheel-linux"]
} 