FROM node:26-slim

ARG CLAUDE_CODE_VERSION=latest

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium \
    LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git jq curl ca-certificates nano xclip \
        chromium libnss3 \
        fonts-noto-core fonts-noto-unhinted \
        libatk-bridge2.0-0 libgtk-3-0 libdrm2 libgbm1 \
        libx11-xcb1 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Pre-create with correct ownership so the ${localEnv:HOME}/.config/gh volume mount
# in devcontainer.json doesn't leave this parent directory root-owned (podman only
# fixes ownership of the mount target itself, not directories it has to auto-create
# above it) — a root-owned ~/.config broke Chromium's crashpad database creation.
RUN mkdir -p /home/node/.config && chown node:node /home/node/.config

# Claude Code's onboarding/session-tracking state (firstStartTime, etc.) lives in
# ~/.claude.json, a FILE directly in $HOME — separate from the ~/.claude/ directory,
# which is what the moneyman-claude-config volume actually persists. Without this,
# every rebuild looked like a fresh install and re-triggered the setup wizard even
# though the real credentials in ~/.claude/.credentials.json were fine. Symlinking
# it into the already-persisted .claude/ volume fixes it without a second volume
# mount (which would risk the same root-owned-mountpoint issue as the .config bug).
RUN ln -sf /home/node/.claude/.claude.json /home/node/.claude.json && \
    chown -h node:node /home/node/.claude.json

USER node
