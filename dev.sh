#!/bin/bash
# Local Development Helper Script
# Usage: ./dev.sh [command] [service]

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Load local environment
export $(grep -v '^#' .env.local | xargs)

# Available services
SERVICES=("user_svc" "job_svc" "email_svc" "image_svc" "client_svc")

print_help() {
  echo -e "${BLUE}Local Development Helper${NC}"
  echo ""
  echo "Usage: ./dev.sh [command] [service]"
  echo ""
  echo "Commands:"
  echo "  start [service]   - Start a service with iex (interactive)"
  echo "  run [service]     - Run a service in foreground"
  echo "  test [service]    - Run tests for a service"
  echo "  deps              - Install dependencies for all services"
  echo "  compile           - Compile all services"
  echo "  migrate           - Run migrations for all services"
  echo "  clean             - Clean build artifacts"
  echo "  infra             - Start infrastructure (MinIO)"
  echo "  stop-infra        - Stop infrastructure"
  echo "  status            - Show running processes"
  echo ""
  echo "Services: ${SERVICES[*]}"
  echo ""
  echo "Examples:"
  echo "  ./dev.sh infra              # Start MinIO"
  echo "  ./dev.sh start user_svc     # Start user service with IEx"
  echo "  ./dev.sh test job_svc       # Run job_svc tests"
  echo "  ./dev.sh deps               # Install deps for all services"
}

start_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo -e "${RED}Error: Service name required${NC}"
    echo "Available services: ${SERVICES[*]}"
    exit 1
  fi

  echo -e "${GREEN}Starting $service with IEx...${NC}"
  cd "apps/$service"
  iex -S mix
}

run_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo -e "${RED}Error: Service name required${NC}"
    exit 1
  fi

  echo -e "${GREEN}Running $service...${NC}"
  cd "apps/$service"
  mix run --no-halt
}

test_service() {
  local service=$1
  if [ -z "$service" ]; then
    echo -e "${YELLOW}Running all tests...${NC}"
    mix test
  else
    echo -e "${YELLOW}Testing $service...${NC}"
    cd "apps/$service"
    mix test
  fi
}

install_deps() {
  echo -e "${GREEN}Installing dependencies for all services...${NC}"
  for service in "${SERVICES[@]}"; do
    echo -e "${BLUE}→ $service${NC}"
    (cd "apps/$service" && mix deps.get)
  done
}

compile_all() {
  echo -e "${GREEN}Compiling all services...${NC}"
  for service in "${SERVICES[@]}"; do
    echo -e "${BLUE}→ $service${NC}"
    (cd "apps/$service" && mix compile)
  done
}

run_migrations() {
  echo -e "${GREEN}Running migrations...${NC}"
  # Only services with databases
  for service in "user_svc" "job_svc"; do
    echo -e "${BLUE}→ $service${NC}"
    (cd "apps/$service" && mix ecto.migrate)
  done
}

clean_all() {
  echo -e "${YELLOW}Cleaning build artifacts...${NC}"
  for service in "${SERVICES[@]}"; do
    echo -e "${BLUE}→ $service${NC}"
    (cd "apps/$service" && mix clean)
  done
}

start_infra() {
  echo -e "${GREEN}Starting infrastructure (MinIO)...${NC}"
  docker compose up -d
  echo -e "${GREEN}✓ MinIO started${NC}"
  echo -e "${BLUE}MinIO Console: http://localhost:9001${NC}"
  echo -e "${BLUE}Credentials: minioadmin / minioadmin${NC}"
}

stop_infra() {
  echo -e "${YELLOW}Stopping infrastructure...${NC}"
  docker compose down
}

show_status() {
  echo -e "${BLUE}Infrastructure Status:${NC}"
  docker compose ps
  echo ""
  echo -e "${BLUE}Running Elixir Processes:${NC}"
  ps aux | grep -E "beam|iex" | grep -v grep || echo "No Elixir processes running"
}

# Main command handler
case "$1" in
  start)
    start_service "$2"
    ;;
  run)
    run_service "$2"
    ;;
  test)
    test_service "$2"
    ;;
  deps)
    install_deps
    ;;
  compile)
    compile_all
    ;;
  migrate)
    run_migrations
    ;;
  clean)
    clean_all
    ;;
  infra)
    start_infra
    ;;
  stop-infra)
    stop_infra
    ;;
  status)
    show_status
    ;;
  help|--help|-h|"")
    print_help
    ;;
  *)
    echo -e "${RED}Unknown command: $1${NC}"
    print_help
    exit 1
    ;;
esac
