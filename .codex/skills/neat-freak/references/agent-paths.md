# Agent Paths Reference

Use this file during the inventory step to locate durable instructions, memory,
and skills for common coding-agent environments.

## OpenAI Codex

| Purpose | Path |
|---|---|
| Global instructions | `~/.codex/AGENTS.md` or `$CODEX_HOME/AGENTS.md` |
| Project instructions | Project-root `AGENTS.md` |
| Project override | `AGENTS.override.md`, when present |
| Global skills | `~/.codex/skills/<name>/SKILL.md` |
| Project skills | `.codex/skills/<name>/SKILL.md` |

Codex does not have a separate memory-index system. Durable project facts should
live in project `AGENTS.md`; cross-project preferences may belong in global
`AGENTS.md` only when the user clearly wants them to apply everywhere.

## Claude Code

| Purpose | Path |
|---|---|
| Global memory | `~/.claude/projects/<encoded-project-path>/memory/` |
| Memory index | `~/.claude/projects/<encoded-project-path>/memory/MEMORY.md` |
| Global instructions | `~/.claude/CLAUDE.md` |
| Project instructions | Project-root `CLAUDE.md` |
| Skills | `~/.claude/skills/<name>/SKILL.md` |

Memory files commonly use YAML frontmatter such as `name`, `description`, and
`type`.

## OpenCode

| Purpose | Path |
|---|---|
| Global config | `~/.config/opencode/` |
| Project config | `.opencode/` |
| Project skills | `.opencode/skills/`, `.claude/skills/`, `.codex/skills/` |
| Global skills | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.codex/skills/` |

OpenCode may read both Claude-style and Codex-style skill directories.

## OpenClaw

| Purpose | Path |
|---|---|
| User skills | `~/.openclaw/skills/<name>/SKILL.md` |
| Project skills | `.openclaw/skills/<name>/SKILL.md` |
| Workspace skills | Workspace `skills/` directory |

## Cross-Agent Projects

For projects used by multiple agent platforms, prefer one canonical project
instruction file plus small pointers from platform-specific files, or keep the
platform files deliberately synchronized. `README.md` and `docs/` should remain
platform-neutral.
