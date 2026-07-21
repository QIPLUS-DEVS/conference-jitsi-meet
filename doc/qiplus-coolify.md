# QIPLUS on Coolify

This repository builds the QIPLUS web interface and runs it with the official
Jitsi signalling and media services. The stack uses the Docker Compose build
pack in Coolify.

## Deploy

1. Create an application from this Git repository and select **Docker Compose**.
2. Set the base directory to `/` and the Compose location to `docker-compose.yml`.
3. Assign `https://meet.qiplus.com.br` to the `jitsi-web` service. Coolify must
   expose its internal port `80`. Coolify then creates
   `SERVICE_URL_JITSI_WEB`; do not create it manually in the environment UI.
4. Copy the values from `.env.example` into Coolify's environment variables,
replacing every placeholder with a distinct secret.
5. Set `JVB_ADVERTISE_IPS` to the server's public IPv4 address.
6. Keep `JITSI_IMAGE_VERSION` equal for all four services; update it only after
   validating the release in homologation.
7. Deploy and open the domain.

The Coolify proxy terminates HTTPS. Do not enable Let's Encrypt or HTTPS inside
the `jitsi-web` container.

## Network and firewall

Open the following inbound ports on the server:

- `80/tcp` and `443/tcp` for the Coolify proxy;
- `10000/udp` for WebRTC media from the Jitsi Videobridge.

The Compose stack intentionally defines no custom Docker network: Coolify
creates one and service names such as `prosody` resolve inside it.

## Authentication

The default configuration requires a JWT. The QIPLUS backend must sign a
short-lived token with `JWT_APP_SECRET`, using the configured issuer and
audience. At minimum it should carry the user's name and moderator permission.

Set `ENABLE_GUESTS=1` only if unauthenticated guests are a deliberate product
rule. Even then, keep room creation restricted by issuing JWTs only from the
QIPLUS backend.

## Branding workflow

The `Dockerfile` compiles this fork and replaces the official web static
assets. Put QIPLUS logos and background images under `images/` and update
`interface_config.js` or the React/CSS code as needed. A new deployment builds
and serves those changes without modifying the Prosody, Jicofo, or JVB images.

## Local smoke test

Copy `.env.example` to `.env`, replace placeholders and IP address, then run:

```sh
docker compose up --build
```

For local-only testing, set `SERVICE_URL_JITSI_WEB=http://localhost` and
`JVB_ADVERTISE_IPS` to the LAN/public address reachable by test participants.
