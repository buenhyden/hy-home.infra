# n8n

## Overview
This directory contains the Docker Compose configuration for running n8n, a workflow automation tool. It is configured to use PostgreSQL as the database and a dedicated Redis instance for queue management.

## Services
- **n8n**: The n8n workflow automation server.
- **n8n-redis**: Redis instance for n8n's internal queue.
- **n8n-redis-exporter**: Prometheus exporter for Redis metrics.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.
- External PostgreSQL service running (as configured in `.env`).

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `N8N_HOST_PORT`: Host port for n8n.
- `N8N_ENCRYPTION_KEY`: Key for encrypting credentials.
- `POSTGRES_HOSTNAME`, `POSTGRES_WRITE_PORT`, `N8N_DB_USER`, `N8N_DB_PASSWORD`: Database connection details.
- `REDIS_PASSWORD`: Password for the internal Redis instance.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **n8n UI**: `http://localhost:${N8N_HOST_PORT}`

## Volumes
- `n8n-data`: Persistent storage for n8n data.
- `n8n-redis-data`: Persistent storage for Redis data.
