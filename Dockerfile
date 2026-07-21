# syntax=docker/dockerfile:1

# White-label image: keep the official Jitsi web bundle for the same release
# used by Prosody, Jicofo, and JVB, then layer the QIPLUS visual identity on
# top. This avoids compiling the full Jitsi frontend on production or CI.
ARG JITSI_IMAGE_VERSION=stable-10888
FROM jitsi/web:${JITSI_IMAGE_VERSION}

# QIPLUS browser branding.
COPY images/logo.png /usr/share/jitsi-meet/images/logo.png
COPY images/favicon.ico /usr/share/jitsi-meet/images/favicon.ico
COPY title.html /usr/share/jitsi-meet/title.html

# The official image copies this file to the persistent /config volume on
# every start, preserving the QIPLUS name and logos after redeployments.
COPY interface_config.js /defaults/interface_config.js

# Load the QIPLUS color palette through Jitsi's dynamic-branding mechanism.
COPY static/qiplus-branding.json /usr/share/jitsi-meet/static/qiplus-branding.json
COPY docker/qiplus-config.js /defaults/qiplus-config.js
RUN cat /defaults/qiplus-config.js >> /defaults/settings-config.js
