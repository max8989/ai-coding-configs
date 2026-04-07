# ============================================================================
# AI Coding Configs — Windows Install Script (PowerShell)
# Installs Claude Code + OpenCode + MCP server dependencies
# Run: powershell -ExecutionPolicy Bypass -File install.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Info    { param($msg) Write-Host "[✓] $msg" -ForegroundColor Green }
function Write-Warn    { param($msg) Write-Host "[!] $msg" -ForegroundColor Yellow }
function Write-Err     { param($msg) Write-Host "[✗] $msg" -ForegroundColor Red }
function Write-Heading { param($msg) Write-Host "`n━━━ $msg ━━━`n" -ForegroundColor Cyan }

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------------------------------------------------------------------------
# Check if a command exists
# ---------------------------------------------------------------------------
function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

# ---------------------------------------------------------------------------
# 1. Prerequisites
# ---------------------------------------------------------------------------
Write-Heading "Prerequisites"

# Check for winget or scoop
$HasWinget = Test-Command "winget"
$HasScoop  = Test-Command "scoop"

if (-not $HasWinget -and -not $HasScoop) {
    Write-Err "Neither winget nor scoop found. Install one first:"
    Write-Host "  winget: comes with Windows 11 / App Installer from Microsoft Store"
    Write-Host "  scoop:  irm get.scoop.sh | iex"
    exit 1
}

# Node.js
if (Test-Command "node") {
    Write-Info "Node.js already installed: $(node --version)"
} else {
    Write-Warn "Installing Node.js..."
    if ($HasWinget) { winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements }
    elseif ($HasScoop) { scoop install nodejs-lts }
}

# Python
if (Test-Command "python") {
    Write-Info "Python already installed: $(python --version)"
} else {
    Write-Warn "Installing Python..."
    if ($HasWinget) { winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements }
    elseif ($HasScoop) { scoop install python }
}

# Git
if (Test-Command "git") {
    Write-Info "Git already installed"
} else {
    Write-Warn "Installing Git..."
    if ($HasWinget) { winget install Git.Git --accept-package-agreements --accept-source-agreements }
    elseif ($HasScoop) { scoop install git }
}

# UV
if (Test-Command "uv") {
    Write-Info "uv already installed"
} else {
    Write-Warn "Installing uv..."
    irm https://astral.sh/uv/install.ps1 | iex
}

# ---------------------------------------------------------------------------
# 4. MCP Server Dependencies
# ---------------------------------------------------------------------------
Write-Heading "MCP Server Dependencies"

# context-mode
if (Test-Command "context-mode") {
    Write-Info "context-mode already installed"
} else {
    Write-Warn "Installing context-mode..."
    npm install -g context-mode
}

# github-mcp-server
if (Test-Command "github-mcp-server") {
    Write-Info "github-mcp-server already installed"
} else {
    Write-Warn "github-mcp-server: download from https://github.com/github/github-mcp-server/releases"
}

Write-Info "chrome-devtools-mcp runs via npx (no install needed)"
Write-Info "mcp-server-git runs via uvx (no install needed)"

# ---------------------------------------------------------------------------
# 5. Symlink configurations
# ---------------------------------------------------------------------------
Write-Heading "Symlinking Configurations"

# Claude config
$ClaudeDir = "$env:USERPROFILE\.claude"
if (-not (Test-Path $ClaudeDir)) { New-Item -ItemType Directory -Path $ClaudeDir | Out-Null }

foreach ($file in @("CLAUDE.md", "settings.json")) {
    $src = Join-Path $ScriptDir "claude\$file"
    $dst = Join-Path $ClaudeDir $file
    if (Test-Path $src) {
        if ((Test-Path $dst) -and -not (Get-Item $dst).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {
            Write-Warn "Backing up $dst → ${dst}.bak"
            Move-Item $dst "${dst}.bak" -Force
        }
        # Requires admin or developer mode for symlinks on Windows
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
            Write-Info "Linked $dst"
        } catch {
            Write-Warn "Symlink failed (need admin/dev mode). Copying instead."
            Copy-Item $src $dst -Force
            Write-Info "Copied $file to $dst"
        }
    }
}

# OpenCode config
$OpenCodeDir = "$env:USERPROFILE\.opencode"
if (-not (Test-Path $OpenCodeDir)) { New-Item -ItemType Directory -Path $OpenCodeDir | Out-Null }

foreach ($item in @("agent", "command", "context", "skill", "tool", "opencode.json", "package.json", "env.example")) {
    $src = Join-Path $ScriptDir "opencode\$item"
    $dst = Join-Path $OpenCodeDir $item
    if (Test-Path $src) {
        if ((Test-Path $dst) -and -not (Get-Item $dst).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {
            Write-Warn "Backing up $dst → ${dst}.bak"
            if (Test-Path $dst -PathType Container) {
                Rename-Item $dst "${dst}.bak" -Force
            } else {
                Move-Item $dst "${dst}.bak" -Force
            }
        }
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
            Write-Info "Linked $dst"
        } catch {
            Write-Warn "Symlink failed. Copying instead."
            if (Test-Path $src -PathType Container) {
                Copy-Item $src $dst -Recurse -Force
            } else {
                Copy-Item $src $dst -Force
            }
            Write-Info "Copied $item to $dst"
        }
    }
}

# context-mode skills (from vendor submodule → ~/.opencode/skill/)
$CtxSkillsDir = Join-Path $ScriptDir "vendor\context-mode\skills"
if (Test-Path $CtxSkillsDir) {
    foreach ($skillDir in Get-ChildItem -Directory $CtxSkillsDir) {
        $dst = Join-Path $OpenCodeDir "skill\$($skillDir.Name)"
        if ((Test-Path $dst) -and -not (Get-Item $dst).Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)) {
            Write-Warn "Backing up $dst → ${dst}.bak"
            Rename-Item $dst "${dst}.bak" -Force
        }
        try {
            New-Item -ItemType SymbolicLink -Path $dst -Target $skillDir.FullName -Force | Out-Null
            Write-Info "Linked context-mode skill: $($skillDir.Name)"
        } catch {
            Copy-Item $skillDir.FullName $dst -Recurse -Force
            Write-Info "Copied context-mode skill: $($skillDir.Name)"
        }
    }
} else {
    Write-Warn "vendor/context-mode not found — run: git submodule update --init --recursive"
}

# Install OpenCode plugins
Write-Info "Installing OpenCode plugins..."
Push-Location $OpenCodeDir
npm install --silent 2>$null
Pop-Location

# ---------------------------------------------------------------------------
# 6. Environment variables reminder
# ---------------------------------------------------------------------------
Write-Heading "Environment Variables"

Write-Host "Copy the env template and fill in your keys:"
Write-Host "  copy $ScriptDir\opencode\env.example $env:USERPROFILE\.opencode\.env"
Write-Host ""
Write-Host "Required:"
Write-Host "  CONTEXT7_API_KEY        — https://context7.com"
Write-Host "  SUPABASE_ACCESS_TOKEN   — https://supabase.com/dashboard/account/tokens"
Write-Host ""
Write-Host "Authenticate Claude Code:  claude login"
Write-Host "Authenticate GitHub:       gh auth login"

Write-Heading "Done!"
Write-Info "Restart your terminal, then run:"
Write-Host "  claude --version"
Write-Host "  opencode --version"
