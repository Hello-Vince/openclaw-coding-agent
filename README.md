# openclaw-coding-agent

Run [OpenClaw](https://openclaw.ai) as a local coding agent inside Docker. Interact through the built-in Control UI in your browser, point it at a project, and let it code. You review diffs and commit from your machine.

Ships with two coding tools:
- **Kilo Code CLI** (default) -- powered by your Kilo Code account
- **Cursor CLI** -- powered by your company's Cursor account

The container includes Python and Poetry so the agent can run tests and lint.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (20.10+) and Docker Compose v2
- A [Kilo Code](https://app.kilo.ai) API key
- A Cursor API key (optional, only if using Cursor)

## Quick Start

1. **Clone this repo**

```bash
git clone https://github.com/Hello-Vince/openclaw-coding-agent.git
cd openclaw-coding-agent
```

2. **Create your `.env` file**

```bash
cp .env.example .env
```

Edit `.env` and fill in:
- Your Kilo Code API key
- Your Cursor API key (optional)
- A gateway token (generate one with `openssl rand -hex 32`)
- The absolute path to your project

3. **Build and start the container**

```bash
docker compose up -d --build
```

4. **Open the Control UI**

Navigate to [http://localhost:18789](http://localhost:18789). On first connection there are two auth steps:

**Step A -- Enter your gateway token:**

The UI will show "This gateway requires auth". Look for a token/password input field in the Control UI settings. Paste the `OPENCLAW_GATEWAY_TOKEN` value from your `.env` file and click Connect.

**Step B -- Approve device pairing:**

After entering the token, you'll see "pairing required". Open a terminal and run:

```bash
docker exec openclaw-agent openclaw devices list
```

Find the pending request ID, then approve it:

```bash
docker exec openclaw-agent openclaw devices approve <requestId>
```

Refresh the page -- you should now see the chat interface.

> **Note:** Device pairing is stored in the `openclaw-state` volume. If you run `docker compose down -v` (which wipes volumes), you'll need to re-approve. A regular `docker compose restart` preserves it.

5. **Send a coding task**

Chat with the agent. It delegates to Kilo Code CLI by default. Say "use cursor" to switch tools.

6. **Review and commit**

```bash
cd /path/to/your/project
git diff
git add -A && git commit -m "your message"
```

## Project Structure

```
openclaw-coding-agent/
├── Dockerfile                # OpenClaw + Kilo CLI + Cursor CLI + Python + Poetry
├── docker-compose.yml        # Container definition with security hardening
├── config/
│   ├── openclaw.json         # Agent, tools, skills, and gateway configuration
│   └── workspace/            # Agent context files (mounted read-only)
│       ├── AGENTS.md         # Operating rules, workflow, boundaries
│       ├── TOOLS.md          # Environment info, available commands
│       ├── USER.md           # Your output preferences
│       ├── SOUL.md           # Agent personality and coding philosophy
│       └── IDENTITY.md       # Agent name, role, goals
├── .env.example
├── .gitignore
└── README.md
```

## Agent Context Files

OpenClaw loads workspace files into every session to shape how it behaves. Edit these in `config/workspace/` to customize the agent:

| File | Purpose | Edit when... |
|------|---------|-------------|
| `AGENTS.md` | Rules, workflow, boundaries | You want to change what the agent can/cannot do |
| `TOOLS.md` | Environment, commands, restrictions | You change the tech stack or add tools |
| `USER.md` | Output format preferences | You want different response styles |
| `SOUL.md` | Personality, coding philosophy | You want a different coding approach |
| `IDENTITY.md` | Name, role, goals | You want to rename or re-purpose the agent |

Changes take effect on the next session (no rebuild needed, files are bind-mounted read-only).

## Configuration

### Changing the AI Model

Edit `config/openclaw.json` and update `agents.defaults.model.primary`. Default is `kilocode/minimax/minimax-m2.5:free` (free tier).

Paid options: `kilocode/anthropic/claude-sonnet-4.5`, `kilocode/anthropic/claude-opus-4.6`, `kilocode/openai/gpt-5.2`

### Pointing to a Different Project

Update `PROJECT_PATH` in your `.env` file and restart:

```bash
docker compose restart
```

### Masking Sensitive Files

The `docker-compose.yml` masks `.env` files in your project so the agent can't read real credentials:

```yaml
- /dev/null:/workspace/.env:ro
- /dev/null:/workspace/src/resource/application.yaml:ro
- /dev/null:/workspace/src/resource/.env:ro
```

Add more lines for any files containing secrets.

## Security Notes

- **Localhost-only port** -- gateway bound to `127.0.0.1:18789`
- **Token auth** -- Control UI requires a gateway token
- **Device pairing** -- new browsers must be approved
- **Dropped capabilities** -- `cap_drop: ALL`
- **Read-only filesystem** -- except `/workspace`, `/tmp`, and state volumes
- **No Docker socket** -- agent cannot access the Docker daemon
- **No-new-privileges** -- blocks privilege escalation
- **Memory limits** -- 3 GB RAM / 4 GB swap
- **Credential masking** -- project `.env` files hidden via `/dev/null` overlay
- **Agent rules** -- `AGENTS.md` forbids git push, file deletion without confirmation, and writing outside `/workspace`

**Always review diffs before committing.**

## Common Operations

```bash
# Rebuild after Dockerfile changes
docker compose down -v && docker compose up -d --build

# Restart (preserves state, re-reads config)
docker compose restart

# Approve new browser
docker exec openclaw-agent openclaw devices list
docker exec openclaw-agent openclaw devices approve <requestId>

# View logs
docker logs openclaw-agent --tail 50

# Stop
docker compose down

# Stop and wipe all state
docker compose down -v
```

## Troubleshooting

### "gateway token missing" / "This gateway requires auth"

The Control UI needs your gateway token. Look for the settings/auth area in the UI, paste the `OPENCLAW_GATEWAY_TOKEN` value from your `.env` file, and click Connect.

### "pairing required"

Your browser needs approval. Run:

```bash
docker exec openclaw-agent openclaw devices list
docker exec openclaw-agent openclaw devices approve <requestId>
```

Then refresh the page.

### "too many failed authentication attempts"

The rate limiter was triggered by repeated failed connections. Close the browser tab, then:

```bash
docker compose down && docker compose up -d
```

Wait a few seconds, then open [http://localhost:18789](http://localhost:18789) and enter your token.

### "origin not allowed"

The gateway doesn't recognize the browser's origin. Check that `gateway.controlUi.allowedOrigins` in `config/openclaw.json` includes the URL you're using (e.g., `http://localhost:18789`).

### Container starts but UI won't load (connection refused)

Check the logs for errors:

```bash
docker logs openclaw-agent --tail 30
```

Common causes: invalid `openclaw.json` (run `docker exec openclaw-agent openclaw doctor`), or the gateway bound to the wrong address.

### Device pairing lost after restart

You used `docker compose down -v` which wipes volumes (including pairing data). Use `docker compose restart` for restarts that preserve state. Only use `-v` when you need a clean slate.

## Future Expansion

Adding communication channels is a config-only change in `config/openclaw.json`:

- **Telegram** -- `channels.telegram` with bot token and DM allowlist
- **Slack** -- `channels.slack` with app token
- **REST API** -- `POST http://localhost:18789/tools/invoke` with gateway token
- **Discord / WhatsApp / Signal** -- all via `channels` config

See [OpenClaw docs](https://docs.openclaw.ai) for details.

## License

This project scaffolding is provided as-is. OpenClaw is licensed under its own terms -- see the [OpenClaw repository](https://github.com/openclaw/openclaw).
