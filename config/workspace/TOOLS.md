# Environment

- **OS**: Linux (Docker container, Debian-based)
- **Languages**: Python, JavaScript, TypeScript
- **Project root**: `/workspace`
- **Container filesystem**: Read-only except `/workspace`, `/tmp`, and agent state directories

# Python

| Task | Command |
|------|---------|
| Run tests | `poetry run pytest` |
| Run single test | `poetry run pytest path/to/test.py -v` |
| Lint | `poetry run ruff check` |
| Format | `poetry run ruff format` |
| Install dependency | `poetry add <package>` |
| Install dev dependency | `poetry add --group dev <package>` |

# Node.js / TypeScript

| Task | Command |
|------|---------|
| Install dependencies | `npm install` or `pnpm install` or `yarn install` |
| Run tests | `npm test` or `pnpm test` or `yarn test` |
| Lint | `npx eslint .` |
| Format | `npx prettier --write .` |
| Build | `npm run build` or `pnpm build` or `yarn build` |
| Type check | `npx tsc --noEmit` |
| Run TS directly | `npx tsx script.ts` |

Check `package.json` to determine which package manager the project uses (look for `packageManager` field, or lock files: `package-lock.json` = npm, `pnpm-lock.yaml` = pnpm, `yarn.lock` = yarn).

Always run commands from `/workspace`.

# Coding Tools

## Cursor CLI (default)

CRITICAL: Cursor CLI MUST use `-p` (print mode) for headless execution. Do NOT use `pty:true`.

```
bash workdir:/workspace background:true command:"cursor-agent --yolo --trust --workspace /workspace -p 'describe the task here'"
```

Flags:
- `-p` / `--print` -- non-interactive print mode (REQUIRED in this headless environment)
- `--yolo` -- auto-approve all shell commands
- `--trust` -- skip workspace trust prompts
- `--workspace /workspace` -- set the working directory

Without `-p`, cursor-agent tries to open an interactive TUI which hangs in this environment.

## Kilo Code CLI

Only use when the user explicitly asks for Kilo Code. Kilo needs PTY (interactive terminal).

```
bash pty:true workdir:/workspace background:true command:"kilo --yolo 'describe the task here'"
```

The container is sandboxed -- all operations are safe to auto-approve.

# Restrictions

- Cannot install system packages (apt/apk) at runtime -- filesystem is read-only.
- Python packages: use `poetry add`.
- Node packages: use `npm install`, `pnpm add`, or `yarn add` (whichever the project uses).
- No Docker socket access -- cannot build or run other containers.
- No sudo or root access.
