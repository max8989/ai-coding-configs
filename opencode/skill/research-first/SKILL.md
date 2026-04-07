---
name: research-first
description: Mandatory research workflow before writing any code — uses Context7, GitHub Intel, and Chrome DevTools MCPs in order
---

## What I Do

I enforce a **research-before-code** discipline. Before any implementation starts, I run a structured lookup sequence using available MCP tools to find existing solutions, read accurate docs, and avoid reinventing the wheel.

## Mandatory Workflow

**Always follow this exact order. Do NOT skip steps.**

### Step 1 — Look Up Docs (Context7 MCP)

Use this whenever a library, framework, or package is involved.

```
1. Call resolve-library-id with the library name and task context
2. Call query-docs with the resolved ID and a specific question
3. Extract relevant API signatures, config options, or usage patterns
4. Summarize findings before proceeding to code
```

**Trigger conditions:**
- Any import or `using` statement being written
- Any npm, NuGet, pip, or cargo package being used
- Any framework-specific feature (React hooks, ASP.NET middleware, EF Core, etc.)

**Never rely on training data alone for:**
- Package APIs (they change between versions)
- Framework configuration options
- CLI command syntax

---

### Step 2 — Search GitHub for Existing Solutions (GitHub Intel MCP)

Use this before writing any non-trivial code block.

```
1. Call search_repositories with relevant keywords
2. Filter by: stars > 100, updated within last 12 months
3. Call get_repository_info on top 2-3 results to assess quality
4. If a good reference exists: study its structure before implementing
5. Report findings to the user: "Found X — I'll use it as reference"
```

**What to search for:**
- Starter templates / boilerplate repos
- Reference implementations of auth flows, CRUD patterns, etc.
- Config examples for tools (Docker Compose, CI/CD, etc.)

**Quality signals to check:**
- ⭐ Stars (>500 = established, >2000 = widely adopted)
- 🕐 Last commit (< 6 months = actively maintained)
- 🐛 Open issues ratio (many unresolved = risky)
- 📄 Has README + license

---

### Step 3 — Open Browser as Last Resort (Chrome DevTools MCP)

Use only when Steps 1 and 2 did not yield sufficient information.

```
1. Navigate to the official docs URL or GitHub issue thread
2. Take a snapshot to read the content
3. Extract the specific answer needed
4. Close the tab when done
```

**Valid use cases:**
- Official changelogs not in Context7
- Specific GitHub issue discussions / workarounds
- Community forum answers (Stack Overflow, Reddit r/dotnet etc.)
- Package comparison sites (npmjs.com, nuget.org)

**Do NOT use the browser for:**
- Things Context7 already answered
- General "how does X work" questions (use Context7)

---

## Decision Tree

```
Need info about a library/framework?
        │
        ▼
  [Context7 MCP] ──── Found answer? ──► Use it, proceed
        │
        NO
        ▼
  [GitHub Intel MCP] ── Found reference repo? ──► Study it, proceed
        │
        NO
        ▼
  [Chrome DevTools MCP] ──── Found answer? ──► Use it, proceed
        │
        NO
        ▼
  Ask the user for clarification
```

---

## Reporting Format

After completing research, always summarize before coding:

```
## Research Summary
- **Docs consulted**: [library name] via Context7 — [key finding]
- **Reference repo**: [owner/repo] (⭐ X stars) — [what was borrowed]
- **Browser lookup**: [URL] — [specific answer found]

## Plan
[What I'm about to implement based on the above]
```

Never silently proceed to code without this summary.

---

## Examples

### Good
```
User: "Add JWT auth to the ASP.NET Core API"

1. Context7: resolve Microsoft.AspNetCore.Authentication.JwtBearer → query middleware setup
2. GitHub: search "aspnetcore jwt auth minimal api" → found dotnet/aspnetcore-samples
3. Summary: "Using AddAuthentication().AddJwtBearer() pattern from official samples"
→ Write code
```

### Bad
```
User: "Add JWT auth to the ASP.NET Core API"
→ Write code immediately from memory
```
