#!/usr/bin/env bash
set -euo pipefail

GODOT_VERSION="${GODOT_VERSION:-4.3-stable}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT_DIR/tools"
BIN_DIR="$TOOLS_DIR/bin"
DOWNLOAD_DIR="$TOOLS_DIR/downloads"
ZIP_PATH="$DOWNLOAD_DIR/Godot_v${GODOT_VERSION}_linux.x86_64.zip"
GODOT_URL="https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip"

mkdir -p "$BIN_DIR" "$DOWNLOAD_DIR"

if [ -x "$BIN_DIR/godot" ]; then
  "$BIN_DIR/godot" --version
  exit 0
fi

if [ ! -f "$ZIP_PATH" ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -L "$GODOT_URL" -o "$ZIP_PATH"
  elif command -v wget >/dev/null 2>&1; then
    wget "$GODOT_URL" -O "$ZIP_PATH"
  else
    echo "Neither curl nor wget is available. Install one, then rerun this script." >&2
    exit 1
  fi
fi

if command -v unzip >/dev/null 2>&1; then
  unzip -o "$ZIP_PATH" -d "$DOWNLOAD_DIR/godot-${GODOT_VERSION}" >/dev/null
else
  echo "unzip is required to extract Godot." >&2
  exit 1
fi

GODOT_BIN="$(find "$DOWNLOAD_DIR/godot-${GODOT_VERSION}" -maxdepth 1 -type f -name 'Godot_v*_linux.x86_64' | head -n 1)"
if [ -z "$GODOT_BIN" ]; then
  echo "Could not find extracted Godot binary." >&2
  exit 1
fi

cp "$GODOT_BIN" "$BIN_DIR/godot"
chmod +x "$BIN_DIR/godot"

echo "Godot installed at $BIN_DIR/godot"
echo "Add to PATH for this shell with:"
echo "export PATH=\"$BIN_DIR:\$PATH\""
"$BIN_DIR/godot" --version
