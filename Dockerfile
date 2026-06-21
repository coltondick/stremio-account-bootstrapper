# Build stage
FROM node:22-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copy dependency files first for better layer caching
COPY package.json pnpm-lock.yaml ./

# Install dependencies (ignore-scripts to skip husky setup which needs .git)
RUN pnpm install --frozen-lockfile --ignore-scripts

# Copy source code
COPY . .

# Build the application
RUN pnpm run build

# Production stage
FROM nginx:stable-alpine AS production

# Copy nginx config and built assets
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
