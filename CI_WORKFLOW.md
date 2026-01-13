# CI/CD Workflow Documentation

This document explains the GitHub Actions workflows for building and distributing SageAttention wheels.

## 📋 Available Workflows

### 1. **build-wheels-linux.yml** (Recommended - New)

**Platform:** Linux (Ubuntu with Docker Buildx)

**Purpose:** Flexible matrix-based builds for Linux wheels supporting all Python/PyTorch/CUDA combinations with consistent PEP 427 wheel naming.

**Features:**
- ✅ Dynamic build matrix generation
- ✅ Multiple build profiles (stable, full, per-version)
- ✅ Consistent PEP 427 compliant wheel naming
- ✅ Automatic version extraction and validation
- ✅ GitHub Releases integration for tags
- ✅ Comprehensive build summaries

**Triggers:**
- **Push to main:** Builds `stable` profile (3 wheels)
- **Pull requests:** Builds `default` profile (1 wheel)
- **Git tags (v*):** Builds `sage2-all` profile (10 wheels) + creates release
- **Manual dispatch:** Choose any build profile

**Build Profiles:**

| Profile | Description | Wheel Count | Use Case |
|---------|-------------|-------------|----------|
| `default` | Single latest build | 1 | PR testing |
| `stable` | Latest Python for each PyTorch | 3 | Regular releases |
| `pytorch26` | All Python for PyTorch 2.6 | 4 | Version-specific |
| `pytorch27` | All Python for PyTorch 2.7 | 3 | Version-specific |
| `pytorch28` | All Python for PyTorch 2.8 | 3 | Version-specific |
| `python310` | All PyTorch for Python 3.10 | 3 | Version-specific |
| `python311` | All PyTorch for Python 3.11 | 3 | Version-specific |
| `python312` | All PyTorch for Python 3.12 | 3 | Version-specific |
| `sage2-all` | All combinations | 10 | Full distribution |

**Manual Workflow Dispatch:**
```bash
# Via GitHub UI: Actions → Build SageAttention Wheels (Matrix) → Run workflow
# Select build_profile: stable, pytorch28, sage2-all, etc.
```

---

### 2. **build-wheels-windows.yml** (Recommended - New)

**Platform:** Windows (Native MSVC + CUDA Toolkit)

**Purpose:** Flexible matrix-based builds for Windows wheels with identical build profiles and naming as Linux.

**Features:**
- ✅ Same dynamic build matrix as Linux
- ✅ Same build profiles (stable, pytorch26/27/28, python310/311/312, sage2-all)
- ✅ Consistent PEP 427 wheel naming: `win_amd64` instead of `linux_x86_64`
- ✅ Native Windows builds using MSVC compiler
- ✅ CUDA Toolkit installation via Jimver/cuda-toolkit
- ✅ Automatic release uploads (appends to Linux release)

**Wheel Naming:**
```
sageattention-{version}-{torch}.{cuda}-cp{python}-cp{python}-win_amd64.whl
```

**Examples:**
```bash
sageattention-2.2.0-280.129-cp312-cp312-win_amd64.whl  # Windows
sageattention-2.2.0-280.129-cp312-cp312-linux_x86_64.whl  # Linux (same versions)
```

---

### 3. **build.yml** (Legacy)

**Purpose:** Original workflow with fixed build matrix.

**Status:** ⚠️ Deprecated - Use `build-wheels-linux.yml` and `build-wheels-windows.yml` instead

**Differences:**
- Hardcoded 2 build combinations
- Mixed platform builds in one workflow
- Less flexible matrix
- Legacy naming scheme

---

## 🎯 Wheel Naming Convention

All workflows produce **PEP 427 compliant** wheels with **consistent naming across platforms**:

```
sageattention-{version}-{build_tag}-{python}-{abi}-{platform}.whl
```

**Platform Tags:**
- Linux: `linux_x86_64`
- Windows: `win_amd64`

### Components

| Component | Format | Example | Description |
|-----------|--------|---------|-------------|
| `{version}` | Semantic version | `2.2.0` | SageAttention package version |
| `{build_tag}` | `{torch}.{cuda}` | `280.129` | PyTorch 2.8.0 + CUDA 12.9 |
| `{python}` | `cp{version}` | `cp312` | Python 3.12 |
| `{abi}` | `cp{version}` | `cp312` | CPython ABI tag |
| `{platform}` | Platform tag | `linux_x86_64` | Linux x86_64 |

### Examples

```bash
# Linux wheels
sageattention-2.2.0-260.126-cp39-cp39-linux_x86_64.whl   # PyTorch 2.6.0 + CUDA 12.6 + Python 3.9
sageattention-2.2.0-270.128-cp311-cp311-linux_x86_64.whl # PyTorch 2.7.0 + CUDA 12.8 + Python 3.11
sageattention-2.2.0-280.129-cp312-cp312-linux_x86_64.whl # PyTorch 2.8.0 + CUDA 12.9 + Python 3.12

# Windows wheels (same version tags, different platform)
sageattention-2.2.0-260.126-cp39-cp39-win_amd64.whl      # PyTorch 2.6.0 + CUDA 12.6 + Python 3.9
sageattention-2.2.0-270.128-cp311-cp311-win_amd64.whl    # PyTorch 2.7.0 + CUDA 12.8 + Python 3.11
sageattention-2.2.0-280.129-cp312-cp312-win_amd64.whl    # PyTorch 2.8.0 + CUDA 12.9 + Python 3.12
```

