#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating apt package index"
sudo apt-get update

echo "==> Installing base prerequisites"
sudo apt-get install -y \
  git curl ca-certificates gnupg lsb-release \
  build-essential pkg-config \
  python3 python3-pip python3-venv \
  unzip zip

if ! command -v node >/dev/null 2>&1; then
  echo "==> Installing Node.js LTS (NodeSource)"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
else
  echo "==> Node.js already installed: $(node -v)"
fi

echo "==> Enabling npm corepack (if available)"
if command -v corepack >/dev/null 2>&1; then
  corepack enable || true
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

if [ -f package.json ]; then
  echo "==> Installing Node dependencies"
  npm install
fi

if [ -f requirements.txt ]; then
  echo "==> Creating Python virtual environment"
  python3 -m venv .venv
  # shellcheck disable=SC1091
  source .venv/bin/activate
  echo "==> Installing Python dependencies"
  pip install --upgrade pip
  pip install -r requirements.txt
  deactivate
fi

echo "==> Setup complete for medical-receipt-agent"
echo "Next: run your app using the repo's start instructions."
