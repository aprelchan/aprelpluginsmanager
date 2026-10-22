#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

usage() {
  echo "Usage: $(basename "$0") [--no-compile | -c LEVEL] [extra elyb args...]"
  echo "  default:          build with compilation (-c 2)"
  echo "  -n, --no-compile: build without compilation (AST check only)"
  echo "  -c, --compile LEVEL: compilation optimization level 0-2"
}

COMPILE=2

while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    -n|--no-compile) COMPILE=""; shift ;;
    -c|--compile)
      if [ -n "${2:-}" ] && [ "${2#-}" = "$2" ]; then
        COMPILE="$2"; shift 2
      else
        COMPILE=1; shift
      fi
      ;;
    --) shift; break ;;
    -*) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    *) break ;;
  esac
done

if [ -z "$COMPILE" ]; then
  uv run --python 3.11 --with elyxbuilder-cli elyb build -a "$@"
else
  uv run --python 3.11 --with elyxbuilder-cli elyb build -c "$COMPILE" "$@"
fi
