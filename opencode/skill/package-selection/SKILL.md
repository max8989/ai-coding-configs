---
name: package-selection
description: Structured process for finding, evaluating, and recommending packages/libraries before installation — always presents options to user before proceeding
---

## What I Do

I enforce a **research → evaluate → present → confirm** cycle for every package decision. No package is installed or added to a project without going through this process. The user always makes the final call.

## When This Skill Activates

- Any mention of adding a dependency (npm install, dotnet add package, pip install, etc.)
- Any feature that likely requires a third-party library
- Any time the user asks "what should I use for X?"

---

## The Process

### 1. Identify Need

Clearly state what capability is needed before searching:

```
Need: [one sentence — e.g. "HTTP client with retry logic for .NET"]
Context: [runtime, framework version, existing deps]
```

### 2. Search GitHub Intel

```
search_repositories("[ecosystem] [capability keyword]")
```

Run 2-3 searches with different keyword angles. Collect top candidates.

### 3. Evaluate Each Candidate

For each candidate, gather:

| Signal | How to get it | Threshold |
|--------|--------------|-----------|
| Stars | `get_repository_info` | >500 good, >2k established |
| Last commit | `get_repository_info` | < 6 months = active |
| Open issues | `list_issues` | Check for critical/breaking bugs |
| NuGet/npm downloads | Chrome DevTools → registry page | High downloads = battle-tested |
| Context7 docs | `resolve-library-id` → check snippet count | More snippets = better documented |

### 4. Check Official Registry (if needed)

Use Chrome DevTools MCP to check:
- **npm**: npmjs.com/package/[name] — weekly downloads, dependents
- **NuGet**: nuget.org/packages/[name] — total downloads, version history
- **PyPI**: pypi.org/project/[name] — download stats, classifiers

### 5. Present Options to User

**Always present exactly 2-3 options** in this format — never just one, never more than three:

```markdown
## Package Options for [Need]

### Option 1 — [Package Name] ⭐ RECOMMENDED
- **Repo**: owner/repo (⭐ X stars, last commit: X months ago)
- **Why**: [1-2 sentences on why it fits]
- **Tradeoff**: [honest downside]
- **Install**: `npm install package-name`

### Option 2 — [Package Name]
- **Repo**: owner/repo (⭐ X stars)
- **Why**: [1-2 sentences]
- **Tradeoff**: [downside]
- **Install**: `npm install package-name`

### Option 3 — [Package Name] (lightweight alternative)
- **Repo**: owner/repo (⭐ X stars)
- **Why**: [1-2 sentences]
- **Tradeoff**: [downside]
- **Install**: `npm install package-name`

**My recommendation: Option 1** because [brief reason tied to project context].
Which would you like to use?
```

### 6. Wait for User Confirmation

**Do NOT proceed with installation until the user picks an option.**

After confirmation:
1. Run the install command
2. Verify install succeeded (check package.json / .csproj / requirements.txt)
3. Pull docs via Context7 before writing integration code

---

## Ecosystem-Specific Notes

### React / Frontend (npm/yarn/pnpm)
- Prefer packages with TypeScript types included (not `@types/...` separate)
- Check bundle size via bundlephobia.com (Chrome DevTools) for UI libs
- Prefer packages compatible with current React version

### .NET / C# (NuGet)
- Check if the package targets the correct .NET version (net8.0, net9.0, etc.)
- Prefer Microsoft-authored packages for core concerns (auth, logging, DI)
- Check for `nullable` and `implicit usings` compatibility

### Python (pip/uv)
- Check Python version compatibility (>=3.10 preferred)
- Prefer packages with type stubs or inline types
- Check if actively maintained (many Python libs go stale)

---

## Never Do These

- ❌ Install a package without presenting options first
- ❌ Pick a package solely from training data without GitHub/Context7 check
- ❌ Install multiple packages at once without explaining each
- ❌ Add a package that duplicates something already in the project's dependencies
- ❌ Recommend a package with no recent commits (> 18 months abandoned)

---

## Example

```
User: "I need to add form validation to the React app"

1. Need: "Client-side form validation with TypeScript support for React"
2. GitHub search: "react form validation typescript"
3. Candidates found: react-hook-form, formik, zod + react-hook-form
4. Evaluated: RHF (35k⭐, 2 weeks ago), Formik (33k⭐, 8 months ago)
5. Presented 3 options with recommendation
6. User picks react-hook-form
7. Context7: resolve react-hook-form → query "register, handleSubmit, validation"
8. Write integration code
```
