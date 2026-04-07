---
name: stack-conventions
description: Preferred technology choices, naming conventions, and defaults for full-stack development with React + .NET/C#, PostgreSQL, and occasional Docker
---

## What I Do

I encode the user's preferred technology stack so the agent never asks redundant questions or makes conflicting technology choices across sessions. These are the **defaults** — the user can override any of them explicitly.

---

## Default Tech Stack

### Frontend
| Concern | Default Choice | Notes |
|---------|---------------|-------|
| Framework | React (with TypeScript) | Always TypeScript, never plain JS |
| Build tool | Vite | Not Create React App, not Webpack directly |
| Router | React Router v6+ | Use `createBrowserRouter` API |
| State (global) | Zustand | Unless Redux is explicitly requested |
| State (server) | TanStack Query (React Query) | For all API data fetching |
| Forms | React Hook Form + Zod | RHF for form state, Zod for schema validation |
| HTTP client | Axios | With interceptors for auth headers |
| Styling | CSS Modules or Tailwind CSS | Ask user which if not specified |
| Component lib | shadcn/ui (if Tailwind) | Otherwise plain CSS Modules |
| Testing | Vitest + React Testing Library + MSW | |
| Linting | ESLint + Prettier | Always include both |

### Backend (.NET / C#)
| Concern | Default Choice | Notes |
|---------|---------------|-------|
| Framework | ASP.NET Core (Minimal API or Controllers) | Ask user preference if not specified |
| Language version | Latest stable C# | Use modern features (records, pattern matching) |
| ORM | Entity Framework Core | With PostgreSQL provider |
| Auth | ASP.NET Core Identity + JWT Bearer | With refresh tokens |
| Validation | FluentValidation | Not Data Annotations |
| Logging | Serilog | Structured logging, not ILogger default |
| Mapping | Mapster | Not AutoMapper |
| API docs | Scalar (or Swagger/OpenAPI) | Include in dev environment |
| Testing | xUnit + Testcontainers | WebApplicationFactory for integration |
| Architecture | Feature folders (vertical slice) | Not strict Clean Architecture unless requested |

### Database
| Concern | Default Choice | Notes |
|---------|---------------|-------|
| Primary DB | PostgreSQL | Latest stable version |
| Local dev | Docker Compose PostgreSQL | See Docker section |
| Migrations | EF Core Migrations | Code-first approach |
| Connection | Connection string in environment variable | Never hardcoded |
| Naming | snake_case for tables/columns | EF Core snake_case naming convention |

### Docker
| Concern | Default Choice | Notes |
|---------|---------------|-------|
| Usage | Docker Compose for local dev | Not required for production by default |
| DB container | `postgres:16-alpine` | Alpine for smaller image |
| API container | `mcr.microsoft.com/dotnet/aspnet` | Runtime only in production stage |
| Frontend | Nginx in production | Or served by backend in dev |
| Network | Named bridge network | All services on same network |
| Volumes | Named volume for DB data | Persist across restarts |

---

## Naming Conventions

### C# / .NET
```csharp
// Namespaces: PascalCase matching folder structure
namespace ProjectName.Features.Users;

// Classes, methods, properties: PascalCase
public class UserService { }
public Task<User> GetUserByIdAsync(Guid id) { }
public string FirstName { get; set; }

// Private fields: _camelCase
private readonly IUserRepository _repository;

// Local variables, params: camelCase
var userId = Guid.NewGuid();

// Constants: PascalCase (not SCREAMING_SNAKE)
public const string DefaultRole = "User";

// Async methods: always suffix with Async
public async Task<Result> CreateUserAsync(CreateUserDto dto) { }

// DTOs: suffix with Dto, Request, Response
public record CreateUserRequest(string Email, string Password);
public record UserResponse(Guid Id, string Email, string FullName);
```

