# AI Coding Configs

Unified setup for **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** and **[OpenCode](https://opencode.ai)** — two AI coding assistants. This repo bundles both configurations as Git submodules with cross-platform install scripts.

## What's Inside

```
ai-coding-configs/
├── claude-config/          # ← submodule: Claude Code global config
│   ├── CLAUDE.md           #    Global instructions (loaded every session)
│   └── settings.json       #    Plugin toggles
├── opencode-config/        # ← submodule: OpenCode config
│   ├── agent/              #    Subagent definitions
│   ├── command/            #    Custom slash commands
│   ├── context/            #    Context system & standards
│   ├── skill/              #    Skills (context-mode, research-first, etc.)
│   ├── tool/               #    Tool configs
│   ├── opencode.json       #    MCP server configuration
│   └── package.json        #    Plugin dependencies
├── install.sh              # Linux / macOS installer
├── install.ps1             # Windows installer (PowerShell)
└── README.md               # This guide
```

## Quick Start

### 1. Clone with submodules

```bash
git clone --recurse-submodules git@github.com:max8989/ai-coding-configs.git
cd ai-coding-configs
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### 2. Run the installer

**Linux / macOS:**
```bash
chmod +x install.sh
./install.sh
```

**Windows (PowerShell as Admin):**
```powershell
powershell -ExecutionPolicy Bypass -File install.ps1
```

### 3. Set up environment variables

```bash
cp opencode-config/env.example ~/.opencode/.env
# Edit ~/.opencode/.env with your API keys
```

### 4. Authenticate

```bash
# Claude Code
claude login

# GitHub (for MCP server)
gh auth login
# or set GITHUB_PERSONAL_ACCESS_TOKEN in your shell profile
```

---

## Platform-Specific Guide

### 🐧 Linux (Arch)

<details>
<summary>Click to expand</summary>

**Prerequisites** (auto-installed by `install.sh`):
```bash
sudo pacman -S git nodejs npm python python-pip
```

**Additional tools:**
```bash
# UV (Python package manager — used by MCP servers)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Bun (optional, faster npm alternative)
sudo pacman -S bun-bin

# AUR packages (with yay)
yay -S opencode-bin
```

**Config locations:**
| Tool | Config Path |
|------|-------------|
| Claude Code | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` |
| OpenCode | `~/.opencode/opencode.json`, `~/.opencode/skill/`, etc. |
| Project-specific | `AGENTS.md` in each repo root |

</details>

### 🐧 Linux (Ubuntu / Debian)

<details>
<summary>Click to expand</summary>

**Prerequisites:**
```bash
sudo apt-get update
sudo apt-get install -y git nodejs npm python3 python3-pip
```

**Additional tools:**
```bash
# UV
curl -LsSf https://astral.sh/uv/install.sh | sh

# Claude Code
npm install -g @anthropic-ai/claude-code

# OpenCode
npm install -g opencode
```

</details>

### 🍎 macOS

<details>
<summary>Click to expand</summary>

**Prerequisites (via Homebrew):**
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install git node python uv
```

**Install tools:**
```bash
# Claude Code
npm install -g @anthropic-ai/claude-code

# OpenCode
brew install opencode-ai/tap/opencode

# MCP servers
npm install -g context-mode
brew install github/gh-mcp-server/github-mcp-server
```

**Config locations** (same as Linux):
| Tool | Config Path |
|------|-------------|
| Claude Code | `~/.claude/CLAUDE.md`, `~/.claude/settings.json` |
| OpenCode | `~/.opencode/opencode.json`, `~/.opencode/skill/`, etc. |

</details>

### 🪟 Windows

<details>
<summary>Click to expand</summary>

**Prerequisites:**

Option A — **winget** (built into Windows 11):
```powershell
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.12
winget install Git.Git
```

Option B — **Scoop**:
```powershell
# Install scoop first
irm get.scoop.sh | iex

scoop install nodejs-lts python git
```

**Install tools:**
```powershell
npm install -g @anthropic-ai/claude-code
npm install -g opencode
npm install -g context-mode
```

**UV (Python):**
```powershell
irm https://astral.sh/uv/install.ps1 | iex
```

**Config locations:**
| Tool | Config Path |
|------|-------------|
| Claude Code | `%USERPROFILE%\.claude\CLAUDE.md` |
| OpenCode | `%USERPROFILE%\.opencode\opencode.json` |

**Note:** The install script uses symlinks, which require either:
- **Developer Mode** enabled (Settings → Privacy & Security → For Developers), or
- Running PowerShell as **Administrator**

If symlinks fail, the script falls back to copying files.

</details>

---

## How It Works

### Claude Code

Claude Code reads `~/.claude/CLAUDE.md` as **global instructions** on every session. For project-specific instructions, create an `AGENTS.md` file in each repo's root — Claude Code auto-discovers and loads it.

### OpenCode

OpenCode reads `~/.opencode/opencode.json` for MCP server configuration. Skills, commands, agents, and context definitions are loaded from their respective directories under `~/.opencode/`.

### MCP Servers

Both tools use MCP (Model Context Protocol) servers for extended capabilities:

| Server | Type | Purpose |
|--------|------|---------|
| Context7 | Remote | Documentation lookup for any library |
| Supabase | Remote | Database management |
| Figma | Remote | Design system integration |
| Chrome DevTools | Local | Browser debugging & testing |
| Git | Local | Git operations (via uvx) |
| GitHub | Local | GitHub API integration |
| context-mode | Local | Context window optimization |

## Updating

### Pull latest configs

```bash
cd ai-coding-configs
git pull
git submodule update --remote --merge
```

### Update a specific submodule

```bash
cd claude-config   # or opencode-config
git pull origin main
cd ..
git add claude-config
git commit -m "chore: update claude-config submodule"
```

## Required API Keys

| Key | Where to Get It | Used By |
|-----|-----------------|---------|
| Anthropic API / Claude login | `claude login` | Claude Code |
| `CONTEXT7_API_KEY` | [context7.com](https://context7.com) | OpenCode (Context7 MCP) |
| `SUPABASE_ACCESS_TOKEN` | [Supabase Dashboard](https://supabase.com/dashboard/account/tokens) | OpenCode (Supabase MCP) |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub Settings](https://github.com/settings/tokens) | GitHub MCP Server |

## License

MIT
