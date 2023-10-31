# --------------------------------------------------
# Stage 1 - Create yarn install skeleton layer
# --------------------------------------------------
FROM docker.io/library/node:18-bookworm-slim AS packages

WORKDIR /app
COPY package.json yarn.lock ./

COPY packages packages

# Comment this out if you don't have any internal plugins
COPY plugins plugins

# Except "package.json", remove all files located at the root of the "app" and "backend" folders.
RUN find packages \! -name "package.json" \! -name "src" -mindepth 2 -maxdepth 2 -exec rm -rf {} \+


# --------------------------------------------------
# Stage 2 - Install dependencies and build packages
# --------------------------------------------------
FROM docker.io/library/node:18-bookworm-slim AS build

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
# Beneva: Add Yarn install as it not part of the base image
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends python3 g++ build-essential git \
    && yarn config set python /usr/bin/python3

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends libsqlite3-dev 

USER node
WORKDIR /app

COPY --from=packages --chown=node:node /app .

# Stop cypress from downloading it's massive binary.
ENV CYPRESS_INSTALL_BINARY=0
RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --frozen-lockfile --network-timeout 600000

COPY --chown=node:node ./ .

# Remove Backend App Plugin
# https://backstage.io/docs/deployment/docker#separate-frontend
RUN rm -vf packages/backend/src/plugins/app.ts \
    && sed -e '/import app/d' \
           -e '/const appEnv.*/d' \
           -e '/appEnv/d' \
           -i packages/backend/src/index.ts \
    && yarn remove --cwd packages/backend @backstage/plugin-app-backend

RUN yarn tsc
RUN yarn config set version-git-tag false \
    && yarn config set version-commit-hooks false \
    && yarn --cwd packages/backend build
# If you have not yet migrated to package roles, use the following command instead:
# RUN yarn --cwd packages/backend backstage-cli backend:bundle --build-dependencies

RUN mkdir packages/backend/dist/skeleton packages/backend/dist/bundle \
    && tar xzf packages/backend/dist/skeleton.tar.gz -C packages/backend/dist/skeleton \
    && tar xzf packages/backend/dist/bundle.tar.gz -C packages/backend/dist/bundle


# --------------------------------------------------
# Stage 3 - Build the actual backend image and install production dependencies
# --------------------------------------------------
FROM docker.io/library/node:18-bookworm-slim

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
# Beneva: Add Yarn install as it not part of the base image
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install -y --no-install-recommends \
        'python3' \
        'g++' \
        'build-essential' \
        'git' \
        'python3' \
        'python3-pip' \
        'python3-venv' \
        'graphviz' \
        'plantuml' \
        'net-tools' \
    && yarn config set python /usr/bin/python3

# Techdocs configuration
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN pip3 install --no-cache \
    'mkdocs-techdocs-core' \
    'mkdocs-material' \
    'mkdocs-mermaid-plugin' \
    'mkdocs-monorepo-plugin' \
    'mkdocs-diagrams'

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

# Copy the install dependencies from the build stage and context
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/packages/backend/dist/skeleton/ ./

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn install --frozen-lockfile --production --network-timeout 600000

# Copy the built packages from the build stage
COPY --from=build --chown=node:node /app/packages/backend/dist/bundle/ ./

# Copy any other files that we need at runtime
COPY --chown=node:node ./app-config.yaml ./

# This switches many Node.js dependencies to production mode.
ENV NODE_ENV production

CMD ["node", "packages/backend", "--config", "app-config.yaml"]
