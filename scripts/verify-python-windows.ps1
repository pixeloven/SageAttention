# Refresh environment and verify Python installation
Write-Host 'Refreshing environment after installations...'
refreshenv

Write-Host 'Checking Python installation...'
if (Test-Path 'C:\Python312\python.exe') {
    Write-Host 'Python found at C:\Python312\python.exe'
    & 'C:\Python312\python.exe' --version
} else {
    Write-Host 'Python not found at expected location, searching...'
    Get-ChildItem 'C:\Python*' -ErrorAction SilentlyContinue | Select-Object Name, FullName
}