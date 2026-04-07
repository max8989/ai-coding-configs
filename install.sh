#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# AI Coding Configs — Install Script
# Installs Claude Code + OpenCode + MCP server dependencies
# Supports: Linux (Arch, Ubuntu/Debian, Fedora) and macOS
# ============================================================================

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info()    { echo -e "${GREEN}[✓]${NC} $*"; }
warn()    { echo -e "${YELLOW}[!]${NC} $*"; }
error()   { echo -e "${RED}[✗]${NC} $*" >&2; }
heading() { echo -e "\n${BOLD}━━━ $* ━━━${NC}\n"; }

# ---------------------------------------------------------------------------
# Detect OS & package manager
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if command -v pacman &>/dev/null; then
                OS="arch"; PKG="sudo pacman -S --noconfirm --needed"
            elif command -v apt-get &>/dev/null; then
                OS="debian"; PKG="sudo apt-get install -y"
            elif command -v dnf &>/dev/null; then
                OS="fedora"; PKG="sudo dnf install -y"
            else
                OS="linux"; PKG=""
            fi
            ;;
        Darwin*)
            OS="macos"
            if ! command -v brew &>/dev/null; then
                warn "Homebrew not found. Installing..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            PKG="brew install"
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            error "For Windows, see install.ps1 or the README."
            exit 1
            ;;
    esac
    info "Detected OS: ${OS}"
}

# ---------------------------------------------------------------------------
# Install a package if not already present
# ---------------------------------------------------------------------------
ensure_cmd() {
    local cmd="$1"
    local pkg="${2:-$1}"
    if command -v "$cmd" &>/dev/null; then
        info "$cmd already installed"
    else
        warn "Installing $pkg..."
        $PKG "$pkg"
    fi
}

# ---------------------------------------------------------------------------
# 1. System prerequisites
# ---------------------------------------------------------------------------
install_prerequisites() {
    heading "System Prerequisites"

    ensure_cmd git git
    ensure_cmd node nodejs
    ensure_cmd npm npm
    ensure_cmd python3 python3
    ensure_cmd pip3 python3-pip

    # UV (Python package installer — used by MCP servers)
    if ! command -v uv &>/dev/null; then
        warn "Installing uv..."
        if [[ "$OS" == "macos" ]]; then
            brew install uv
        else
            curl -LsSf https://astral.sh/uv/install.sh | sh
        fi
    else
        info "uv already installed"
    fi

    # Bun (optional but faster than npm for OpenCode plugins)
    if ! command -v bun &>/dev/null; then
        warn "Installing bun..."
        if [[ "$OS" == "macos" ]]; then
            brew install oven-sh/bun/bun
        elif [[ "$OS" == "arch" ]]; then
            $PKG bun-bin 2>/dev/null || npm install -g bun
        else
            npm install -g bun
        fi
    else
        info "bun already installed"
    fi
}

# ---------------------------------------------------------------------------
# 2. Claude Code CLI
# ---------------------------------------------------------------------------
install_claude_code() {
    heading "Claude Code CLI"

    if command -v claude &>/dev/null; then
        info "Claude Code already installed: $(claude --version 2>/dev/null || echo 'unknown')"
    else
        warn "Installing Claude Code CLI via npm..."
        npm install -g @anthropic-ai/claude-code
    fi
}

# ---------------------------------------------------------------------------
# 3. OpenCode
# ---------------------------------------------------------------------------
install_opencode() {
    heading "OpenCode"

    if command -v opencode &>/dev/null; then
        info "OpenCode already installed: $(opencode --version 2>/dev/null || echo 'unknown')"
    else
        warn "Installing OpenCode..."
        if [[ "$OS" == "arch" ]]; then
            # AUR or direct install
            if command -v yay &>/dev/null; then
                yay -S --noconfirm opencode-bin 2>/dev/null || npm install -g opencode
            else
                npm install -g opencode
            fi
        elif [[ "$OS" == "macos" ]]; then
            brew install opencode-ai/tap/opencode 2>/dev/null || npm install -g opencode
        else
            npm install -g opencode
        fi
    fi
}

