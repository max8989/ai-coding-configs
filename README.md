# AI Coding Configs

One repo with all **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** and **[OpenCode](https://opencode.ai)** configuration. Clone it once, symlink to your home directory, or pull specific pieces into other repos via `git submodule`.

## Structure

```
ai-coding-configs/
├── claude/                 # Claude Code global config
│   ├── CLAUDE.md           #   Global instructions (every session)
│   └── settings.json       #   Plugin toggles
├── opencode/               # OpenCode config
│   ├── agent/              #   Subagent definitions
│   ├── command/            #   Custom slash commands
│   ├── context/            #   Context system & standards
│   ├── skill/              #   Skills (context-mode, research-first, …)
│   ├── tool/               #   Tool configs
│   ├── opencode.json       #   MCP server configuration
│   ├── package.json        #   Plugin dependencies
│   └── env.example         #   Required env vars template
├── install.sh              # Linux / macOS installer
├── install.ps1             # Windows installer (PowerShell)
└── README.md
```

## Quick Start

```bash
git clone git@github.com:max8989/ai-coding-configs.git
cd ai-coding-configs
chmod +x install.sh && ./install.sh
```

The installer handles everything: prerequisites, Claude Code, OpenCode, MCP servers, and symlinks.

---

## Using as a Submodule in Other Repos

Add the whole repo and reference only what you need:

```bash
# Add this repo as a submodule
git submodule add git@github.com:max8989/ai-coding-configs.git .ai-configs

# Symlink just the skills into your project's .opencode
ln -s .ai-configs/opencode/skill .opencode/skill

# Or symlink the full opencode config
ln -s .ai-configs/opencode/opencode.json .opencode/opencode.json

# Or just the CLAUDE.md
ln -s .ai-configs/claude/CLAUDE.md CLAUDE.md
```

### Sparse Checkout (clone only specific dirs)

If you only want `opencode/skill/` without everything else:

```bash
git submodule add --no-checkout git@github.com:max8989/ai-coding-configs.git .ai-configs
cd .ai-configs
git sparse-checkout init --cone
git sparse-checkout set opencode/skill
git checkout main
cd ..
```

### Cherry-pick examples

| I need… | Command |
|---------|---------|
| Just skills | `git sparse-checkout set opencode/skill` |
| Just MCP config | `git sparse-checkout set opencode/opencode.json` |
| Claude global rules | `git sparse-checkout set claude` |
| Skills + commands | `git sparse-checkout set opencode/skill opencode/command` |
| Everything | `git sparse-checkout disable` |

### Update the submodule

```bash
cd .ai-configs && git pull origin main && cd ..
git add .ai-configs && git commit -m "chore: update ai-configs"
```

---

## Full Setup Guide

### 🐧 Linux (Arch)

<details>
<summary>Click to expand</summary>

```bash
sudo pacman -S git nodejs npm python python-pip

# UV (for MCP servers)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Claude Code
npm install -g @anthropic-ai/claude-code

# OpenCode (AUR)
yay -S opencode-bin

# MCP deps
npm install -g context-mode
```

</details>

### 🐧 Linux (Ubuntu / Debian)

<details>
<summary>Click to expand</summary>

```bash
sudo apt-get update && sudo apt-get install -y git nodejs npm python3 python3-pip
curl -LsSf https://astral.sh/uv/install.sh | sh
npm install -g @anthropic-ai/claude-code opencode context-mode
```

</details>

### 🍎 macOS

<details>
<summary>Click to expand</summary>

```bash
brew install git node python uv
npm install -g @anthropic-ai/claude-code context-mode
brew install opencode-ai/tap/opencode
brew install github/gh-mcp-server/github-mcp-server
```

</details>

### 🪟 Windows

<details>
<summary>Click to expand</summary>

```powershell
# Prerequisites (winget)
winget install OpenJS.NodeJS.LTS Python.Python.3.12 Git.Git

# UV
irm https://astral.sh/uv/install.ps1 | iex

# Tools
npm install -g @anthropic-ai/claude-code opencode context-mode

# Run installer
powershell -ExecutionPolicy Bypass -File install.ps1
```

**Note:** Symlinks require **Developer Mode** or **Admin**. The script falls back to copying.

</details>

---

## Config Locations

| Tool | Path |
|------|------|
| Claude Code (global) | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` |
| Claude Code (per-project) | `AGENTS.md` in repo root |
| OpenCode | `~/.opencode/opencode.json`, `~/.opencode/skill/`, etc. |

## MCP Servers

| Server | Type | Purpose |
|--------|------|---------|
| Context7 | Remote | Library documentation lookup |
| Supabase | Remote | Database management |
| Figma | Remote | Design system integration |
| Chrome DevTools | Local | Browser debugging |
| Git | Local | Git operations (via uvx) |
| GitHub | Local | GitHub API |
| context-mode | Local | Context window optimization |

## Required API Keys

| Key | Source | Used By |
|-----|--------|---------|
| Anthropic | `claude login` | Claude Code |
| `CONTEXT7_API_KEY` | [context7.com](https://context7.com) | Context7 MCP |
| `SUPABASE_ACCESS_TOKEN` | [Supabase tokens](https://supabase.com/dashboard/account/tokens) | Supabase MCP |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub tokens](https://github.com/settings/tokens) | GitHub MCP |

## License

MIT
