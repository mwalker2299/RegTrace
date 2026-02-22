#!/usr/bin/env bash
set -euo pipefail

shopt -s globstar nullglob

echo "Checking for E2E tests..."

if ! compgen -G "e2e/**/*.spec.*" > /dev/null && \
   ! compgen -G "e2e/**/*.test.*" > /dev/null; then
  echo "No E2E tests found; skipping E2E stage."
  exit 0
fi

echo "E2E tests detected."
if [ "${E2E_SKIP_INSTALL:-}" != "1" ]; then
  pnpm install --frozen-lockfile
  pnpm e2e:install
fi
pnpm e2e:run