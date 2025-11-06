# Local Development Guide

Fast local development without Docker containers (except MinIO for S3 storage).

## Quick Start

```bash
# 1. Start infrastructure (MinIO only)
./dev.sh infra

# 2. Compile all services
./dev.sh compile

# 3. Start a service interactively
./dev.sh start user_svc

# 4. In another terminal, start job_svc
./dev.sh start job_svc
```

## Why Local Development?

- **10x faster iteration** - No container rebuilds for code changes
- **Better debugging** - Direct access to IEx REPL
- **Easier testing** - Run tests instantly without Docker overhead
- **Live reload** - Code changes picked up immediately

## Environment Files

- `.env.local` - Local development (services on localhost)
- `.env.staging` - Docker environment (services use container names)
- `.env.example` - Template

## Dev Script Commands

```bash
./dev.sh help              # Show all commands
./dev.sh status            # Show running services
./dev.sh infra             # Start MinIO
./dev.sh stop-infra        # Stop MinIO
./dev.sh compile           # Compile all services
./dev.sh start user_svc    # Start service with IEx
./dev.sh test job_svc      # Run tests
```

## Running Services Manually

If you prefer not to use the dev script:

```bash
# Start infrastructure
docker compose up -d

# Export environment variables
export $(grep -v '^#' .env.local | xargs)

# Start a service
cd apps/user_svc
iex -S mix

# Or run without IEx
mix run --no-halt
```

## Service Ports

| Service | Port | URL |
|---------|------|-----|
| user_svc | 8081 | http://localhost:8081 |
| job_svc | 8082 | http://localhost:8082 |
| email_svc | 8083 | http://localhost:8083 |
| image_svc | 8084 | http://localhost:8084 |
| client_svc | 8085 | http://localhost:8085 |
| MinIO API | 9000 | http://localhost:9000 |
| MinIO Console | 9001 | http://localhost:9001 |

## Testing the Setup

```bash
# 1. Start MinIO
./dev.sh infra

# 2. Start user_svc in terminal 1
./dev.sh start user_svc

# 3. In IEx, test the service
iex> Client.health()
:ok

# 4. Create a user
iex> Client.create(1)
{:ok, %{status: 201, body: %{"id" => "1", ...}}}
```

## Full Stack vs Local Dev

### Local Dev (Current Setup)
- **Infrastructure**: MinIO only (Docker)
- **Services**: Run locally with `iex -S mix`
- **Speed**: Very fast
- **Use for**: Development, testing, debugging

### Full Stack (docker-compose-all.yml)
- **Infrastructure**: MinIO, Prometheus, Grafana, Loki, Jaeger
- **Services**: All in Docker containers
- **Speed**: Slower (container rebuilds)
- **Use for**: Integration testing, production simulation

To switch to full stack:
```bash
# Use the full docker-compose file
docker compose -f docker-compose-all.yml up -d
```

## Troubleshooting

### Port Already in Use
```bash
# Find and kill process on port
lsof -ti:8081 | xargs kill -9
```

### MinIO Not Accessible
```bash
./dev.sh status  # Check if MinIO is running
./dev.sh infra   # Restart if needed
```

### Services Can't Find Each Other
Make sure all services are using `127.0.0.1` (from `.env.local`), not Docker service names.

### Database Issues
```bash
# Reset job_svc database
cd apps/job_svc
rm -rf db/
mix ecto.create
mix ecto.migrate
```

## Next Steps

- See [TESTING.md](TESTING.md) for testing guide (coming soon)
- See [OPENAPI.md](openapi/README.md) for API specs
- See [README.md](README.md) for architecture overview
