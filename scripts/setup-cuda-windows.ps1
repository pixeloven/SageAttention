# CUDA Detection and Setup Script for Windows
# This script detects CUDA installation and configures environment variables

param(
    [string]$CudaVersion = $env:CUDA_VERSION
)

Write-Host "=== CUDA Detection and Setup ==="
Write-Host "Target CUDA Version: $CudaVersion"

# Check for existing CUDA installations
Write-Host "=== Checking CUDA Installations ==="
Write-Host "Standard CUDA Directory:"
if (Test-Path 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA') {
    Get-ChildItem 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA' | Select-Object Name, FullName
    Write-Host "CUDA Version Directories:"
    Get-ChildItem 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*' -ErrorAction SilentlyContinue | Select-Object Name, FullName
} else {
    Write-Host "Standard CUDA directory not found"
}

Write-Host "Chocolatey CUDA packages:"
Get-ChildItem 'C:\ProgramData\chocolatey\lib\cuda*' -ErrorAction SilentlyContinue | Select-Object Name, FullName

# Determine CUDA installation path
Write-Host "=== Determining CUDA Installation Path ==="
$cudaPath = $null
$cudaVersions = @('v12.9', 'v12.8')

foreach ($version in $cudaVersions) {
    $testPath = "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\$version"
    if (Test-Path "$testPath\bin\nvcc.exe") {
        $cudaPath = $testPath
        Write-Host "Found valid CUDA installation at: $testPath"
        break
    }
}

if (-not $cudaPath) {
    Write-Host 'Searching for any CUDA installation...'
    $cudaDirs = Get-ChildItem 'C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v*' -ErrorAction SilentlyContinue
    foreach ($dir in $cudaDirs) {
        if (Test-Path "$($dir.FullName)\bin\nvcc.exe") {
            $cudaPath = $dir.FullName
            Write-Host "Found CUDA installation at: $cudaPath"
            break
        }
    }
}

if (-not $cudaPath) {
    throw 'No valid CUDA installation found with nvcc.exe'
}

# Set CUDA_HOME environment variable
Write-Host "Setting CUDA_HOME to: $cudaPath"
[Environment]::SetEnvironmentVariable('CUDA_HOME', $cudaPath, 'Machine')

# Update PATH with CUDA binary directory
Write-Host "=== Updating PATH ==="
if ($cudaPath -and (Test-Path "$cudaPath\bin")) {
    $cudaBin = "$cudaPath\bin"
    Write-Host "Using CUDA bin directory: $cudaBin"
    
    $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
    if ($currentPath -notlike "*$cudaBin*") {
        $newPath = "$cudaBin;$currentPath"
        [Environment]::SetEnvironmentVariable('PATH', $newPath, 'Machine')
        Write-Host "Added CUDA bin to PATH"
    } else {
        Write-Host "CUDA bin already in PATH"
    }
} else {
    throw "CUDA bin directory not found at: $cudaPath\bin"
}

# Set process environment variables for immediate use
$machineHome = [Environment]::GetEnvironmentVariable('CUDA_HOME', 'Machine')
$machinePath = [Environment]::GetEnvironmentVariable('PATH', 'Machine')
Write-Host "Setting process environment - CUDA_HOME: $machineHome"
[Environment]::SetEnvironmentVariable('CUDA_HOME', $machineHome, 'Process')
[Environment]::SetEnvironmentVariable('PATH', $machinePath, 'Process')

Write-Host "=== CUDA Setup Complete ==="