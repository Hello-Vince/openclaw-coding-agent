# Operating Rules

- The project code is at `/workspace`. ALL coding work happens inside `/workspace`.
- NEVER write OpenClaw files (IDENTITY.md, SOUL.md, AGENTS.md, MEMORY.md, etc.) to `/workspace`.
- NEVER read or modify files outside `/workspace` and `/tmp`.
- Default to **Cursor CLI**. Use **Kilo Code CLI** only when the user explicitly asks.
- After making changes, run tests to verify nothing is broken.
- Report what files were changed and a brief summary when done.

# Autonomy

- This container is fully sandboxed. All operations inside it are safe.
- NEVER ask for permission before running commands -- execute immediately.
- Auto-approve all tool calls, exec requests, and file operations.
- If a tool or command needs confirmation, approve it automatically.
- Do NOT wait for user approval on shell commands, file writes, or installs.

# Workflow

1. **Understand** -- Read the user's request carefully. Ask for clarification if ambiguous.
2. **Explore** -- Read relevant files in `/workspace` to understand existing code and patterns.
3. **Plan** -- Describe what you'll change before starting. For large tasks, break into steps.
4. **Code** -- Delegate to cursor-agent or kilo using the correct invocation below.
5. **Verify** -- Run the project's test command (e.g., `poetry run pytest`, `npm test`, `pnpm test`) and linter to check nothing is broken.
6. **Report** -- Tell the user what files changed, what was done, and whether tests passed.

# Coding Tool Usage

## Cursor CLI (default)

Cursor CLI MUST run in **print mode (`-p`)** -- it does NOT work with PTY in this headless environment.

```
bash workdir:/workspace background:true command:"cursor-agent --yolo --trust --workspace /workspace -p 'your task description'"
```

Do NOT use `pty:true` with cursor-agent. The `-p` flag enables non-interactive print mode which works headlessly.

## Kilo Code CLI (only when user asks)

Kilo Code uses interactive mode and needs PTY:

```
bash pty:true workdir:/workspace background:true command:"kilo --yolo 'your task description'"
```

## Monitoring background sessions

- `process action:log sessionId:XXX` -- view output
- `process action:poll sessionId:XXX` -- check if still running

# Boundaries

- Do NOT commit to git. The user reviews and commits from their machine.
- Do NOT push to any remote repository.
