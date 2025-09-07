# CUDA Detection and Build Environment Setup
Write-Host 'Build Configuration:'
Write-Host "  TORCH_VERSION: $env:TORCH_VERSION"
Write-Host "  PYTHON_VERSION: $env:PYTHON_VERSION"
Write-Host "  CUDA_VERSION: $env:CUDA_VERSION"
Write-Host "  TORCH_CUDA_ARCH_LIST: $env:TORCH_CUDA_ARCH_LIST"

Write-Host '=== CUDA Detection ==='
$cudaHome = $null

# Try getting CUDA_HOME from machine environment first
$envCudaHome = [Environment]::GetEnvironmentVariable('CUDA_HOME', 'Machine')
if ($envCudaHome -and (Test-Path "$envCudaHome\bin\nvcc.exe")) {
    $cudaHome = $envCudaHome
    Write-Host "Found CUDA via CUDA_HOME: $cudaHome"
} else {
    # Search common CUDA installation paths
    $cudaVersions = @('v12.9', 'v12.8', 'v12.7', 'v12.6', 'v12.5')
    $basePaths = @(
        'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA',
        'C:\ProgramData\chocolatey\lib\cuda\tools\cuda'
    )
    
    Write-Host 'Searching for CUDA installation...'
    :searchLoop foreach ($basePath in $basePaths) {
        if (Test-Path $basePath) {
            foreach ($version in $cudaVersions) {
                $testPath = Join-Path $basePath $version
                if (Test-Path "$testPath\bin\nvcc.exe") {
                    $cudaHome = $testPath
                    Write-Host "Found CUDA at: $cudaHome"
                    break searchLoop
                }
            }
        }
    }
    
    # Final fallback - search anywhere for nvcc.exe
    if (-not $cudaHome) {
        Write-Host 'Searching for any nvcc.exe installation...'
        $nvccPath = Get-ChildItem -Path 'C:\' -Recurse -Name 'nvcc.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($nvccPath) {
            $cudaHome = Split-Path (Split-Path $nvccPath -Parent) -Parent
            Write-Host "Found CUDA via nvcc search: $cudaHome"
        }
    }
}

if ($cudaHome -and (Test-Path "$cudaHome\bin\nvcc.exe")) {
    Write-Host "Using CUDA installation: $cudaHome"
    & "$cudaHome\bin\nvcc.exe" --version
    
    Write-Host 'Creating nvcc hard link for compatibility...'
    try {
        New-Item -ItemType HardLink -Path "$cudaHome\bin\nvcc" -Target "$cudaHome\bin\nvcc.exe" -Force -ErrorAction SilentlyContinue
        Write-Host 'Successfully created nvcc hard link'
    } catch {
        Write-Host 'Hard link creation failed, trying copy...'
        Copy-Item "$cudaHome\bin\nvcc.exe" "$cudaHome\bin\nvcc" -Force -ErrorAction SilentlyContinue
    }
    
    # Set CUDA_HOME for this process and future processes
    [Environment]::SetEnvironmentVariable('CUDA_HOME', $cudaHome, 'Process')
    [Environment]::SetEnvironmentVariable('CUDA_HOME', $cudaHome, 'Machine')
    
    Write-Host "CUDA_HOME set to: $cudaHome"
} else {
    Write-Host 'WARNING: No CUDA installation found with nvcc.exe'
    Write-Host 'Build will continue but CUDA extensions may not compile properly'
    Write-Host 'Available CUDA-related directories:'
    Get-ChildItem 'C:\Program Files\NVIDIA*' -ErrorAction SilentlyContinue | Select-Object Name, FullName
    Get-ChildItem 'C:\ProgramData\chocolatey\lib\cuda*' -ErrorAction SilentlyContinue | Select-Object Name, FullName
}