#!/usr/bin/env bash
set -e

echo "=== Install & Setup Nix + direnv + uv + Global Template (nixuv) ==="

# --- 1. Nix インストール ---
if ! command -v nix &> /dev/null; then
    echo "[1/4] Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --no-daemon
else
    echo "[1/4] Nix already installed."
fi

# --- 2. direnv インストール ---
if ! command -v direnv &> /dev/null; then
    echo "[2/4] Installing direnv..."
    nix-env -iA nixpkgs.direnv
else
    echo "[2/4] direnv already installed."
fi

# --- 3. uv インストール ---
if ! command -v uv &> /dev/null; then
    echo "[3/4] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[3/4] uv already installed."
fi

# --- 4. Global Template Setup ---
TEMPLATE_DIR="$HOME/.nixuv-template"
mkdir -p "$TEMPLATE_DIR/template"

echo "[4/4] Setting up global template at $TEMPLATE_DIR"

# --- flake.nix ---
cat > "$TEMPLATE_DIR/template/flake.nix" <<'EOF'
{
  description = "Minimal Python + uv + direnv template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
      in {
        devShell = pkgs.mkShell {
          buildInputs = [
            python
            pkgs.direnv
          ];
          shellHook = ''
            echo "🐍 Python environment ready (via Nix)"
          '';
        };
      });
}
EOF

# --- .envrc ---
cat > "$TEMPLATE_DIR/template/.envrc" <<'EOF'
use flake
layout python uv
EOF

# --- pyproject.toml ---
cat > "$TEMPLATE_DIR/template/pyproject.toml" <<'EOF'
[project]
name = "example"
version = "0.1.0"
description = "Example project using Nix + uv + direnv"
requires-python = ">=3.12"

[tool.uv]
dev-dependencies = ["pytest"]
EOF

# --- 5. nixuv コマンド作成 ---
cat > "$TEMPLATE_DIR/nixuv" <<'EOF'
#!/usr/bin/env bash
set -e

if [ "$1" != "init" ]; then
    echo "Usage: nixuv init name=my_project"
    exit 1
fi

project_name="${2#name=}"
if [ -z "$project_name" ]; then
    echo "❌ Please specify project name: nixuv init name=my_project"
    exit 1
fi

echo "🚀 Creating project '$project_name'..."
cp -r "$HOME/.nixuv-template/template" "./$project_name"

# --- pyproject.toml name 置換 ---
PYPROJECT_FILE="./$project_name/pyproject.toml"
if [ -f "$PYPROJECT_FILE" ]; then
    sed -i.bak -E "s/^name = .*/name = \"$project_name\"/" "$PYPROJECT_FILE"
    rm "$PYPROJECT_FILE.bak"
fi

cd "$project_name"
direnv allow

echo "✅ Project '$project_name' created!"
echo "👉 cd $project_name で開発開始可能です"
EOF

chmod +x "$TEMPLATE_DIR/nixuv"

# --- PATH に追加案内 ---
echo ""
echo "✅ Global template and nixuv command installed!"
echo "👉 Add the following to your shell config (~/.bashrc or ~/.zshrc):"
echo "export PATH=\"$HOME/.nixuv-template:\$PATH\""
echo "Then run 'source ~/.bashrc' (or 'source ~/.zshrc')"
echo ""
echo "Next, create a new project with:"
echo "nixuv init name=my_project"
