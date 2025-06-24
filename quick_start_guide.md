# Claude Code Docker - Windows クイックスタートガイド

## 🚀 5分で始める Claude Code

### 前提条件
- ✅ Docker Desktop for Windows がインストール済み
- ✅ Claude Pro プラン（認証用）

### Step 1: ファイルのダウンロード
すべてのファイルを同じフォルダに保存してください：
- `Dockerfile`
- `docker-compose.yml`
- `.env.example`
- `claude.bat` (メインコマンド)

### Step 2: 初期セットアップ

```cmd
# 初期セットアップ（全自動）
claude.bat setup
```

### Step 3: Claude Code セットアップ

```cmd
# コンテナに接続
claude.bat connect
```

### Step 4: Claude Code の認証

コンテナ内で以下を実行：

```bash
# 1. インストール確認
/home/claude/check-claude.sh

# 2. エイリアス設定
echo 'alias claude="/home/claude/claude-wrapper.sh"' >> ~/.bashrc
source ~/.bashrc

# 3. Claude Code 起動（初回認証）
claude
```

ブラウザでURLが開くので、Claude Pro アカウントでログインしてください。

### Step 5: プロジェクト作成

```bash
# プロジェクト作成例
claude "React + TypeScript + Tailwind CSS のプロジェクトを作成して"
```

### Step 6: プロジェクトの移動

```cmd
# コンテナから一度退出
exit

# プロジェクトを専用ディレクトリに移動
claude.bat move
# Project name: my-react-app
```

## 🔧 よく使うコマンド

### Claude Code管理
| 操作 | コマンド | 説明 |
|------|----------|------|
| 初期セットアップ | `claude.bat setup` | 全て自動セットアップ |
| コンテナ接続 | `claude.bat connect` | Claude Codeに接続 |
| 状態確認 | `claude.bat status` | コンテナ状態確認 |
| コンテナ停止 | `claude.bat stop` | コンテナ停止 |
| 完全クリーンアップ | `claude.bat clean` | 全てリセット |
| ヘルプ表示 | `claude.bat help` | 全コマンド表示 |

### プロジェクト管理
| 操作 | コマンド | 説明 |
|------|----------|------|
| プロジェクト移動 | `claude.bat move` | workspaceをprojectsに移動 |
| プロジェクト一覧 | `claude.bat list` | 作成済みプロジェクト表示 |
| 既存プロジェクトで作業 | `claude.bat work` | プロジェクトをworkspaceに読み込み |
| 変更を保存 | `claude.bat save [project]` | workspaceの変更をプロジェクトに保存 |

### 直接コマンド（緊急時）
| 操作 | コマンド |
|------|----------|
| コンテナビルド | `docker-compose build` |
| コンテナ起動 | `docker-compose up -d` |
| コンテナ接続 | `docker-compose exec claude-code bash` |
| コンテナ停止 | `docker-compose down` |

## 🚨 PowerShell実行ポリシーエラーの解決

### **即座に解決（推奨）**
```powershell
# PowerShellで以下を実行（現在のセッションでのみ有効）
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process

# これで .\commands.ps1 が使用可能
.\commands.ps1 help
```

### **バッチファイル使用（確実）**
PowerShellの設定を変更したくない場合は、上記のバッチファイルを使用してください。

## ❗ トラブルシューティング

### バッチファイルが認識されない
```cmd
# ❌ 間違い
claude setup

# ✅ 正しい
claude.bat setup
```

### Claude Code が見つからない
```cmd
# 再ビルド
claude.bat clean
claude.bat setup

# または手動確認
docker-compose exec claude-code /home/claude/check-claude.sh
```

### 認証エラー
コンテナ内で：
```bash
# 認証情報リセット
rm -rf ~/.config/claude-code
claude
```

### Docker が動かない
```cmd
# Dockerサービス確認
docker --version
docker-compose --version

# Docker Desktop を再起動
```

## 📁 フォルダ構造の詳細

### プロジェクト移動前
```
your-project-folder/
├── workspace/
│   ├── package.json        # Claude Codeで作成されたファイル
│   ├── src/
│   │   └── App.tsx
│   └── README.md
└── projects/               # 空（まだプロジェクトなし）
```

### プロジェクト移動後（例: my-react-app）
```
your-project-folder/
├── workspace/              # 空（次のプロジェクト用）
└── projects/
    └── my-react-app/       # 指定したプロジェクト名でディレクトリ作成
        ├── package.json    # workspaceから移動されたファイル
        ├── src/
        │   └── App.tsx
        └── README.md
```

### 複数プロジェクト作成後
```
your-project-folder/
├── workspace/              # 空（次のプロジェクト用）
└── projects/
    ├── my-react-app/       # 1番目のプロジェクト
    ├── my-python-api/      # 2番目のプロジェクト
    ├── my-vue-app/         # 3番目のプロジェクト
    └── my-go-service/      # 4番目のプロジェクト
```

## 🎯 完全ワークフロー例

### 新しいプロジェクト作成
```cmd
# 1. 初期セットアップ
claude.bat setup

# 2. Claude Code でプロジェクト作成
claude.bat connect
# (コンテナ内でプロジェクト作成)
# claude "新しいWebアプリを作成して"
# exit

# 3. プロジェクト移動
claude.bat move
# Project name: my-web-app

# 4. 確認
claude.bat list
```

### 既存プロジェクトの編集
```cmd
# 1. 既存プロジェクトで作業開始
claude.bat work
# Available projects:
# my-web-app
# my-python-api
# Select project to work on: my-web-app

# 2. Claude Code で編集作業
# (コンテナ内)
# claude "新しい機能を追加して"
# exit

# 3. 変更を保存
claude.bat save my-web-app
# ✅ Workspace saved to 'projects\my-web-app'

# 4. 別のプロジェクトに切り替え
claude.bat work
# Select project to work on: my-python-api
```

### プロジェクト間の切り替え
```cmd
# プロジェクトA で作業
claude.bat work          # my-react-app を選択
# (作業)
claude.bat save my-react-app

# プロジェクトB に切り替え
claude.bat work          # my-python-api を選択
# (作業)
claude.bat save my-python-api

# 再びプロジェクトA に戻る
claude.bat work          # my-react-app を選択
```

## 🎉 おすすめポイント

- **`claude.bat`** = 分かりやすいコマンド名で全機能使用可能
- **拡張子必須** = Windowsの標準仕様（`.bat`を忘れずに）
- **プロジェクト分離** = workspace（一時） + projects（永続）
- **安全な保存** = 自動バックアップ機能付き

これで Claude Code の完璧な開発環境が完成です！🚀