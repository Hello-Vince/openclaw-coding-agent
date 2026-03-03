# openclaw-coding-agent

Run [OpenClaw](https://openclaw.ai) as a local coding agent inside Docker. Interact through the built-in Control UI in your browser, point it at a project, and let it code. You review diffs and commit from your machine.

Supports two coding agents you can switch between:
- **Kilo Code CLI** (default) -- open-source coding agent powered by your Kilo Code account
- **Cursor CLI** -- headless Cursor agent powered by your company's Cursor account

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (20.10+) and Docker Compose v2
- A [Kilo Code](https://app.kilo.ai) API key (sign in, copy key from your profile)
- A Cursor API key (from your company's Cursor account -- needed only if using the Cursor agent)

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
- Your Cursor API key (optional, only if using the Cursor agent)
- A gateway token (generate one with `openssl rand -hex 32`)
- The absolute path to the project you want OpenClaw to work on

3. **Build and start the container**

```bash
docker compose up -d --build
```

The first run builds a custom image that extends the official OpenClaw image with both Kilo Code CLI and Cursor CLI pre-installed.

4. **Open the Control UI**

Navigate to [http://localhost:18789](http://localhost:18789) in your browser. Enter your gateway token when prompted.

5. **Send a coding task**

Use the chat interface to describe what you want built or changed. By default the **kilo** agent is active and uses Kilo Code CLI. You'll see live tool output as it works.

6. **Review and commit**

Changes appear immediately in your local project directory. Review the diffs and commit when you're satisfied:

```bash
cd /path/to/your/project
git diff
git add -A && git commit -m "your message"
```

## Switching Between Agents

Two coding agents are configured. Switch between them in the Control UI using the `/agent` command:

| Command | Agent | Coding Tool | API Key Used |
|---------|-------|-------------|--------------|
| `/agent kilo` | Kilo Code CLI | `kilo` | `KILOCODE_API_KEY` |
| `/agent cursor` | Cursor CLI (headless) | `agent` | `CURSOR_API_KEY` |

Both agents share the same `/workspace` mount and tool permissions. The difference is which coding CLI they invoke to make changes.

## Project Structure

```
openclaw-coding-agent/
├── Dockerfile            # Extends OpenClaw image with Kilo Code CLI + Cursor CLI
├── docker-compose.yml    # Container definition with security hardening
├── config/
│   └── openclaw.json     # Agent, tools, skills, and gateway configuration
├── .env.example          # Template for required environment variables
├── .gitignore
└── README.md
```

## What's Configured

### AI Model Provider

[Kilo Code](https://docs.openclaw.ai/providers/kilocode) is the model provider for OpenClaw's brain. It uses your `KILOCODE_API_KEY` and routes through `https://api.kilo.ai`. The default model is `kilocode/minimax/minimax-m2.5:free` (no cost).

Available Kilo Code models include:
- `kilocode/minimax/minimax-m2.5:free` (default -- free tier)
- `kilocode/z-ai/glm-5:free` (free tier)
- `kilocode/anthropic/claude-sonnet-4.5`
- `kilocode/anthropic/claude-opus-4.6`
- `kilocode/openai/gpt-5.2`
- `kilocode/google/gemini-3-pro-preview`

Change the model in `config/openclaw.json` under `agent.model.primary`.

### Agents (`config/openclaw.json`)

- **`kilo`** -- uses the `coding-agent` skill to invoke Kilo Code CLI (`kilo`) in background mode
- **`cursor`** -- uses the `cursor-cli-headless` and `cursor-agent` skills to invoke Cursor CLI (`agent`) in headless mode

Both agents have the `coding` tool profile with access to `group:fs`, `group:runtime`, and `group:sessions`.

### Docker Setup

- **Custom image** (`Dockerfile`): installs `@kilocode/cli` (npm) and Cursor CLI on top of the official OpenClaw image
- **Agent data volume**: persists Kilo Code and Cursor config/session data across container restarts
- **Env passthrough**: `KILOCODE_API_KEY` and `CURSOR_API_KEY` are passed into the container and made available via the `env` block in `openclaw.json`
- **Security hardening**: read-only filesystem, dropped capabilities, no-new-privileges, localhost-only port

## Configuration

### Changing the AI Model

Edit `config/openclaw.json` and update `agent.model.primary`:

```json
"model": {
  "primary": "kilocode/anthropic/claude-opus-4.6"
}
```

### Pointing to a Different Project

Update `PROJECT_PATH` in your `.env` file and restart:

```bash
docker compose down && docker compose up -d
```

## Security Notes

This setup applies several hardening measures out of the box:

- **Localhost-only port binding** -- the gateway is bound to `127.0.0.1:18789`, not exposed to the network
- **Token-authenticated gateway** -- the Control UI requires a token to connect (mitigates "ClawJacked"-class attacks; use OpenClaw v2026.2.26+)
- **Dropped capabilities** -- all Linux capabilities are dropped (`cap_drop: ALL`)
- **Read-only filesystem** -- the container filesystem is read-only except for tmpfs mounts and the workspace/agent-data volumes
- **No Docker socket** -- the container has no access to the Docker daemon
- **No-new-privileges** -- prevents privilege escalation inside the container
- **Memory limits** -- capped at 3 GB RAM / 4 GB swap
- **Exec set to `full`** -- the coding CLIs need unrestricted exec inside the container. This is safe because the container itself is isolated and the filesystem is locked down outside of `/workspace`.

**Always review diffs before committing.** The agents write code autonomously; treat their output the same way you'd treat any pull request.

## Future Expansion

Adding communication channels is a config-only change in `config/openclaw.json`. No architectural changes needed.

- **Telegram** -- add a `channels.telegram` block with your bot token and a DM allowlist
- **Slack** -- add a `channels.slack` block with your Slack app token
- **REST API automation** -- use the existing `POST http://localhost:18789/tools/invoke` endpoint with your gateway token
- **Discord / WhatsApp / Signal** -- all supported via the `channels` config block

See the [OpenClaw docs](https://docs.openclaw.ai) for channel configuration details.

## Rebuilding

After updating the `Dockerfile` or changing OpenClaw versions:

```bash
docker compose down && docker compose up -d --build
```

## Stopping

```bash
docker compose down
```

To also remove the agent data volume:

```bash
docker compose down -v
```

## License

This project scaffolding is provided as-is. OpenClaw itself is licensed under its own terms -- see the [OpenClaw repository](https://github.com/openclaw/openclaw) for details.
