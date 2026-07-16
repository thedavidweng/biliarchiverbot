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
# Fixed IDs so named volumes / host bind mounts can be chown'd predictably.
ENV APP_UID=10001
ENV APP_GID=10001

RUN apk add --no-cache su-exec \
  && addgroup -g "$APP_GID" -S app \
  && adduser -u "$APP_UID" -S -G app app \
  && mkdir -p /app/config \
  && chown -R app:app /app

COPY --from=build --chown=app:app /app/node_modules ./node_modules
COPY --from=build --chown=app:app /app/build ./build
COPY --from=build --chown=app:app /app/package.json ./package.json
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Entrypoint starts as root only long enough to fix /app/config ownership, then
# permanently drops to UID/GID 10001 before running the server.
USER root
EXPOSE 5173

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
  CMD wget --quiet --tries=3 --spider http://127.0.0.1:5173/favicon.png || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["node", "build"]
