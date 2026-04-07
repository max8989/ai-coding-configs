---
name: greenfield-scaffolding
description: Structured process for starting new projects from scratch — proposes folder structure, confirms with user, then generates files in the right order
---

## What I Do

I prevent the most common greenfield mistake: **writing code before agreeing on structure**. For every new project or major feature from scratch, I follow a propose-confirm-generate cycle that avoids wasted rework.

## When This Skill Activates

- "Create a new project / app / service"
- "Start from scratch"
- "Set up a new [React app / ASP.NET Core API / Python service]"
- Any task where no existing codebase structure exists yet

---

## The Process

### Phase 1 — Understand Before Proposing

Ask (or infer from context) these before generating anything:

```
1. What is the app's purpose? (1 sentence)
2. Full-stack or backend-only or frontend-only?
3. Auth required? (JWT / OAuth / None)
4. Database? (PostgreSQL / SQLite / None)
5. Docker? (Yes / No / Maybe later)
6. Testing? (Unit / Integration / Both / None for now)
7. Deployment target? (Local dev / Cloud / Container)
```

If the user already answered these, skip asking and state assumptions explicitly.

### Phase 2 — Search GitHub for Reference Scaffold

Before generating any folder structure, run:

```
github-intel: search_repositories("[stack] starter template boilerplate")
```

Examples:
- `"react dotnet minimal api starter"`
- `"aspnetcore clean architecture template"`
- `"nextjs postgresql prisma starter"`

**If a good reference exists (>500 stars, recent activity):**
- Report it to user: "Found [repo] — using it as structural reference"
- Mirror its conventions, don't invent new ones

**If nothing useful found:**
- Generate structure based on stack-conventions skill defaults

### Phase 3 — Propose Structure First

**Present the full folder tree BEFORE writing any files.** Format:

```
## Proposed Project Structure

[project-name]/
├── src/
│   ├── [Feature1]/
│   │   ├── [Feature1]Controller.cs
│   │   ├── [Feature1]Service.cs
│   │   └── [Feature1]Repository.cs
│   └── Common/
│       ├── Middleware/
│       └── Extensions/
├── tests/
│   ├── Unit/
│   └── Integration/
├── docker-compose.yml          ← included because Docker: Yes
├── .env.example
├── README.md
└── [project].sln

## Key Decisions
- Pattern: [Repository pattern / Clean Architecture / Minimal API]
- Auth: [JWT with ASP.NET Identity / None]
- ORM: [EF Core / Dapper / None]
- Test framework: [xUnit / NUnit]

## What I'll generate first
1. Solution + project files
2. Core domain models
3. Database context + migrations
4. Auth setup
5. CRUD endpoints
6. Test project scaffold
7. Docker + environment files

Shall I proceed with this structure, or would you like to adjust anything?
```

**Wait for user confirmation before writing any files.**

### Phase 4 — Generate in Order

Once confirmed, generate files in this sequence (never random order):

#### For Full-Stack (React + .NET)

```
1. Solution / workspace root files (.gitignore, README, .env.example)
2. Backend project scaffold (*.csproj / Program.cs / appsettings.json)
3. Database layer (DbContext, entities, initial migration)
4. Auth layer (if required)
5. Feature modules (controllers → services → repositories)
6. Frontend scaffold (Vite + React + TypeScript config)
7. Frontend structure (pages → components → hooks → api layer)
8. Docker Compose (if required)
9. Test projects (mirrors backend structure)
10. CI/CD config (if required)
```

#### For Backend Only (.NET API)

```
1. Solution + project files
2. Program.cs + middleware pipeline
3. Database layer
4. Auth (if required)
5. Feature modules
6. Tests
7. Docker + environment
```

#### For Frontend Only (React)

```
1. Vite + React + TypeScript init config
2. Folder structure (pages, components, hooks, lib, types)
3. Router setup
4. API client layer
5. Auth context (if required)
6. Shared UI components scaffold
7. Test setup (Vitest + Testing Library)
```

### Phase 5 — Handoff Summary

After all files are generated:

```markdown
## Project Ready ✓

**Structure created**: [X files across Y directories]
**Next steps**:
1. `cd [project-name]`
2. [install command]
3. Copy `.env.example` → `.env` and fill in values
4. [run command]

**What's not yet implemented** (intentionally left for you):
- [ ] Business logic in service layer stubs
- [ ] UI design / styling
- [ ] Production deployment config
```

---

## Boilerplate Templates by Type

### Auth Boilerplate (.NET JWT)
- Always use `Microsoft.AspNetCore.Authentication.JwtBearer` (no custom)
- Store secret in environment variable, never in `appsettings.json`
- Include refresh token endpoint stub
- Reference: search GitHub for `aspnetcore-jwt-refresh-token` before writing

### Auth Boilerplate (React client side)
- Auth context with `useAuth` hook
- Protected route wrapper component
- Token stored in `httpOnly` cookie (never `localStorage`)
- Axios/fetch interceptor for automatic token refresh

### Test Boilerplate (.NET)
- xUnit as default
- One test project per layer (Unit / Integration)
- Use `WebApplicationFactory` for integration tests
- Testcontainers for PostgreSQL in integration tests

### Test Boilerplate (React)
- Vitest + React Testing Library as default
- `render` + `screen` + `userEvent` pattern
- MSW (Mock Service Worker) for API mocking

---

## Never Do These

- ❌ Start writing feature code before folder structure is confirmed
- ❌ Mix concerns (put business logic in controllers, UI logic in pages)
- ❌ Generate all files at once without the propose → confirm step
- ❌ Invent a folder structure when a well-known reference exists on GitHub
- ❌ Skip `.env.example` — always create it alongside `.env` (never commit `.env`)
- ❌ Skip `.gitignore` — always create it as the very first file
