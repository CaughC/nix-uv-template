#!/usr/bin/env bash
set -e

echo "=== User-local Install & Setup: Portable Nix + direnv + uv + Global Template ==="

# --- 1. ディレクトリ準備 ---
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.nixuv-template"

# --- 2. nix-portable インストール ---
if ! command -v nix &> /dev/null; then
    echo "[1/5] Installing nix-portable..."
    curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) -o "$HOME/.local/bin/nix-portable"
    chmod +x "$HOME/.local/bin/nix-portable"
    
    # PATH にリンクして nix コマンドとして使えるようにする
    ln -sf "$HOME/.local/bin/nix-portable" "$HOME/.local/bin/nix"
    export PATH="$HOME/.local/bin:$PATH"

    echo "✅ nix-portable installed and linked to nix command."
else
    echo "[1/5] nix already available."
fi

# --- 3. direnv インストール（ユーザー単位, nix-env 不使用） ---
if ! command -v direnv &> /dev/null; then
    echo "[2/5] Installing direnv via official script..."
    curl -LsSf https://direnv.net/install.sh | bash
else
    echo "[2/5] direnv already installed."
fi

# --- 4. uv インストール（ユーザー単位） ---
if ! command -v uv &> /dev/null; then
    echo "[3/5] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[3/5] uv already installed."
fi

# --- 5. Global Template Setup ---
TEMPLATE_DIR="$HOME/.nixuv-template"
mkdir -p "$TEMPLATE_DIR/template"

echo "[4/5] Setting up user-local global template at $TEMPLATE_DIR"

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
            echo "🐍 Python environment ready (via Portable Nix)"
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
description = "Example project using Portable Nix + uv + direnv"
requires-python = ">=3.12"

[tool.uv]
dev-dependencies = ["pytest"]
EOF

# --- 6. nixuv コマンド作成 ---
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
ln -sf "$TEMPLATE_DIR/nixuv" "$HOME/.local/bin/nixuv"
rm -f ./nix-portable
echo "[5/5] nixuv command installed."

# --- PATH に追加案内 ---
echo ""
echo "✅ User-local global template and nixuv command installed!"
echo "👉 Add the following line to your shell config (~/.bashrc or ~/.zshrc):"
echo 'export PATH="$HOME/.nixuv-template:$HOME/.local/bin:$PATH"'
echo "Then run 'source ~/.bashrc' (or 'source ~/.zshrc')"
echo ""
echo "Next, create a new project with:"
echo "nixuv init name=my_project"
