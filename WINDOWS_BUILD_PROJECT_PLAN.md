# Windows Build Integration Project Plan

## Overview

This project plan outlines the integration of Windows build support into the SageAttention fork, bringing the same level of multi-platform support as the original `woct0rdho/SageAttention` repository while maintaining our superior Docker-based build system and PEP 427 compliant wheel naming conventions.

## Current State Analysis

### Your Fork (Linux-only)
- **Build System**: Optimized Docker multi-stage builds with BuildKit caching
- **Wheel Naming**: PEP 427 compliant (`sageattention-2.2.0-280.129-cp312-cp312-linux_x86_64.whl`)
- **Supported Versions**: Python 3.12, PyTorch 2.7.0/2.8.0, CUDA 12.8.1/12.9.1
- **Architecture**: Clean docker-bake.hcl with clear naming conventions

### Original Windows Fork
- **Build System**: GitHub Actions with direct Windows compilation
- **Wheel Naming**: Non-PEP 427 (`sageattention-2.2.0+cu128torch2.8.0.post2-cp39-abi3-win_amd64.whl`)
- **Supported Versions**: Python 3.9+, PyTorch 2.5.1-2.8.0, CUDA 12.4-12.8
- **Architecture**: Direct Windows builds without containerization

## Project Objectives

1. **Maintain Architectural Excellence**: Keep Docker-based multi-stage builds
2. **Standards Compliance**: Use PEP 427 wheel naming across all platforms
3. **Version Parity**: Match or exceed original Windows fork's version support
4. **Consistency**: Unified build system for Linux and Windows
5. **Quality**: Automated testing and validation

## Implementation Plan

### Phase 1: Create Windows Docker Infrastructure
**Duration**: 3-4 days
**Objective**: Establish Docker-based Windows build environment

#### Tasks:
1. **Create `dockerfile.builder.windows`**
   - Base on Windows Server Core with CUDA support
   - Implement multi-stage build pattern:
     - `runtime`: System dependencies + Python + PyTorch
     - `builder`: + SageAttention compilation
     - `wheel`: Wheel extraction
     - `test`: Runtime verification
   - Configure MSVC build tools and CUDA toolkit
   - Optimize for BuildKit caching

2. **Research Windows Container Requirements**
   - Identify base images (`mcr.microsoft.com/windows/servercore:ltsc2022`)
   - Verify CUDA runtime compatibility in Windows containers
   - Test MSVC build tools installation and configuration
   - Document Windows-specific Docker requirements

3. **Adapt Build Scripts for Windows**
   - Modify `setup.py` for Windows CUDA detection
   - Handle Windows path separators and environment variables
   - Ensure CUDA architecture list compatibility
   - Test compilation of CUDA extensions on Windows

**Deliverables**:
- `dockerfile.builder.windows`
- Windows build documentation
- Tested Windows compilation process

### Phase 2: Implement Windows Build Targets in docker-bake.hcl
**Duration**: 2-3 days
**Objective**: Extend build configuration with Windows support

#### Tasks:
1. **Add Windows Build Targets**
   ```hcl
   # Target naming pattern: windows-pytorch{version}-cu{version}-python{version}
   windows-pytorch27-cu128-python39
   windows-pytorch27-cu128-python310
   windows-pytorch27-cu128-python311
   windows-pytorch27-cu128-python312
   windows-pytorch28-cu129-python39
   windows-pytorch28-cu129-python310
   windows-pytorch28-cu129-python311
   windows-pytorch28-cu129-python312
   ```

2. **Create Windows Test Targets**
   - Mirror existing test infrastructure
   - `test-windows-pytorch{version}-cu{version}-python{version}`
   - Validate wheel installation and basic functionality

3. **Update Convenience Groups**
   ```hcl
   group "windows" {
     targets = [/* all Windows builds */]
   }
   group "windows-pytorch27" {
     targets = [/* Windows PyTorch 2.7 builds */]
   }
   group "windows-pytorch28" {
     targets = [/* Windows PyTorch 2.8 builds */]
   }
   ```

4. **Configure Platform-Specific Arguments**
   - Windows container platform: `windows/amd64`
   - TORCH_CUDA_ARCH_LIST: `8.0;8.6;8.9;9.0;12.0`
   - Output path configuration for Windows

**Deliverables**:
- Updated `docker-bake.hcl` with Windows targets
- Windows convenience groups
- Tested build target execution

### Phase 3: Create Windows CI/CD Workflow
**Duration**: 2-3 days
**Objective**: Automated Windows wheel building and testing

#### Tasks:
1. **Create GitHub Actions Workflow**
   - `.github/workflows/build-windows.yml`
   - Windows Server 2022 runners
   - Docker Desktop with Windows containers

2. **Configure Build Matrix**
   ```yaml
   strategy:
     matrix:
       python: [3.9, 3.10, 3.11, 3.12]
       pytorch: [2.7.0, 2.8.0]
       cuda: [12.8.1, 12.9.1]
   ```

