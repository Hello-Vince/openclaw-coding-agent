FROM ghcr.io/openclaw/openclaw:latest

USER root

RUN npm install -g @kilocode/cli

RUN curl https://cursor.com/install -fsSL | bash

RUN mkdir -p /home/node/.openclaw /home/node/.local/share && \
    chown -R node:node /home/node/.openclaw /home/node/.local/share

USER node
