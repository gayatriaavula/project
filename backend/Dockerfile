FROM node:22-alpine

# Run as non-root user — avoids Trivy HIGH finding for root container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

# Copy manifests first so npm install layer is cached separately
COPY package.json package-lock.json* ./
RUN npm install --omit=dev --ignore-scripts && npm cache clean --force

# Copy application source (node_modules, tests, .env excluded via .dockerignore)
COPY . .

# Transfer ownership to non-root user
RUN chown -R appuser:appgroup /usr/src/app
USER appuser

EXPOSE 3000

# Health check — Trivy DS-0026 and Docker best practice
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

CMD ["node", "server.js"]
