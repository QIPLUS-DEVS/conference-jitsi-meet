# QIPLUS on Coolify

GitHub Actions builds and publishes the QIPLUS web interface to GitHub
Container Registry (GHCR). Coolify only pulls that ready-made image and runs it
with the official Jitsi signalling and media services.

## Deploy

1. Push to `master` and wait for the **Publish QIPLUS web image** GitHub Actions
   workflow to finish successfully.
2. If the GHCR package is private, configure GHCR as a Docker registry in
   Coolify with a GitHub token that has the `read:packages` permission. Making
   the package public also works for a public meeting service.
3. Create an application from this Git repository and select **Docker Compose**.
4. Set the base directory to `/` and the Compose location to `docker-compose.yml`.
5. Assign `https://meet.qiplus.com.br` to the `jitsi-web` service. Coolify must
   expose its internal port `80`. Coolify then creates
   `SERVICE_URL_JITSI_WEB`; do not create it manually in the environment UI.
6. Copy the values from `.env.example` into Coolify's environment variables,
replacing every placeholder with a distinct secret.
7. Set `JVB_ADVERTISE_IPS` to the server's public IPv4 address.
8. Keep `JITSI_IMAGE_VERSION` equal for all four services; update it only after
   validating the release in homologation.
9. Deploy and open the domain. Subsequent redeploys pull the latest published
   QIPLUS image and do not run a frontend build on the server.

Do not enable Coolify auto-deploy directly from Git while this workflow is
building the image: it can deploy before GHCR receives the new `latest` tag.
Redeploy after the GitHub Actions workflow finishes, or configure a Coolify
deployment webhook as a later CI step.

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

## Branding and image workflow

The GitHub Actions workflow compiles this fork with the `Dockerfile` and
publishes `ghcr.io/qiplus-devs/conference-jitsi-meet:latest`. Put QIPLUS logos
and background images under `images/` and update `interface_config.js` or the
React/CSS code as needed. Push the change, wait for the image workflow, then
redeploy in Coolify. Prosody, Jicofo, and JVB remain official images.

## Local smoke test

Copy `.env.example` to `.env`, replace placeholders and IP address, then run:

```sh
docker build -t qiplus/jitsi-web:local .
QIPLUS_WEB_IMAGE=qiplus/jitsi-web QIPLUS_WEB_TAG=local docker compose up
```

For local-only testing, set `SERVICE_URL_JITSI_WEB=http://localhost` and
`JVB_ADVERTISE_IPS` to the LAN/public address reachable by test participants.
