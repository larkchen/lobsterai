FROM ubuntu:24.04 AS builder

RUN cat > /etc/apt/sources.list.d/ubuntu.sources <<EOF
Types: deb
URIs: https://mirrors.aliyun.com/ubuntu
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: https://mirrors.aliyun.com/ubuntu
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF

RUN apt-get update && apt-get install -y \
    curl \
    git \
    libgtk-3-0 \
    libnotify4 \
    libnss3 \
    libxss1 \
    libxtst6 \
    xdg-utils \
    libatspi2.0-0 \
    libuuid1 \
    libsecret-1-0 \
    libfuse2 \
    build-essential \
    python3

RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs

RUN corepack enable

WORKDIR /app

RUN git clone --branch 2026.5.9 --depth 1 \
      https://github.com/netease-youdao/LobsterAI.git /app

RUN sed -i '455a if (id === "moltbot-popo") continue;' scripts/ensure-openclaw-plugins.cjs
RUN sed -i '109a if (plugin.id === "moltbot-popo") continue;' scripts/electron-builder-hooks.cjs

RUN echo 'registry=https://registry.npmmirror.com' > ~/.npmrc
RUN cat > ~/.gitconfig <<\EOF
[url "https://gh-proxy.com/https://github.com"]
        insteadof = https://github.com
EOF

RUN npm install

RUN npm install pnpm@10.32.1

#curl -OL https://gh-proxy.com/github.com/electron/electron/releases/download/v40.2.1/electron-v40.2.1-linux-x64.zip
#curl -OL https://gh-proxy.com/github.com/electron-userland/electron-builder-binaries/releases/download/appimage-12.0.1/appimage-12.0.1.7z

RUN npm run dist:linux

RUN mkdir -p /dist && \
    cp /app/release/LobsterAI*.AppImage /dist/ 2>/dev/null || true && \
    cp /app/release/lobsterai*.deb /dist/ 2>/dev/null || true && \
    ls -la /dist/

FROM ubuntu:24.04
COPY --from=builder /dist /dist
