# Cross-platform Task installer (Windows, Linux, macOS)
Set-StrictMode -Version Latest

$release = Invoke-RestMethod -Uri "https://api.github.com/repos/go-task/task/releases/latest"
$version = $release.tag_name.TrimStart("v")

function Install-Windows {
    $arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { "386" }
    $zipUrl = "https://github.com/go-task/task/releases/download/v$version/task_windows_$arch.zip"
    $zipPath = "$env:TEMP\task.zip"
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
    $dest = "C:\Program Files\task"
    if (-not (Test-Path $dest)) { New-Item -ItemType Directory -Force -Path $dest }
    Expand-Archive -Path $zipPath -DestinationPath $dest -Force
    $envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($envPath -notlike "*$dest*") {
        setx /M PATH "$envPath;$dest"
    }
    Remove-Item $zipPath -Force
    Write-Host "✅ Installed Task: " & (Join-Path $dest "task.exe") -ForegroundColor Green
}

function Install-Unix {
    $os = $IsLinux ? "linux" : "darwin"
    $arch = if ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture -eq "Arm64") { "arm64" } else { "amd64" }
    $tgzUrl = "https://github.com/go-task/task/releases/download/v$version/task_${os}_$arch.tar.gz"
    $tgzPath = "/tmp/task.tar.gz"
    Invoke-WebRequest -Uri $tgzUrl -OutFile $tgzPath
    tar -xzf $tgzPath -C /usr/local/bin task
    Remove-Item $tgzPath -Force
    Write-Host "✅ Installed Task: $(task --version)" -ForegroundColor Green
}

if ($IsWindows) {
    Install-Windows
} elseif ($IsLinux -or $IsMacOS) {
    Install-Unix
} else {
    Write-Error "Unsupported OS"
    exit 1
}