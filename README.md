# RegTrace

A full-stack SaaS demo implementing tenant-aware authentication, governed data models, and audit-ready reporting workflows using FastAPI, React, and cloud-ready engineering practices.

## Status

Ready for feature dev — CI and tooling setup now complete

This repo now has a working scaffold for a full-stack **FastAPI + React (TypeScript)** application, with quality gate/CI-first engineering practices prioritised immediately. The frontend is bootstrapped with placeholder app code and tests, and is already configured with **type-aware linting**, **formatting**, **TypeScript typechecking**, and **test** runners. The backend provides a minimal FastAPI service (settings/config, engine wiring, and health/readiness routes) with the same standardized workflow: **lint**, **format**, **typecheck**, and **tests**.

**Github Actions** have been configured that run the following stages when a PR is raised:

- stage 1: quality checks:
  - Linting, formatting, typecheck
- stage 2: fast tests (unit and component tests)
- stage 3: integration tests and smoke tests
  - smoke tests run against container images to confirm health and ready endpoints are accessible and happy.
- stage 4: E2E tests

<img width="1397" height="655" alt="image" src="https://github.com/user-attachments/assets/4a3d1c9f-4c67-48ac-90a6-8dcc305e9183" />


The project includes **deployment-ready Docker builds** for both apps (build/release/run separation, configuration via environment), and two development modes: a fast hot-reload loop (Vite + Uvicorn reload + Compose-managed Postgres) and a staging-analogous mode that uses compose to raise built web and api images for smoke/E2E-style validation.

A top-level **Makefile** is the single command surface for local and CI (lint/format/typecheck/tests/compose), with local dev commands that cover the same stages enforced by the CI pipeline on every PR. This makes it simple to validate code locally before PR.

With this foundation in place, the next milestone can focus purely on business logic.

## Next steps

### Feature 1 — Authentication + Tenant-Scoped Users View

This feature delivers the first vertical slice of the application: user authentication and a protected page that displays a tenant-scoped list of users. 

### Goals

- Implement OAuth2 password flow with JWT access tokens (+ refresh token rotation).
- Protect application routes behind authentication
- Provide an authenticated API endpoint to fetch users
- Display a list of users belonging only to the authenticated user’s tenant

---

## Development Philosophy

- Trunk-based development
- CI-first workflow
- Test driven development
- AWS-ready architecture

## Prerequisites

- Git
- Docker + Docker Compose
- Make
- Python 3.12+
- uv
- Node.js (via nvm)
- pnpm (via Corepack)