# ---------------------------------------------------------------------------
# 4. MCP Server Dependencies
# ---------------------------------------------------------------------------
install_mcp_deps() {
    heading "MCP Server Dependencies"

    # context-mode (npm global)
    if command -v context-mode &>/dev/null; then
        info "context-mode already installed"
    else
        warn "Installing context-mode..."
        npm install -g context-mode
    fi

    # github-mcp-server
    if command -v github-mcp-server &>/dev/null; then
        info "github-mcp-server already installed"
    else
        warn "Installing github-mcp-server..."
        if [[ "$OS" == "macos" ]]; then
            brew install github/gh-mcp-server/github-mcp-server 2>/dev/null || go install github.com/github/github-mcp-server@latest 2>/dev/null || warn "Could not install github-mcp-server automatically. See: https://github.com/github/github-mcp-server"
        else
            go install github.com/github/github-mcp-server@latest 2>/dev/null || warn "Could not install github-mcp-server. Install Go first or download from: https://github.com/github/github-mcp-server/releases"
        fi
    fi

    # mcp-server-git (via uvx — installed on-demand, just check uv)
    if command -v uvx &>/dev/null; then
        info "uvx available (mcp-server-git will run via uvx)"
    else
        warn "uvx not found — mcp-server-git needs uv. Run: curl -LsSf https://astral.sh/uv/install.sh | sh"
    fi

    # chrome-devtools-mcp (runs via npx — no install needed)
    info "chrome-devtools-mcp runs via npx (no install needed)"
}

# ---------------------------------------------------------------------------
# 5. Symlink configurations
# ---------------------------------------------------------------------------
setup_symlinks() {
    heading "Symlinking Configurations"

    # Claude Code config
    mkdir -p "$HOME/.claude"
    for file in CLAUDE.md settings.json; do
        local src="$SCRIPT_DIR/claude/$file"
        local dst="$HOME/.claude/$file"
        if [[ -f "$src" ]]; then
            if [[ -e "$dst" && ! -L "$dst" ]]; then
                warn "Backing up existing $dst → ${dst}.bak"
                mv "$dst" "${dst}.bak"
            fi
            ln -sf "$src" "$dst"
            info "Linked $dst → $src"
        fi
    done

    # OpenCode config
    mkdir -p "$HOME/.opencode"
    for item in agent command context skill tool opencode.json package.json env.example; do
        local src="$SCRIPT_DIR/opencode/$item"
        local dst="$HOME/.opencode/$item"
        if [[ -e "$src" ]]; then
            if [[ -e "$dst" && ! -L "$dst" ]]; then
                warn "Backing up existing $dst → ${dst}.bak"
                mv "$dst" "${dst}.bak"
            fi
            ln -sf "$src" "$dst"
            info "Linked $dst → $src"
        fi
    done

    # context-mode skills (from vendor submodule → ~/.opencode/skill/)
    if [[ -d "$SCRIPT_DIR/vendor/context-mode/skills" ]]; then
        for skill_dir in "$SCRIPT_DIR/vendor/context-mode/skills"/*/; do
            local skill_name
            skill_name="$(basename "$skill_dir")"
            local dst="$HOME/.opencode/skill/$skill_name"
            if [[ -e "$dst" && ! -L "$dst" ]]; then
                warn "Backing up existing $dst → ${dst}.bak"
                mv "$dst" "${dst}.bak"
            fi
            ln -sf "$skill_dir" "$dst"
            info "Linked context-mode skill: $skill_name"
        done
    else
        warn "vendor/context-mode not found — run: git submodule update --init --recursive"
    fi

    # Install OpenCode node dependencies
    if [[ -f "$HOME/.opencode/package.json" ]]; then
        info "Installing OpenCode plugins..."
        (cd "$HOME/.opencode" && npm install --silent 2>/dev/null) || warn "npm install in ~/.opencode failed — run manually"
    fi
}

# ---------------------------------------------------------------------------
# 6. Environment variables reminder
# ---------------------------------------------------------------------------
print_env_reminder() {
    heading "Environment Variables"

    echo "Copy the env.example and fill in your keys:"
    echo ""
    echo "  cp $SCRIPT_DIR/opencode/env.example ~/.opencode/.env"
    echo ""
    echo "Required variables:"
    echo "  CONTEXT7_API_KEY        — https://context7.com"
    echo "  SUPABASE_ACCESS_TOKEN   — https://supabase.com/dashboard/account/tokens"
    echo ""
    echo "For Claude Code, authenticate with:"
    echo "  claude login"
    echo ""
    echo "For GitHub MCP, set GITHUB_PERSONAL_ACCESS_TOKEN or run:"
    echo "  gh auth login"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
    echo -e "${BOLD}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   AI Coding Configs — Installer          ║"
    echo "║   Claude Code + OpenCode + MCP Servers    ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"

    detect_os
    install_prerequisites
    install_claude_code
    install_opencode
    install_mcp_deps
    setup_symlinks
    print_env_reminder

    heading "Done!"
    info "Restart your terminal, then run:"
    echo "  claude --version"
    echo "  opencode --version"
}

main "$@"
