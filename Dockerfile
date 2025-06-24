# Claude Code専用のDockerfile
FROM node:20-alpine

# 作業ディレクトリを設定
WORKDIR /app

# 必要なパッケージをインストール
RUN apk add --no-cache \
    git \
    curl \
    bash \
    openssh-client \
    ca-certificates \
    vim \
    nano \
    coreutils

# BusyBoxのenvをGNU coreutilsのenvに置き換え
RUN ln -sf /usr/bin/env /bin/env

# npmの設定
RUN npm config set registry https://registry.npmjs.org/

# Claude Codeをインストール
RUN npm install -g @anthropic-ai/claude-code

# ユーザーを作成（セキュリティのため）
RUN adduser -D -s /bin/bash claude

# Claude用のディレクトリを作成
RUN mkdir -p /workspace && \
    chown -R claude:claude /workspace

# npmグローバルディレクトリの権限設定
RUN mkdir -p /home/claude/.npm-global && \
    chown -R claude:claude /home/claude/.npm-global

# ユーザーをclaude用に切り替え
USER claude

# npmのglobal prefixを設定
RUN npm config set prefix '/home/claude/.npm-global'

# 作業ディレクトリを設定
WORKDIR /workspace

# 環境変数の設定
ENV NODE_ENV=production
ENV PATH="/home/claude/.npm-global/bin:/usr/local/bin:$PATH"

# ヘルプスクリプトを作成
RUN echo '#!/bin/bash' > /home/claude/check-claude.sh && \
    echo 'echo "Claude Code チェック中..."' >> /home/claude/check-claude.sh && \
    echo 'if command -v claude &> /dev/null; then' >> /home/claude/check-claude.sh && \
    echo '    echo "✅ Claude Code が利用可能です"' >> /home/claude/check-claude.sh && \
    echo '    claude --version 2>/dev/null || echo "バージョン情報取得に失敗（正常）"' >> /home/claude/check-claude.sh && \
    echo 'else' >> /home/claude/check-claude.sh && \
    echo '    echo "❌ Claude Code が見つかりません"' >> /home/claude/check-claude.sh && \
    echo '    echo "パス確認: $PATH"' >> /home/claude/check-claude.sh && \
    echo '    echo "手動インストールを試してください:"' >> /home/claude/check-claude.sh && \
    echo '    echo "npm install -g @anthropic-ai/claude-code"' >> /home/claude/check-claude.sh && \
    echo 'fi' >> /home/claude/check-claude.sh && \
    chmod +x /home/claude/check-claude.sh

# Claude実行用のラッパースクリプトを作成
RUN echo '#!/bin/bash' > /home/claude/claude-wrapper.sh && \
    echo 'if [ -f /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js ]; then' >> /home/claude/claude-wrapper.sh && \
    echo '    node /usr/local/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js "$@"' >> /home/claude/claude-wrapper.sh && \
    echo 'elif [ -f /home/claude/.npm-global/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js ]; then' >> /home/claude/claude-wrapper.sh && \
    echo '    node /home/claude/.npm-global/lib/node_modules/@anthropic-ai/claude-code/dist/cli.js "$@"' >> /home/claude/claude-wrapper.sh && \
    echo 'else' >> /home/claude/claude-wrapper.sh && \
    echo '    echo "Claude Code が見つかりません。インストールしてください:"' >> /home/claude/claude-wrapper.sh && \
    echo '    echo "npm install -g @anthropic-ai/claude-code"' >> /home/claude/claude-wrapper.sh && \
    echo '    exit 1' >> /home/claude/claude-wrapper.sh && \
    echo 'fi' >> /home/claude/claude-wrapper.sh && \
    chmod +x /home/claude/claude-wrapper.sh

# コンテナが起動したときにbashを実行
CMD ["bash"]