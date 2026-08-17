# ILM-Docker-Develop-Environment

This repository contains the Docker Compose files and helper scripts that stand up a local
development environment for the ILM platform. Several services need to be running during
development, and Compose profiles select which of them start — from the core services alone to
the full set of connectors — depending on the service you are going to work on.

## Quick start

Prerequisites:

- Docker with the Compose plugin (Compose v2, the `docker compose` command).
- Local checkouts of the platform source repositories, cloned under one base directory. Most
  services in `ilm-compose.yml` build their images from these sources.

Copy the `.env.example` file to `.env` and update `ILM_SOURCES_BASE_DIR` with the path to the
platform sources on your machine. For a quick start, use the following command to start the
environment for the core services with the PostgreSQL database in Docker:

```bash
docker compose -f ilm-compose.yml -f postgres-compose.yml --profile database --profile core up
```

## Full documentation

[docs/site/development-environment.md](docs/site/development-environment.md) is the complete
guide to this environment. It covers the Compose profiles, the environment variables, the
database, the messaging topology, authentication and registering the first administrator,
running the Administrator frontend against these services, and the helper scripts in
`scripts/`. The same guide is published in the contributors section of
https://docs.otilm.com.

## Contributing to these docs

`docs/site/development-environment.md` is synced into https://docs.otilm.com. It carries
`sidebar_position` front matter, and **links may only be same-directory relative links** —
every other target is an absolute URL.
