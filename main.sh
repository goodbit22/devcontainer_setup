#!/usr/bin/env bash
set -euo pipefail

install_task_linux_macos() {
  VERSION=$(curl -s https://api.github.com/repos/go-task/task/releases/latest | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)
  case $ARCH in
    x86_64) ARCH=amd64 ;;
    aarch64) ARCH=arm64 ;;
  esac

  echo "Installing Task v$VERSION for $OS-$ARCH..."
  curl -sL "https://github.com/go-task/task/releases/download/v${VERSION}/task_${OS}_${ARCH}.tar.gz" -o task.tar.gz
  sudo tar -xzf task.tar.gz -C /usr/local/bin task
  rm task.tar.gz
  echo "✅ Installed: $(task --version)"
}

install_task_windows() {
  echo "Detected Windows. Please run the PowerShell script instead:"
  echo "pwsh -File install-task.ps1"
  exit 1
}

case "$(uname -s)" in
  Linux|Darwin) install_task_linux_macos ;;
  MINGW*|CYGWIN*|MSYS*) install_task_windows ;;
  *) echo "Unsupported OS"; exit 1 ;;
esac