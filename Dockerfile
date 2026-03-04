FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN npm install -g @kilocode/cli

RUN curl https://cursor.com/install -fsSL | bash && \
    cp /root/.local/bin/cursor-agent /usr/local/bin/ && \
    chmod +x /usr/local/bin/cursor-agent

RUN mkdir -p /home/node/.openclaw /home/node/.local/share && \
    chown -R node:node /home/node/.openclaw /home/node/.local/share

USER node
