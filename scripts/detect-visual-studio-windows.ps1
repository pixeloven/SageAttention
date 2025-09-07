# Detect Visual Studio Build Tools and create build script (v2 - prioritize vcvars64)
Write-Host 'Detecting Visual Studio Build Tools...'

$vcvarsPath = $null
# Prioritize vcvars64.bat over VsDevCmd.bat for better C++ support
$vcvars64Paths = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat',
    'C:\Program Files\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat'
)

$vsDevCmdPaths = @(
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\Common7\Tools\VsDevCmd.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\VsDevCmd.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\Tools\VsDevCmd.bat',
    'C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\Common7\Tools\VsDevCmd.bat'
)

$possiblePaths = $vcvars64Paths + $vsDevCmdPaths

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
$vcvarsCall = if ($vcvarsPath -like "*VsDevCmd.bat") {
    # For VsDevCmd.bat, explicitly enable C++ build tools with all required components
    "call `"$vcvarsPath`" -arch=x64 -host_arch=x64 -vcvars_ver=14.29 -startdir=none"
} else {
    # For vcvars64.bat, use standard call
    "call `"$vcvarsPath`""
}

$buildScript = '@echo off' + "`r`n" + 
               $vcvarsCall + "`r`n" + 
               'if %ERRORLEVEL% neq 0 (' + "`r`n" +
               '    echo ERROR: Failed to setup Visual Studio environment' + "`r`n" +
               '    exit /b 1' + "`r`n" +
               ')' + "`r`n" +
               'echo === Post-vcvars Environment ===' + "`r`n" +
               'echo PATH=%PATH%' + "`r`n" +
               'echo INCLUDE=%INCLUDE%' + "`r`n" +
               'echo LIB=%LIB%' + "`r`n" +
               'echo Checking cl.exe availability...' + "`r`n" +
               'where cl' + "`r`n" +
               'cl 2>nul || (' + "`r`n" +
               '    echo ERROR: cl.exe not found in PATH after VS setup' + "`r`n" +
               '    echo Available VS tools:' + "`r`n" +
               '    dir "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC" 2>nul' + "`r`n" +
               '    exit /b 1' + "`r`n" +
               ')' + "`r`n" +
               'echo cl.exe found successfully' + "`r`n" +
               'echo === Starting Python Build ===' + "`r`n" +
               'set DISTUTILS_USE_SDK=1' + "`r`n" + 
               'set MSSdk=1' + "`r`n" +
               'set DISTUTILS_DEBUG=1' + "`r`n" +
               'C:\opt\venv\Scripts\python.exe setup.py bdist_wheel'

Set-Content -Path 'C:\src\build.bat' -Value $buildScript -Encoding ASCII

Write-Host 'Build script created with VS path:'
Write-Host $vcvarsPath
Write-Host 'Script type:' $(if ($vcvarsPath -like "*vcvars64.bat") { "vcvars64.bat (proper C++ environment)" } else { "VsDevCmd.bat (with architecture flags)" })