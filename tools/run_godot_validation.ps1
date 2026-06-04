$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$BinDir = Join-Path $RepoRoot "tools\bin"
$GodotExe = Join-Path $BinDir "godot.exe"

if (-not (Test-Path -LiteralPath $GodotExe)) {
    & (Join-Path $PSScriptRoot "setup_godot.ps1")
}

$env:PATH = "$BinDir;$env:PATH"

godot --version
godot --headless --version
godot --headless --path $RepoRoot --quit
