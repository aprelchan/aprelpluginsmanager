@echo off
if "%1"=="--no-compile" (
  uv run --python 3.11 --with elyxbuilder-cli elyb build -a %2 %3 %4 %5 %6 %7 %8 %9
) else if "%1"=="-n" (
  uv run --python 3.11 --with elyxbuilder-cli elyb build -a %2 %3 %4 %5 %6 %7 %8 %9
) else (
  uv run --python 3.11 --with elyxbuilder-cli elyb build -c 2 %1 %2 %3 %4 %5 %6 %7 %8 %9
)