3. **Implement Artifact Management**
   - Upload wheels with PEP 427 naming
   - Wheel naming verification: `sageattention-2.2.0-{torch}.{cuda}-cp{python}-cp{python}-win_amd64.whl`
   - Artifact retention and organization

4. **Add Quality Gates**
   - Wheel installation testing in clean environments
   - Import verification (`import sageattention`)
   - Basic functionality tests from `tests/test_sageattn.py`

**Deliverables**:
- Windows CI/CD workflow
- Automated wheel building and testing
- Quality gate implementation

### Phase 4: Testing and Validation
**Duration**: 3-4 days
**Objective**: Comprehensive testing across Windows configurations

#### Tasks:
1. **Local Testing Setup**
   - Test Docker Windows builds locally
   - Verify wheel generation meets PEP 427 standards
   - Installation testing in clean Windows environments

2. **Cross-Platform Validation**
   - Compare Windows vs Linux wheel behavior
   - CUDA kernel loading verification on Windows
   - Performance parity testing (optional)

3. **Compatibility Testing**
   - Python version compatibility (3.9-3.12)
   - PyTorch version compatibility (2.7.0, 2.8.0)
   - Windows version testing (Server 2019/2022, Windows 10/11)

4. **Integration Testing**
   - Run examples from `example/` directory
   - Execute full test suite (`tests/test_sageattn.py`)
   - Memory usage and performance validation

**Deliverables**:
- Comprehensive test results
- Windows compatibility matrix
- Performance benchmarks

### Phase 5: Documentation and Deployment
**Duration**: 1-2 days
**Objective**: Complete integration with documentation

#### Tasks:
1. **Update CLAUDE.md**
   ```markdown
   # Windows Builds
   docker buildx bake --file docker-bake.hcl windows
   docker buildx bake --file docker-bake.hcl windows-pytorch28-cu129-python312
   ```

2. **Update README**
   - Windows installation instructions
   - Supported Windows configurations
   - Troubleshooting section for Windows-specific issues

3. **Release Strategy**
   - Define Windows wheel distribution (GitHub Releases)
   - Version alignment with Linux builds
   - Release automation consideration

4. **Monitoring and Maintenance**
   - Build failure notification setup
   - Update procedures for CUDA/PyTorch versions
   - Windows-specific issue tracking

**Deliverables**:
- Updated documentation
- Release strategy
- Maintenance procedures

## Technical Specifications

### Supported Configurations
| Component | Versions |
|-----------|----------|
| Python | 3.9, 3.10, 3.11, 3.12 |
| PyTorch | 2.7.0, 2.8.0 |
| CUDA | 12.8.1, 12.9.1 |
| Platform | Windows x64 (win_amd64) |
| GPU Architectures | SM 8.0, 8.6, 8.9, 9.0, 12.0 |

### Wheel Naming Convention
```
sageattention-{version}-{pytorch_version}.{cuda_version}-cp{python}-cp{python}-win_amd64.whl

Example:
sageattention-2.2.0-280.129-cp312-cp312-win_amd64.whl
```

### Build Commands
```bash
# All Windows builds
docker buildx bake --file docker-bake.hcl windows

# Specific configuration
docker buildx bake --file docker-bake.hcl windows-pytorch28-cu129-python312

# Test builds
docker buildx bake --file docker-bake.hcl test-windows-pytorch28-cu129-python312
```

## Success Criteria

1. **Functional**: Windows wheels build successfully for all target configurations
2. **Quality**: All wheels pass installation and functionality tests
3. **Standards**: PEP 427 compliant naming maintained across platforms
4. **Automation**: CI/CD pipeline builds and validates Windows wheels automatically
5. **Documentation**: Complete instructions for Windows build usage
6. **Performance**: Windows builds match Linux performance characteristics

## Risk Assessment

### High Risk
- **Windows Container Complexity**: Docker Windows containers are more complex than Linux
- **CUDA Compatibility**: Windows CUDA toolkit installation in containers

### Medium Risk
- **Build Time**: Windows builds typically slower than Linux
- **Testing Coverage**: Limited Windows testing environments

### Low Risk
- **Naming Conflicts**: Well-defined naming convention reduces conflicts
- **Integration Issues**: Following existing patterns minimizes integration risk

## Timeline

**Total Duration**: 2-3 weeks

- **Week 1**: Phases 1-2 (Docker infrastructure and build targets)
- **Week 2**: Phases 3-4 (CI/CD and testing)
- **Week 3**: Phase 5 and buffer time (documentation and deployment)

## Dependencies

- Docker Desktop with Windows containers support
- GitHub Actions Windows runners
- Access to Windows development environment for testing
- CUDA toolkit compatibility verification

## Next Steps

1. Review and approve this project plan
2. Set up development environment with Windows container support
3. Begin Phase 1: Create Windows Docker infrastructure
4. Regular check-ins at end of each phase for plan adjustments