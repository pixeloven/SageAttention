# Get CUDA_HOME from machine environment and create nvcc alias
$cudaHome = [Environment]::GetEnvironmentVariable('CUDA_HOME', 'Machine')

Write-Host 'Build Configuration:'
Write-Host "  TORCH_VERSION: $env:TORCH_VERSION"
Write-Host "  PYTHON_VERSION: $env:PYTHON_VERSION"
Write-Host "  CUDA_VERSION: $env:CUDA_VERSION"
Write-Host "  TORCH_CUDA_ARCH_LIST: $env:TORCH_CUDA_ARCH_LIST"
Write-Host "  CUDA_HOME: $cudaHome"

Write-Host 'Checking CUDA compiler accessibility...'
if ($cudaHome -and (Test-Path "$cudaHome\bin\nvcc.exe")) {
    Write-Host "nvcc.exe found at: $cudaHome\bin\nvcc.exe"
    & "$cudaHome\bin\nvcc.exe" --version
    
    Write-Host 'Creating nvcc hard link for compatibility...'
    try {
        New-Item -ItemType HardLink -Path "$cudaHome\bin\nvcc" -Target "$cudaHome\bin\nvcc.exe" -Force
        Write-Host 'Successfully created nvcc hard link'
        if (Test-Path "$cudaHome\bin\nvcc") {
            Write-Host 'Verifying nvcc alias works...'
            & "$cudaHome\bin\nvcc" --version
        }
    } catch {
        Write-Host 'Hard link creation failed, trying copy...'
        Copy-Item "$cudaHome\bin\nvcc.exe" "$cudaHome\bin\nvcc" -Force
    }
    
    [Environment]::SetEnvironmentVariable('CUDA_HOME', $cudaHome, 'Process')
} else {
    Write-Host 'ERROR: nvcc.exe not found at expected location'
    throw 'CUDA installation verification failed'
}