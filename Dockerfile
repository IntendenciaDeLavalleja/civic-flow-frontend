# =======================================================
# Stage 1: Build
# Vite bakes VITE_* env vars at compile time.
# In Coolify: add VITE_API_URL as a Build Variable.
# Docker manual: --build-arg VITE_API_URL=https://api.example.com
# =======================================================
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies first (cache layer)
COPY package.json package-lock.json* ./
RUN npm ci

# Copy source code
COPY . .

# VITE_API_URL is required at build time.
# Must point to the Flask backend's public URL (e.g. https://api.civicflow.example.com/api)
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# =======================================================
# Stage 2: Serve (nginx:alpine — no Node in runtime image)
# =======================================================
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our nginx config (gzip + cache-control + SPA fallback + health check)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Coolify / Docker Healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --spider -q http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
