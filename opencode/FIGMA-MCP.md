# Figma Remote MCP — OpenCode Setup

## Why this is needed

Figma maintains a **client whitelist** for their remote MCP server. OpenCode is not on it yet
(pending approval as of March 2026). The standard `opencode mcp auth figma` command fails with:

```
HTTP 403: Invalid OAuth error response: SyntaxError: JSON Parse error:
Unexpected identifier "Forbidden". Raw body: Forbidden
```

**Root cause:** Figma rejects OpenCode's OAuth Dynamic Client Registration (RFC 7591) because
`opencode` is not a whitelisted client name. The fix is to authenticate once using a patched
fork that spoofs the client name as a whitelisted one — the resulting tokens are cached and
your normal `opencode` binary uses them transparently.

> Tracking issue: https://github.com/anomalyco/opencode/issues/5636
> Workaround credit: https://github.com/connorads/opencode/tree/mcp-auth-workaround

---

## Step 1 — Add Figma to opencode.json

In `~/.config/opencode/opencode.json` (or your dotfiles equivalent):

```json
{
  "mcp": {
    "figma": {
      "type": "remote",
      "url": "https://mcp.figma.com/mcp",
      "enabled": true
    }
  }
}
```

---

## Step 2 — One-time OAuth via the workaround fork

```bash
git clone -b mcp-auth-workaround https://github.com/connorads/opencode.git ~/repos/opencode-mcp-auth
cd ~/repos/opencode-mcp-auth
bun install
bun dev mcp auth figma
```

This opens your browser → Figma OAuth page → click **Allow access**.

Tokens are saved to `~/.local/share/opencode/mcp-auth.json` — your normal `opencode`
picks them up automatically. You never need the fork again (unless tokens expire).

---

## Step 3 — Restart OpenCode

Restart `opencode` and the Figma MCP should connect successfully.

---

## Re-authentication (if tokens expire)

Just repeat Step 2:

```bash
cd ~/repos/opencode-mcp-auth
bun dev mcp auth figma
```

---

## Usage

The Figma MCP is **link-based**. In OpenCode, paste a Figma URL and prompt:

```
Implement this component: https://figma.com/file/xxxx?node-id=1-2
```

To get a node URL from Figma: right-click any layer → **Copy link to selection**.

---

## Status

- [ ] OpenCode whitelisted by Figma natively (pending — no ETA from Figma as of March 2026)
- [x] Workaround functional via `connorads/opencode` fork
