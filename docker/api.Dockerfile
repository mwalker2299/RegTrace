# syntax=docker/dockerfile:1.7

############################
# Builder: create /app/.venv
############################
FROM python:3.12-slim AS builder

# Copy uv binary in (pinned to 0.10.4 for reproducible builds)
COPY --from=ghcr.io/astral-sh/uv:0.10.4 /uv /uvx /bin/

WORKDIR /app

# Production install settings
ENV UV_NO_DEV=1 \
  UV_COMPILE_BYTECODE=1 \
  UV_LINK_MODE=copy

# 1) Copy only dependency metadata first (stable layer)
COPY backend/pyproject.toml backend/uv.lock ./

# 2) Install ONLY dependencies (not the project) for better Docker caching
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked --no-install-project

# 3) Now copy the rest of the backend source
COPY backend/ ./

# 4) Sync again to install the project into the venv
RUN --mount=type=cache,target=/root/.cache/uv \
  uv sync --locked

############################
# Runtime: minimal image
############################
FROM python:3.12-slim AS runtime

# Create non-root user
RUN useradd -m -u 10001 app
WORKDIR /app

# Copy app + venv from builder
COPY --from=builder --chown=app:app /app /app

ENV PATH="/app/.venv/bin:$PATH" \
  PYTHONUNBUFFERED=1

USER app
EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]