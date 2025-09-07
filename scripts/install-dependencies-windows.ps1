# Install system dependencies using chocolatey
Write-Host 'Installing Python 3.12...'
choco install python312 -y

Write-Host 'Installing Visual Studio Build Tools...'
choco install visualstudio2019buildtools --package-parameters '--add Microsoft.VisualStudio.Workload.VCTools' -y

Write-Host 'Installing Git...'
choco install git -y

Write-Host 'Installing NVIDIA CUDA Toolkit...'
if ($env:CUDA_VERSION -eq '12.8.1') {
    choco uninstall cuda -y --ignore-dependencies
    choco install cuda --version=12.8.1.572 -y
} else {
    choco uninstall cuda -y --ignore-dependencies
    choco install cuda --version=12.9.1.576 -y
}

Write-Host 'All dependencies installed successfully'