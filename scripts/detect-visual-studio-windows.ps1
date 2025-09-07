# Detect Visual Studio Build Tools and create build script
Write-Host 'Detecting Visual Studio Build Tools...'

$vcvarsPath = $null
$possiblePaths = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat'
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        Write-Host "Found VS tools at: $path"
        break
    }
}

if (-not $vcvarsPath) {
    Write-Host 'Standard paths not found, searching...'
    $found = Get-ChildItem 'C:\Program Files*\Microsoft Visual Studio' -Recurse -Name '*vcvars*.bat' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $vcvarsPath = $found.FullName
        Write-Host "Found alternative VS tools at: $vcvarsPath"
    } else {
        throw 'No Visual Studio Build Tools found'
    }
}

# Create build script
$buildScript = '@echo off' + "`r`n" + 
               "call `"$vcvarsPath`"" + "`r`n" + 
               'set DISTUTILS_USE_SDK=1' + "`r`n" + 
               'C:\opt\venv\Scripts\python.exe setup.py bdist_wheel'

Set-Content -Path 'C:\src\build.bat' -Value $buildScript -Encoding ASCII

Write-Host 'Build script created with VS path:'
Write-Host $vcvarsPath