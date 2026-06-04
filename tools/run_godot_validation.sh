#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="$ROOT_DIR/tools/bin"

if [ ! -x "$BIN_DIR/godot" ]; then
  "$ROOT_DIR/tools/setup_godot.sh"
fi

export PATH="$BIN_DIR:$PATH"

godot --version
godot --headless --version
godot --headless --path "$ROOT_DIR" --quit
