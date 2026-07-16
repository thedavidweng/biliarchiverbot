FROM node:24-alpine AS base
LABEL org.opencontainers.image.source=https://github.com/saveweb/biliarchiverbot

ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

FROM base AS deps
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
RUN pnpm fetch

FROM deps AS build
COPY . .
RUN pnpm install --offline --frozen-lockfile

# Placeholder env so `vite build` can evaluate private module imports.
ENV BILIARCHIVER_WEBAPP=https://example.com/
ENV BILIARCHIVER_USERNAME=example
ENV BILIARCHIVER_API=https://example.com/
ENV BILIARCHIVER_BOT=example

RUN pnpm run build
# Drop toolchain packages from the runtime image without re-running prepare.
RUN pnpm prune --prod --ignore-scripts

FROM node:24-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=5173

RUN addgroup -S app && adduser -S app -G app \
  && mkdir -p /app/config \
  && chown -R app:app /app

COPY --from=build --chown=app:app /app/node_modules ./node_modules
COPY --from=build --chown=app:app /app/build ./build
COPY --from=build --chown=app:app /app/package.json ./package.json

USER app
EXPOSE 5173

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=3 --spider http://127.0.0.1:5173/favicon.png || exit 1

CMD ["node", "build"]
