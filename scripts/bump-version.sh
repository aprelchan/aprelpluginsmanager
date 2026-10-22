#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

if [ -z "$1" ]; then
    echo "Usage: $0 <version> [codename]"
    echo "Example: $0 1.6.1"
    echo "Example: $0 1.6.1 \"Aprel Chan\""
    exit 1
fi

VERSION="$1"
CODENAME="${2:-}"
METAINFO="apmplugin/metainfo.json"

if [ ! -f "$METAINFO" ]; then
    echo "Error: $METAINFO not found"
    exit 1
fi

if [ -n "$CODENAME" ]; then
    python3 scripts/bump_version.py "$METAINFO" "$VERSION" "$CODENAME"
else
    python3 scripts/bump_version.py "$METAINFO" "$VERSION"
fi

echo ""
echo "Building plugin package..."
if command -v uv &> /dev/null; then
    uv run --with elyxbuilder-cli elyb build
elif command -v elyb &> /dev/null; then
    elyb build
else
    pip install elyxbuilder-cli --break-system-packages -U && elyb build
fi
