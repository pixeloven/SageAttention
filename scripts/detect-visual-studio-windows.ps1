# Detect Visual Studio Build Tools and create build script
Write-Host 'Detecting Visual Studio Build Tools...'

$vcvarsPath = $null
$possiblePaths = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat'
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $vcvarsPath = $path
        Write-Host "Found VS tools at: $path"
        
        # Verify this VS installation has the C++ compiler
        $vsRoot = Split-Path (Split-Path (Split-Path $path -Parent) -Parent) -Parent
        $clPath = Join-Path $vsRoot "VC\Tools\MSVC"
        if (Test-Path $clPath) {
            $msvcVersions = Get-ChildItem $clPath -Directory | Sort-Object Name -Descending
            if ($msvcVersions) {
                $latestMsvc = $msvcVersions[0].FullName
                $clExe = Join-Path $latestMsvc "bin\Hostx64\x64\cl.exe"
                if (Test-Path $clExe) {
                    Write-Host "Verified C++ compiler available at: $clExe"
                    break
                } else {
                    Write-Host "Warning: VS installation found but no C++ compiler at expected location: $clExe"
                }
            }
        } else {
            Write-Host "Warning: VS installation found but no MSVC tools directory: $clPath"
        }
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

# Create build script with enhanced environment setup
$buildScript = '@echo off' + "`r`n" + 
               "call `"$vcvarsPath`"" + "`r`n" + 
               'echo === Post-vcvars Environment ===' + "`r`n" +
               'echo PATH=%PATH%' + "`r`n" +
               'echo INCLUDE=%INCLUDE%' + "`r`n" +
               'echo LIB=%LIB%' + "`r`n" +
               'echo Checking cl.exe availability...' + "`r`n" +
               'where cl' + "`r`n" +
               'cl 2>nul || echo cl.exe not found in PATH' + "`r`n" +
               'echo === Starting Python Build ===' + "`r`n" +
               'set DISTUTILS_USE_SDK=1' + "`r`n" + 
               'set MSSdk=1' + "`r`n" +
               'set DISTUTILS_DEBUG=1' + "`r`n" +
               'C:\opt\venv\Scripts\python.exe setup.py bdist_wheel'

Set-Content -Path 'C:\src\build.bat' -Value $buildScript -Encoding ASCII

Write-Host 'Build script created with VS path:'
Write-Host $vcvarsPath