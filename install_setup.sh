#!/usr/bin/env bash
set -e

echo "=== Nix + direnv + uv setup script ==="

# --- Install Nix ---
if ! command -v nix &> /dev/null; then
    echo "[1/3] Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
else
    echo "[1/3] Nix already installed."
fi

# --- Install direnv ---
if ! command -v direnv &> /dev/null; then
    echo "[2/3] Installing direnv..."
    nix-env -iA nixpkgs.direnv
else
    echo "[2/3] direnv already installed."
fi

# --- Install uv ---
if ! command -v uv &> /dev/null; then
    echo "[3/3] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[3/3] uv already installed."
fi

# --- Check versions ---
echo ""
echo "=== Installed versions ==="
nix --version || true
direnv --version || true
uv --version || true

echo ""
echo "✅ Setup complete!"
echo "👉 Next: Run 'make init name=my_project'"