### Build Tag Decoding

| Build Tag | PyTorch | CUDA | Full Versions |
|-----------|---------|------|---------------|
| `260.126` | 2.6 | 12.6 | PyTorch 2.6.0 + CUDA 12.6.1 |
| `270.128` | 2.7 | 12.8 | PyTorch 2.7.0 + CUDA 12.8.1 |
| `280.129` | 2.8 | 12.9 | PyTorch 2.8.0 + CUDA 12.9.1 |

---

## 🔄 Workflow Execution Flow

### Pull Request Flow (Both Linux + Windows in Parallel)
```
PR opened/updated
  ↓
┌─────────────────────┬─────────────────────┐
│ Linux Workflow      │ Windows Workflow    │
├─────────────────────┼─────────────────────┤
│ validate            │ validate            │
│ ↓                   │ ↓                   │
│ generate-matrix     │ generate-matrix     │
│ (default → 1 build) │ (default → 1 build) │
│ ↓                   │ ↓                   │
│ build-wheels        │ build-wheels        │
│ ├─ Docker Bake      │ ├─ Native MSVC      │
│ ├─ Verify naming    │ ├─ Verify naming    │
│ └─ Test wheel       │ └─ Test wheel       │
│ ↓                   │ ↓                   │
│ build-summary       │ build-summary       │
└─────────────────────┴─────────────────────┘
```

### Main Branch Push Flow (Both Platforms)
```
Push to main
  ↓
┌─────────────────────┬─────────────────────┐
│ Linux Workflow      │ Windows Workflow    │
├─────────────────────┼─────────────────────┤
│ validate            │ validate            │
│ ↓                   │ ↓                   │
│ generate-matrix     │ generate-matrix     │
│ (stable → 3 builds) │ (stable → 3 builds) │
│ ↓                   │ ↓                   │
│ build-wheels        │ build-wheels        │
│ ├─ 3 wheels (Linux) │ ├─ 3 wheels (Win)   │
│ ├─ Verify naming    │ ├─ Verify naming    │
│ └─ Test wheels      │ └─ Test wheels      │
│ ↓                   │ ↓                   │
│ build-summary       │ build-summary       │
└─────────────────────┴─────────────────────┘

Total: 6 wheels (3 Linux + 3 Windows)
```

### Tag Push Flow (Release - Both Platforms)
```
Push tag v*
  ↓
┌─────────────────────────┬─────────────────────────┐
│ Linux Workflow          │ Windows Workflow        │
├─────────────────────────┼─────────────────────────┤
│ validate                │ validate                │
│ ↓                       │ ↓                       │
│ generate-matrix         │ generate-matrix         │
│ (sage2-all → 10 builds) │ (sage2-all → 10 builds) │
│ ↓                       │ ↓                       │
│ build-wheels            │ build-wheels            │
│ ├─ 10 wheels (Linux)    │ ├─ 10 wheels (Windows)  │
│ ├─ Verify naming        │ ├─ Verify naming        │
│ └─ Test wheels          │ └─ Test wheels          │
│ ↓                       │ ↓                       │
│ build-summary           │ build-summary           │
│ ↓                       │ ↓                       │
│ release                 │ release                 │
│ ├─ Create GitHub Release│ └─ Append to release    │
│ └─ Upload 10 wheels     │   └─ Upload 10 wheels   │
└─────────────────────────┴─────────────────────────┘

Total: 20 wheels in single release (10 Linux + 10 Windows)
```

---

## 🚀 Usage Examples

### Creating a Release

```bash
# 1. Update version in pyproject.toml
vim pyproject.toml  # Update version = "2.2.1"

# 2. Commit and push
git add pyproject.toml
git commit -m "Bump version to 2.2.1"
git push origin main

# 3. Create and push tag
git tag -a v2.2.1 -m "Release v2.2.1"
git push origin v2.2.1

# 4. Workflow automatically:
#    - Builds all 10 wheel combinations
#    - Creates GitHub Release
#    - Uploads wheels to release
```

### Manual Build for Specific Version

```bash
# Via GitHub UI:
# 1. Go to Actions tab
# 2. Select "Build SageAttention Wheels (Matrix)"
# 3. Click "Run workflow"
# 4. Select branch: main
# 5. Choose build_profile: pytorch28 (for all Python 3.10/3.11/3.12 wheels with PyTorch 2.8)
# 6. Click "Run workflow"
```

### Testing PR Changes

```bash
# 1. Create PR
gh pr create --title "Add feature X" --body "Description"

# 2. Workflow automatically runs with 'default' profile
#    - Builds 1 wheel (latest stable: PyTorch 2.8.0 + CUDA 12.9 + Python 3.12)
#    - Tests the wheel
#    - Uploads artifact

# 3. Download artifact from Actions tab for manual testing
```

