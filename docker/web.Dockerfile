# ---- Build stage (Vite) ----
FROM node:22-alpine AS build
WORKDIR /app

# 1) Enable pnpm (pinned to 10.30.1 for reproducibility)
RUN corepack enable
RUN corepack prepare pnpm@10.30.1 --activate

# 2) Copy workspace root files first
COPY pnpm-lock.yaml pnpm-workspace.yaml ./

# 3) Copy only the frontend manifest for dependency layer caching
COPY frontend/package.json ./frontend/package.json

# 4) Install deps
RUN pnpm install --frozen-lockfile --filter ./frontend...

# 5) Copy the rest of the frontend source
COPY frontend/ ./frontend/

# Vite env vars
ARG VITE_API_BASE=/api/v1
ENV VITE_API_BASE=${VITE_API_BASE}

# 6) Build
WORKDIR /app/frontend
RUN pnpm build

# ---- Runtime stage (Nginx) ----
FROM nginx:1.28-alpine AS runtime
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/frontend/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]