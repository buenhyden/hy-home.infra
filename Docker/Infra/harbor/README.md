# Harbor

## Overview
This directory contains the Docker Compose configuration for running Harbor, an open-source trusted cloud-native registry project that stores, signs, and scans content. It uses Bitnami images and integrates with PostgreSQL and Valkey (Redis).

## Services
- **harbor-core**: The core service of Harbor.
- **harbor-registry**: The Docker registry service.
- **harbor-registryctl**: Controls the registry.
- **harbor-portal**: The web UI for Harbor.
- **harbor-jobservice**: Handles asynchronous jobs.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.
- External PostgreSQL and Valkey (Redis) services running (as configured in `.env`).

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `HARBOR_PORT`: Port for Harbor services.
- `HARBOR_PASSWORD`: Admin password.
- `HARBOR_CORE_SECRET`, `HARBOR_JOBSERVICE_SECRET`, `HARBOR_REGISTRY_HTTP_SECRET`: Secrets for internal communication.
- `POSTGRES_HOSTNAME`, `POSTGRES_PORT`, `POSTGRES_PASSWORD`: Database connection details.
- `VALKEY_STANDALONE_HOSTNAME`, `VALKEY_PORT`, `VALKEY_PASSWORD`: Redis connection details.
- `DEFAULT_CICD_DIR`: Base directory for persistent storage.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Harbor Portal**: `http://localhost:${HARBOR_PORT}` (Check your `.env` for the actual port)

## Volumes
- `harbor-registry-data-volume`: Stores registry data.
- `harbor-core-data-volume`: Stores core data.
- `harbor-jobservice-logs-volume`: Stores job logs.
- Configuration volumes for registry, registryctl, core, and jobservice.