### React / TypeScript
```typescript
// Components: PascalCase files and function names
// UserCard.tsx → export function UserCard() {}

// Hooks: camelCase with "use" prefix
// useUserProfile.ts → export function useUserProfile() {}

// Utilities / helpers: camelCase
// formatDate.ts → export function formatDate() {}

// Types / interfaces: PascalCase, no "I" prefix
type User = { id: string; email: string }
interface ApiResponse<T> { data: T; error?: string }

// Constants: SCREAMING_SNAKE_CASE for true constants
const MAX_RETRY_COUNT = 3

// Zod schemas: camelCase with "Schema" suffix
const userSchema = z.object({ email: z.string().email() })
```

### PostgreSQL
```sql
-- Tables: snake_case, plural
CREATE TABLE users (...);
CREATE TABLE refresh_tokens (...);

-- Columns: snake_case
first_name, last_name, created_at, updated_at

-- Primary keys: id (UUID by default)
id UUID PRIMARY KEY DEFAULT gen_random_uuid()

-- Timestamps: always include both
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
```

---

## File & Folder Structure

### React App (Vite + TypeScript)
```
src/
├── assets/              # Static files (images, fonts)
├── components/          # Shared/reusable UI components
│   └── ui/              # shadcn/ui or base components
├── features/            # Feature-based modules
│   └── [feature]/
│       ├── components/  # Feature-specific components
│       ├── hooks/       # Feature-specific hooks
│       ├── api.ts       # API calls for this feature
│       ├── store.ts     # Zustand slice (if needed)
│       └── types.ts     # TypeScript types
├── hooks/               # Shared hooks
├── lib/                 # Utilities, helpers
│   ├── axios.ts         # Axios instance + interceptors
│   └── utils.ts         # General utilities
├── pages/               # Route-level page components
├── router/              # React Router config
├── store/               # Global Zustand store
├── types/               # Global TypeScript types
└── main.tsx
```

### ASP.NET Core API (Feature Folders)
```
src/
├── Features/
│   └── [Feature]/
│       ├── [Feature]Endpoints.cs    # Minimal API endpoints
│       ├── [Feature]Service.cs      # Business logic
│       ├── [Feature]Repository.cs   # DB queries
│       ├── [Feature]Dto.cs          # Request/Response records
│       └── [Feature]Validator.cs    # FluentValidation
├── Common/
│   ├── Middleware/                  # Custom middleware
│   ├── Extensions/                  # IServiceCollection extensions
│   ├── Exceptions/                  # Custom exception types
│   └── Models/                      # Shared models (Result<T>, etc.)
├── Infrastructure/
│   ├── Data/
│   │   ├── AppDbContext.cs
│   │   ├── Configurations/          # EF entity configurations
│   │   └── Migrations/
│   └── Auth/                        # JWT + Identity setup
├── Program.cs
└── appsettings.json
```

---

## Environment & Configuration

### Required `.env.example` Template
```bash
# Database
DATABASE_URL=Host=localhost;Port=5432;Database=myapp;Username=postgres;Password=postgres

# JWT
JWT_SECRET=your-very-long-secret-key-here
JWT_EXPIRY_MINUTES=60
JWT_REFRESH_EXPIRY_DAYS=7

# API
ASPNETCORE_ENVIRONMENT=Development
ASPNETCORE_URLS=http://localhost:5000

# Frontend
VITE_API_BASE_URL=http://localhost:5000
```

### Rules
- Never commit `.env` — always in `.gitignore`
- Always commit `.env.example` with all keys but no real values
- Use `IConfiguration` in .NET, `import.meta.env` in Vite

---

## Docker Compose Default Template

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  api:
    build:
      context: ./api
      dockerfile: Dockerfile
    environment:
      - DATABASE_URL=Host=db;Port=5432;Database=myapp;Username=postgres;Password=postgres
    ports:
      - "5000:5000"
    depends_on:
      db:
        condition: service_healthy

volumes:
  postgres_data:
```

---

## Override Rules

These defaults can be overridden at any time by the user stating a preference. When overriding:
1. Acknowledge the override: "Noted — using [X] instead of [default Y]"
2. Apply it consistently for the rest of the session
3. Do not revert to defaults mid-task
