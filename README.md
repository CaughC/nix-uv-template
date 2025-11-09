# 🧱 Nix + direnv + uv Template

このテンプレートは **Nix + direnv + uv** を使った最小構成のPython開発環境を即時構築できます。

---

## 🌍️ グローバルセットアップ
ここでいうglobalとは、単一ユーザがどのディレクトリ配下でもcommand実行可能な状態をさします。
```bash
git clone git@github.com:CaughC/nix-uv-template.git
cd nix-uv-template
bash install_global_nixuv.sh 
export PATH="$HOME/.nixuv-template:$PATH"
# ~/.bashrc や ~/.zshrc に追記すると永続化
```

## 作成されるディレクトリ構成
```
$HOME/.nixuv-template/
├── nixuv          # 新規プロジェクト作成コマンド
└── template/      # global template
    ├── flake.nix
    ├── .envrc
    └── pyproject.toml
```

## 🧩 新しいプロジェクトを作る
```bash
nixuv init name=my_project
cd my_project
direnv allow
```

## Memo
- Nix標準のインストーラーは/nix（システム全体インストール用ディレクトリ）を作ろうとする。(--no-daemonをつけたり、NIX_INSTALLER_NO_SUDOの環境変数を設定しても。)　ということで、本shellscriptではPortable Nixを採用。

- Nix Portable : https://github.com/DavHau/nix-portable

## 各Packageの更新方法
- Nix Portable
```bash
# 現在の nix-portable を置き換えるだけ
cd $HOME/.local/bin
curl -L https://github.com/DavHau/nix-portable/releases/latest/download/nix-portable-$(uname -m) -o nix-portable
chmod +x nix-portable
```

- direnv
```bash
# 公式インストールスクリプトを再実行
curl -LsSf https://direnv.net/install.sh | bash
```

- uv
```bash
# uv 公式スクリプトで再インストール
curl -LsSf https://astral.sh/uv/install.sh | sh
```

## 本機能が不要になった場合のたたみ方
- Nix Portable
```bash
rm -f $HOME/.local/bin/nix-portable
rm -f $HOME/.local/bin/nix  # シンボリックリンクも削除
```

- direnv
```bash
# 公式スクリプトでインストールしたバイナリを削除
rm -f $HOME/.local/bin/direnv
```

- uv
```bash
# uv のユーザー単位インストールを削除
rm -rf $HOME/.uv
rm -f $HOME/.local/bin/uv
```

- global template
```bash
rm -rf $HOME/.nixuv-template
```

- Revert PATH setting
```bash
# ~/.bashrc または ~/.zshrc に追加した PATH 行を削除
# 例: export PATH="$HOME/.nixuv-template:$HOME/.local/bin:$PATH"
```

### Note
Nix portableの仕様か、windows上での動作が不安定。
```
PRootは、ptrace()というLinuxカーネルのシステムコール（他のプロセスをトレース・操作する機能）を多用して動作します。しかし、WSL（特にWSL 1）では、このptrace()の実装が完全ではない、または通常のLinuxとは異なる振る舞いをすることが知られています。これにより、PRootが意図した通りに動作しない、あるいはエラーが発生することがあります。
```
これは、export NP_RUNTIME=prootとしたときに発生する。wslではこれをつけないこと。（linuxでも必要ないかも？）