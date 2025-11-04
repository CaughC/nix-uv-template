#!/usr/bin/env bash
set -e

echo "=== User-local Install & Setup: Portable Nix + direnv + uv + Global Template ==="

# --- 1. ディレクトリ準備 ---
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.nixuv-template/template"

TEMPLATE_DIR="$HOME/.nixuv-template/template"

# --- 2. Global Template Setup ---
# template_files/ にある flake.nix, .envrc, pyproject.toml をコピーする
if [ ! -d "./template_files" ]; then
    echo "❌ template_files/ ディレクトリが存在しません"
    exit 1
fi
cp -r ./template_files/. "$TEMPLATE_DIR/"

# --- 3. nix-portable インストール ---
if ! command -v nix &> /dev/null; then
    echo "[1/5] Installing nix-portable..."
    curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) -o "$HOME/.local/bin/nix-portable"
    chmod +x "$HOME/.local/bin/nix-portable"
    ln -sf "$HOME/.local/bin/nix-portable" "$HOME/.local/bin/nix"
    export PATH="$HOME/.local/bin:$PATH"
    echo "✅ nix-portable installed."
else
    echo "[1/5] nix already available."
fi

# --- 4. direnv インストール ---
if ! command -v direnv &> /dev/null; then
    echo "[2/5] Installing direnv..."
    curl -LsSf https://direnv.net/install.sh | bash
else
    echo "[2/5] direnv already installed."
fi

# --- 5. uv インストール ---
if ! command -v uv &> /dev/null; then
    echo "[3/5] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
else
    echo "[3/5] uv already installed."
fi

# --- 6. nixuv コマンド作成 ---
cat > "$HOME/.nixuv-template/nixuv" <<'EOF'
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

TEMPLATE_DIR="$HOME/.nixuv-template/template"
echo "🚀 Creating project '$project_name'..."
mkdir -p "./$project_name"

# --- template をコピー ---
cp -r "$TEMPLATE_DIR/"* "./$project_name/"

# --- pyproject.toml 内の name を置換 ---
PYPROJECT_FILE="./$project_name/pyproject.toml"
if [ -f "$PYPROJECT_FILE" ]; then
    sed -i.bak -E "s/^name = .*/name = \"$project_name\"/" "$PYPROJECT_FILE"
    rm "$PYPROJECT_FILE.bak"
fi

# --- プロジェクト内の不要な nix-portable 削除 ---
rm -f "./$project_name/nix-portable"

cd "$project_name"
direnv allow

echo "✅ Project '$project_name' created!"
echo "👉 cd $project_name で開発開始可能です"
EOF

chmod +x "$HOME/.nixuv-template/nixuv"

# --- 7. PATH に追加案内 ---
echo ""
echo "✅ User-local global template and nixuv command installed!"
echo "👉 Add the following line to your shell config (~/.bashrc or ~/.zshrc):"
echo 'export PATH="$HOME/.nixuv-template:$HOME/.local/bin:$PATH"'
echo "Then run 'source ~/.bashrc' (or 'source ~/.zshrc')"
echo ""
echo "Next, create a new project with:"
echo "nixuv init name=my_project"
