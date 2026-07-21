# syntax=docker/dockerfile:1

# Build the Jitsi Meet web bundles from this QIPLUS fork.
ARG JITSI_IMAGE_VERSION=stable-10888
FROM node:24-bookworm AS builder

WORKDIR /usr/src/jitsi-meet

COPY package.json package-lock.json ./
# The upstream postinstall script configures React Native as well. The web
# image does not need that work, but it does need the repository patches.
RUN npm ci --ignore-scripts \
    && ./node_modules/.bin/patch-package --error-on-fail

COPY . .
RUN make

# Keep the official web container entrypoint and its runtime configuration,
# but replace the static application with the version built from this fork.
FROM jitsi/web:${JITSI_IMAGE_VERSION}

COPY --from=builder /usr/src/jitsi-meet/index.html /usr/share/jitsi-meet/index.html
COPY --from=builder /usr/src/jitsi-meet/css /usr/share/jitsi-meet/css
COPY --from=builder /usr/src/jitsi-meet/fonts /usr/share/jitsi-meet/fonts
COPY --from=builder /usr/src/jitsi-meet/images /usr/share/jitsi-meet/images
COPY --from=builder /usr/src/jitsi-meet/lang /usr/share/jitsi-meet/lang
COPY --from=builder /usr/src/jitsi-meet/libs /usr/share/jitsi-meet/libs
COPY --from=builder /usr/src/jitsi-meet/sounds /usr/share/jitsi-meet/sounds
COPY --from=builder /usr/src/jitsi-meet/static /usr/share/jitsi-meet/static

# The official image copies this file to the persistent /config volume on
# every start. This keeps the QIPLUS application name and welcome-page logo.
COPY --from=builder /usr/src/jitsi-meet/interface_config.js /defaults/interface_config.js
