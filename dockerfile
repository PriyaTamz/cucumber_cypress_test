# ---------- Stage 1: Builder ----------
FROM node:22.16.0-slim AS builder

WORKDIR /e2e

# Set Cypress cache folder
ENV CYPRESS_CACHE_FOLDER=/home/cypress/.cache/Cypress
ENV NODE_TLS_REJECT_UNAUTHORIZED=0

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci --unsafe-perm --no-audit --no-fund

# Copy Cypress project files
COPY cypress.config.js ./
COPY cypress ./cypress

# Install Cypress binary into cache
RUN npx cypress install --force


# ---------- Stage 2: Runner ----------
FROM cypress/base:22.0.0

# Create cypress user
RUN addgroup --system cypress && adduser --system --ingroup cypress cypress

WORKDIR /e2e

# Environment
ENV NODE_TLS_REJECT_UNAUTHORIZED=0
ENV PATH=/e2e/node_modules/.bin:$PATH
ENV CYPRESS_CACHE_FOLDER=/home/cypress/.cache/Cypress
ENV CYPRESS_VERIFY_DISABLE=1

# Copy app + Cypress binary cache
COPY --from=builder --chown=cypress:cypress /e2e /e2e
COPY --from=builder --chown=cypress:cypress /home/cypress/.cache /home/cypress/.cache

# Make sure user owns everything
RUN chown -R cypress:cypress /home/cypress /e2e

# Switch to non-root
USER cypress

# Debug: confirm Cypress binary exists
RUN ls -R /home/cypress/.cache/Cypress

# Default command → run in Electron
CMD ["npx", "cypress", "run", "--browser", "electron"]