---

## 🔍 Wheel Naming Validation

The workflow includes automatic validation to ensure all wheels follow the PEP 427 naming convention.

### Validation Checks

1. **Pattern matching:** Verifies regex pattern
2. **Version extraction:** Extracts and validates version components
3. **Consistency:** Ensures build tag matches actual PyTorch/CUDA versions

### Example Validation Output

```
Checking wheel: sageattention-2.2.0-280.129-cp312-cp312-linux_x86_64.whl
  ✅ SageAttention version: 2.2.0
  ✅ PyTorch version tag: 280 (2.8.0)
  ✅ CUDA version tag: 129 (12.9)
  ✅ Python version: 312 (3.12)
```

---

## 📦 Artifact Management

### Retention Policy

- **Pull Requests:** 7 days
- **Main branch:** 7 days
- **Releases:** Permanent (attached to GitHub Release)

### Download Artifacts

```bash
# Using gh CLI
gh run download <run-id>

# Or via GitHub UI:
# Actions → Select workflow run → Artifacts section
```

---

## 🔧 Maintenance

### Adding New PyTorch/CUDA Combinations

1. **Update docker-bake.hcl:**
   ```hcl
   target "linux-sage2-pytorch29-cu130-python312" {
     # ... configuration
   }
   ```

2. **Update CI workflow:**
   Edit `.github/workflows/build-wheels-matrix.yml`:
   ```bash
   # Add to all_builds array in generate-matrix job
   "linux-sage2-pytorch29-cu130-python312|3.12|2.9.0|13.0|PyTorch 2.9.0 + CUDA 13.0 + Python 3.12"
   ```

3. **Update documentation:**
   - `BUILD_MATRIX.md`: Add new combination to tables
   - `CLAUDE.md`: Update version ranges

### Troubleshooting

**Issue:** Wheel naming doesn't match expected pattern
- **Cause:** Build tag generation in setup.py
- **Fix:** Ensure `setup.py` generates tags in `{torch}.{cuda}` format

**Issue:** Matrix generation fails
- **Cause:** Invalid profile name or syntax error in bash array
- **Fix:** Check `generate-matrix` job logs, validate bash syntax

**Issue:** Wheels not uploaded to release
- **Cause:** Tag doesn't match `v*` pattern or release job permissions
- **Fix:** Ensure tag starts with `v` and workflow has `contents: write` permission

---

## 🎯 Best Practices

### For Development
1. **PR Testing:** Let default profile run (1 wheel)
2. **Pre-merge:** Manually dispatch `stable` profile to test main builds
3. **Merge:** Stable builds run automatically

### For Releases
1. **Version Bump:** Update `pyproject.toml` first
2. **Tag Format:** Always use `v` prefix (e.g., `v2.2.0`)
3. **Wait for CI:** Don't create release manually, let workflow handle it
4. **Verify:** Check release has all 10 wheels before announcing

### For Debugging
1. **Check Artifacts:** Download and inspect wheel names
2. **Review Logs:** Build summary shows exact versions in table
3. **Test Locally:** Use `docker buildx bake` with same target names

---

## 📊 Workflow Comparison

| Feature | Linux Workflow | Windows Workflow | build.yml (Legacy) |
|---------|---------------|------------------|-------------------|
| **Platform** | 🐧 Linux | 🪟 Windows | Mixed |
| **Build method** | Docker Buildx | Native MSVC | Mixed |
| **Build profiles** | ✅ 8 profiles | ✅ 8 profiles | ❌ Fixed |
| **Dynamic matrix** | ✅ Yes | ✅ Yes | ❌ No |
| **Wheel naming** | ✅ PEP 427 | ✅ PEP 427 | ⚠️ Partial |
| **Max wheels** | ✅ 10 | ✅ 10 | ❌ 2 |
| **Manual dispatch** | ✅ Yes | ✅ Yes | ❌ No |
| **Release automation** | ✅ Creates release | ✅ Appends wheels | ⚠️ Partial |
| **Summary quality** | ✅ Detailed table | ✅ Detailed table | ⚠️ Basic |
| **Naming consistency** | ✅ 100% | ✅ 100% | ❌ No |
| **Platform tag** | `linux_x86_64` | `win_amd64` | Varies |
| **Recommended** | ✅ **Yes** | ✅ **Yes** | ❌ Deprecated |

### Total Wheel Capacity

| Trigger | Linux | Windows | Total |
|---------|-------|---------|-------|
| **PR** (default) | 1 | 1 | **2 wheels** |
| **Main** (stable) | 3 | 3 | **6 wheels** |
| **Tag** (sage2-all) | 10 | 10 | **20 wheels** |
| **Manual** (sage2-all) | 10 | 10 | **20 wheels** |

---

## 🔗 Related Documentation

- [BUILD_MATRIX.md](BUILD_MATRIX.md) - Complete build matrix details
- [docker-bake.hcl](docker-bake.hcl) - Docker build configuration
- [CLAUDE.md](CLAUDE.md) - Project overview and build commands
- [PEP 427](https://peps.python.org/pep-0427/) - Wheel binary package format
