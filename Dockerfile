FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN npm install -g @kilocode/cli typescript ts-node tsx eslint prettier

RUN corepack enable && corepack prepare pnpm@latest --activate && corepack prepare yarn@stable --activate

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv pipx git && \
    pipx install poetry && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/node/.openclaw/workspace /home/node/.local/share /home/node/.local/bin /home/node/.local/state /home/node/.cursor /home/node/.config && \
    chown -R node:node /home/node/.openclaw /home/node/.local /home/node/.cursor /home/node/.config

USER node

RUN curl https://cursor.com/install -fsSL | bash && \
    if [ ! -f /home/node/.local/bin/cursor-agent ]; then \
      ln -s "$(find /home/node/.local/share/cursor-agent -name cursor-agent -type f | head -1)" /home/node/.local/bin/cursor-agent; \
    fi

ENV PATH="/home/node/.local/bin:/root/.local/bin:$PATH"
ENV XDG_CONFIG_HOME="/home/node/.config"
