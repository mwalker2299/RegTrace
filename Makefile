# Single command surface for local + CI
SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c

BACKEND_DIR := backend
FRONTEND_PROJECT_NAME := frontend

UV_SYNC_FLAGS ?=
PNPM_INSTALL_FLAGS ?=

API_BASE ?= http://localhost:8000
WEB_BASE ?= http://localhost:8090

CURL_SMOKE = curl -fsS \
	--retry 30 --retry-delay 1 --retry-connrefused \
	--connect-timeout 2 --max-time 5

COMPOSE_DEV := docker compose
COMPOSE_CI  := docker compose -f docker-compose.ci.yml

.PHONY: help
help:
	@echo "Targets:"
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*## "}{printf "  %-24s %s\n", $$1, $$2}'

# ---------------- Prerequisite checks ----------------
.PHONY: prereq-check

prereq-check:
	@echo "Checking prerequisites..."

	@command -v docker >/dev/null 2>&1 || (echo "❌ docker not installed"; exit 1)
	@command -v uv >/dev/null 2>&1 || (echo "❌ uv not installed"; exit 1)
	@command -v python3 >/dev/null 2>&1 || (echo "❌ python3 not installed"; exit 1)
	@command -v node >/dev/null 2>&1 || (echo "❌ node not installed"; exit 1)
	@command -v pnpm >/dev/null 2>&1 || (echo "❌ pnpm not installed"; exit 1)
	

	@echo "Tools present"

	@echo "Node version:"
	@node -v

	@echo "pnpm version:"
	@pnpm -v

	@echo "uv version:"
	@uv --version

	@echo "Python version:"
	@python3 --version

	@echo "Docker version:"
	@docker --version

	@echo "Pre-requisites met"

# ---------------- Bootstrap ----------------
.PHONY: bootstrap bootstrap-env bootstrap-backend bootstrap-frontend
bootstrap: bootstrap-env bootstrap-backend bootstrap-frontend ## Setup everything

bootstrap-env: ## copy .env.example -> .env if missing
	@test -f .env || (cp .env.example .env && echo "Created .env from .env.example")

bootstrap-backend: ## uv sync
	cd $(BACKEND_DIR)
	uv sync $(UV_SYNC_FLAGS)

bootstrap-frontend: ## pnpm install
	pnpm -F $(FRONTEND_PROJECT_NAME) install $(PNPM_INSTALL_FLAGS)

# ---------------- Leaf: format ----------------
.PHONY: fmt fmt-backend fmt-frontend
fmt: fmt-backend fmt-frontend ## Format all

fmt-backend: ## ruff format
	cd $(BACKEND_DIR)
	uv run ruff format .

fmt-frontend: ## prettier write
	pnpm -F $(FRONTEND_PROJECT_NAME) format

# ---------------- Leaf: fmt-check ----------------
.PHONY: fmt-check fmt-check-backend fmt-check-frontend
fmt-check: fmt-check-backend fmt-check-frontend ## Check formatting

fmt-check-backend: ## ruff format --check
	cd $(BACKEND_DIR)
	uv run ruff format --check .

fmt-check-frontend: ## prettier --check
	pnpm -F $(FRONTEND_PROJECT_NAME) format:check

# ---------------- Leaf: lint ----------------
.PHONY: lint lint-backend lint-frontend
lint: lint-backend lint-frontend ## Lint all

lint-backend: ## ruff check
	cd $(BACKEND_DIR)
	uv run ruff check .

lint-frontend: ## eslint
	pnpm -F $(FRONTEND_PROJECT_NAME) lint

# ---------------- Leaf: typecheck ----------------
.PHONY: typecheck typecheck-backend typecheck-frontend
typecheck: typecheck-backend typecheck-frontend ## Typecheck all

typecheck-backend: ## pyright
	cd $(BACKEND_DIR)
	uv run pyright

typecheck-frontend: ## tsc --noEmit
	pnpm -F $(FRONTEND_PROJECT_NAME) typecheck

# ---------------- Leaf: tests ----------------
.PHONY: test-unit test-unit-backend test-unit-frontend
test-unit: test-unit-backend test-unit-frontend ## Unit tests

