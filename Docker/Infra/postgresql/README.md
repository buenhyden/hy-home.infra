# PostgreSQL HA (Patroni + Etcd + HAProxy)

## Overview
This directory contains the Docker Compose configuration for a High Availability PostgreSQL cluster using Patroni, Etcd, and HAProxy. It provides automatic failover and read/write splitting.

## Services
- **etcd-1, etcd-2, etcd-3**: Distributed key-value store for Patroni's cluster state.
- **pg-0, pg-1, pg-2**: PostgreSQL nodes managed by Patroni (Spilo image).
- **pg-router**: HAProxy for routing traffic to the primary (write) or replicas (read).
- **pg-*-exporter**: Prometheus exporters for each Postgres node.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `POSTGRES_WRITE_HOST_PORT`: Host port for write operations (Primary).
- `POSTGRES_READ_HOST_PORT`: Host port for read operations (Replicas).
- `HAPROXY_HOST_PORT`: Host port for HAProxy stats.
- `POSTGRES_PASSWORD`: Database password.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Write Endpoint**: `localhost:${POSTGRES_WRITE_HOST_PORT}`
- **Read Endpoint**: `localhost:${POSTGRES_READ_HOST_PORT}`
- **HAProxy Stats**: `http://localhost:${HAPROXY_HOST_PORT}`

## Volumes
- `etcd*-data`: Persistent storage for Etcd.
- `pg*-data`: Persistent storage for PostgreSQL data.
