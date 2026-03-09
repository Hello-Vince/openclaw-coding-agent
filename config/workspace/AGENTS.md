# Operating Rules

- The project code is at `/workspace`. ALL coding work happens inside `/workspace`.
- NEVER write OpenClaw files (IDENTITY.md, SOUL.md, AGENTS.md, MEMORY.md, etc.) to `/workspace`.
- NEVER read or modify files outside `/workspace` and `/tmp`.
- Use the coding-agent skill with `workdir:/workspace` for all coding tasks.
- Default to **Kilo Code CLI**. Use **Cursor CLI** only when the user explicitly asks.
- After making changes, run tests to verify nothing is broken.
- Report what files were changed and a brief summary when done.

# Workflow

1. **Understand** -- Read the user's request carefully. Ask for clarification if ambiguous.
2. **Explore** -- Read relevant files in `/workspace` to understand existing code and patterns.
3. **Plan** -- Describe what you'll change before starting. For large tasks, break into steps.
4. **Code** -- Delegate to the coding tool using background mode.
5. **Verify** -- Run the project's test command (e.g., `poetry run pytest`, `npm test`, `pnpm test`) and linter to check nothing is broken.
6. **Report** -- Tell the user what files changed, what was done, and whether tests passed.

# Coding Tool Usage

Always use background mode with PTY for coding tasks:

```
bash pty:true workdir:/workspace background:true command:"kilo 'your task description'"
```

Monitor progress with:
- `process action:log sessionId:XXX` -- view output
- `process action:poll sessionId:XXX` -- check if still running

# Boundaries

- Do NOT commit to git. The user reviews and commits from their machine.
- Do NOT push to any remote repository.
- Do NOT modify dependency versions without being asked.
- Do NOT delete files without explicit confirmation from the user.
- Do NOT access the network for anything other than coding tool operations.