test-unit-backend: ## pytest unit (no DB)
	cd $(BACKEND_DIR)
	uv run pytest app/tests/unit

test-unit-frontend: ## vitest unit
	pnpm -F $(FRONTEND_PROJECT_NAME) test:unit

.PHONY: test-component test-component-backend test-component-frontend
test-component: test-component-backend test-component-frontend ## Component tests

test-component-backend: ## pytest component (no DB)
	cd $(BACKEND_DIR)
	uv run pytest app/tests/component

test-component-frontend: ## RTL/component tests
	pnpm -F $(FRONTEND_PROJECT_NAME) test:component

.PHONY: test-integration test-integration-backend test-integration-frontend
test-integration: test-integration-backend test-integration-frontend ## Integration tests

test-integration-backend: ## pytest integration (requires Postgres)
	$(COMPOSE_DEV) up -d
	cd $(BACKEND_DIR)
	uv run pytest app/tests/integration
	$(COMPOSE_DEV) down -v

test-integration-backend-ci: ## pytest integration for CI (assumes DB already up)
	cd $(BACKEND_DIR)
	uv run pytest app/tests/integration

test-integration-frontend: ## mocked integration (MSW)
	pnpm -F $(FRONTEND_PROJECT_NAME) test:integration

# ---------------- Image build ----------------
.PHONY: build-images build-api build-web
build-images: build-api build-web ## Build container images

build-api: ## docker build -t regtrace-api ...
	DOCKER_BUILDKIT=1 docker build -t regtrace-api -f docker/api.Dockerfile .

build-web: ## docker build -t regtrace-web ...
	docker build -t regtrace-web -f docker/web.Dockerfile .

# ---------------- Compose ----------------
.PHONY: db-up db-down compose-up-ci compose-down-ci
db-up: ## docker compose up -d (dev - postgres only)
	$(COMPOSE_DEV) up -d

db-down: ## docker compose down -v
	$(COMPOSE_DEV) down -v

compose-up-ci: ## docker compose -f docker-compose.ci.yml up -d --build
	$(COMPOSE_CI) up -d --build

compose-down-ci: ## docker compose -f docker-compose.ci.yml down -v
	$(COMPOSE_CI) down -v

# ---------------- Local Dev (Hot Reload) ----------------
dev-api: ## uvicorn dev server
	cd $(BACKEND_DIR)
	uv run uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

dev-web: ## Vite dev server
	pnpm -F $(FRONTEND_PROJECT_NAME) dev

# ---------------- Smoke checks ----------------
.PHONY: smoke smoke-api-health smoke-api-ready smoke-web-root smoke-web-proxy-api
smoke: smoke-api-health smoke-api-ready smoke-web-root smoke-web-proxy-api ## Run smoke checks

smoke-api-health: ## curl /healthz == 200
	$(CURL_SMOKE) $(API_BASE)/healthz > /dev/null

smoke-api-ready: ## curl /readyz == 200
	$(CURL_SMOKE) $(API_BASE)/readyz > /dev/null

smoke-web-root: ## curl / == 200
	$(CURL_SMOKE) $(WEB_BASE)/ > /dev/null

smoke-web-proxy-api: ## curl /api/v1/healthz == 200 (verifies web -> api proxy is working)
	$(CURL_SMOKE) $(WEB_BASE)/api/v1/healthz > /dev/null

# ---------------- E2E ----------------
.PHONY: e2e e2e-playwright
e2e: e2e-playwright ## Run E2E

e2e-playwright: ## playwright test
	pnpm -F $(FRONTEND_PROJECT_NAME) e2e:run

# ---------------- CI stage groups ----------------
.PHONY: ci-stage1 ci-stage2 ci-stage3 ci-stage4 ci

ci-stage1: fmt-check lint typecheck ## Quality gates (fast)

ci-stage2: test-unit test-component ## Unit + component tests

ci-stage3: test-integration ## Integration tests

ci-stage4: build-images compose-up-ci smoke e2e compose-down-ci ## Build + smoke + E2E

ci: ci-stage1 ci-stage2 ci-stage3 ci-stage4 ## Full local CI run