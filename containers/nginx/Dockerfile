# --------------------------------------------------
# Step 1 build the app
# --------------------------------------------------
FROM docker.io/library/node:18-bookworm-slim AS build

ARG STAGE

RUN mkdir -vp /app
COPY . /app
WORKDIR /app

RUN yarn install --network-timeout 600000

COPY chart/config/app-config${STAGE}.yaml /app/

RUN yarn workspace app build


# --------------------------------------------------
# Step 2 release in Nginx web server
# --------------------------------------------------
FROM docker.io/library/nginx:stable-alpine

COPY --from=build /app/packages/app/dist /usr/share/nginx/html

COPY containers/nginx/config/backstage.conf /etc/nginx/conf.d/backstage.conf

EXPOSE 8080