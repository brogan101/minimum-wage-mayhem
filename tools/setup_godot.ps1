param(
    [string]$GodotVersion = "4.3-stable"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BinDir = Join-Path $RepoRoot "tools\bin"
$DownloadDir = Join-Path $RepoRoot "tools\downloads"
$ZipPath = Join-Path $DownloadDir "Godot_v${GodotVersion}_win64.exe.zip"
$GodotUrl = "https://github.com/godotengine/godot/releases/download/${GodotVersion}/Godot_v${GodotVersion}_win64.exe.zip"
$GodotExe = Join-Path $BinDir "godot.exe"

New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
New-Item -ItemType Directory -Force -Path $DownloadDir | Out-Null

if (Test-Path -LiteralPath $GodotExe) {
    & $GodotExe --version
    exit 0
}

if (-not (Test-Path -LiteralPath $ZipPath)) {
    Invoke-WebRequest -Uri $GodotUrl -OutFile $ZipPath
}

$ExtractDir = Join-Path $DownloadDir "godot-${GodotVersion}"
New-Item -ItemType Directory -Force -Path $ExtractDir | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractDir -Force

$ExtractedExe = Get-ChildItem -LiteralPath $ExtractDir -Filter "Godot_v*_win64.exe" | Select-Object -First 1
if (-not $ExtractedExe) {
    throw "Could not find extracted Godot executable."
}

Copy-Item -LiteralPath $ExtractedExe.FullName -Destination $GodotExe -Force

Write-Host "Godot installed at $GodotExe"
Write-Host "Add to PATH for this PowerShell session with:"
Write-Host "`$env:PATH = '$BinDir;' + `$env:PATH"
& $GodotExe --version
