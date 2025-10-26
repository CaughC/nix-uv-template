# 🧱 Nix + direnv + uv Template

このテンプレートは **Nix + direnv + uv** を使った最小構成のPython開発環境を即時構築できます。

---

## 🚀 セットアップ

```bash
git clone <your_repo> nix-uv-template
cd nix-uv-template
bash install_setup.sh
```

## 🌍️ グローバルセットアップ
```bash
bash install_global_nixuv.sh 
chmod +x ~/.nixuv-template/nixuv
mkdir -p ~/bin
ln -s ~/.nixuv-template/nixuv ~/bin/nixuv
export PATH="$HOME/.nixuv-template:$PATH"
# ~/.bashrc や ~/.zshrc に追記すると永続化
```

## 🧩 新しいプロジェクトを作る

```
nixuv init name=my_project
cd my_project
direnv allow
```