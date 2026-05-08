FROM node:20-alpine

# Run as non-root user — avoids Trivy HIGH finding for root container
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /usr/src/app

# Copy manifests first so npm install layer is cached separately
COPY package.json package-lock.json* ./
RUN npm install --omit=dev && npm cache clean --force

# Copy application source (node_modules, tests, .env excluded via .dockerignore)
COPY . .

# Transfer ownership to non-root user
RUN chown -R appuser:appgroup /usr/src/app
USER appuser

EXPOSE 3000
CMD ["node", "server.js"]
