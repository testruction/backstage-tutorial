# --------------------------------------------------
# Step 1 build the app
# --------------------------------------------------
FROM docker.io/library/node:18-bookworm-slim AS build

ARG STAGE

RUN mkdir -vp /app
COPY . /app
WORKDIR /app

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --network-timeout 600000

COPY chart/config/app-config.${STAGE}.yaml /app/

RUN yarn workspace app build


# --------------------------------------------------
# Step 2 release in Caddy web server
# --------------------------------------------------
FROM docker.io/amd64/caddy:2.7-alpine

COPY --chown=caddy:caddy containers/caddy/config/Caddyfile /etc/caddy/Caddyfile
COPY --chown=caddy:caddy --from=build /app/packages/app/dist /usr/share/caddy

ENV PORT 3000