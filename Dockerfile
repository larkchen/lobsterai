FROM ubuntu:24.04 AS builder

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
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable

WORKDIR /app

RUN git clone --branch 2026.5.9 --depth 1 \
      https://github.com/netease-youdao/LobsterAI.git /app

RUN sed -i '455a if (id === "moltbot-popo") continue;' scripts/ensure-openclaw-plugins.cjs

RUN npm install

RUN npm install pnpm

RUN npm run dist:linux

RUN mkdir -p /dist && \
    cp /app/release/LobsterAI*.AppImage /dist/ 2>/dev/null || true && \
    cp /app/release/lobsterai*.deb /dist/ 2>/dev/null || true && \
    ls -la /dist/

FROM ubuntu:24.04
COPY --from=builder /dist /dist
