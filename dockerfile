### ---------- Stage 1: Builder ----------
FROM node:22.16.0-slim AS builder

# Set working directory
WORKDIR /e2e

# Set Cypress cache path to match what Cypress expects later
ENV CYPRESS_CACHE_FOLDER=/root/.cache/Cypress
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Disable strict SSL for self-signed certs
RUN npm config set strict-ssl false

# Copy dependency definitions
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci --unsafe-perm --no-audit --no-fund

# Copy Cypress config and tests
COPY cypress.config.js ./
COPY cypress/ ./cypress/

# Install Cypress binary into /root/.cache/Cypress
RUN npx cypress install


### ---------- Stage 2: Runner ----------
FROM cypress/browsers:node-22.16.0-chrome-137.0.7151.68-1-ff-139.0.1-edge-137.0.3296.62-1

# Set working directory
WORKDIR /e2e

# Copy app + Cypress cache from builder
COPY --from=builder /e2e /e2e
COPY --from=builder /root/.cache/Cypress /root/.cache/Cypress

# Set env variables
ENV NODE_TLS_REJECT_UNAUTHORIZED=0
ENV PATH=/e2e/node_modules/.bin:$PATH
ENV CYPRESS_CACHE_FOLDER=/root/.cache/Cypress

# Optional debug: confirm binary exists
RUN ls -l /root/.cache/Cypress/*/Cypress

# Default command
CMD ["npx", "cypress", "run"]
