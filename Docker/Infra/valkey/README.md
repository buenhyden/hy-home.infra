# Valkey (Redis Alternative)

## Overview
This directory contains the Docker Compose configuration for running Valkey, a high-performance key-value store (fork of Redis). It includes a cluster configuration with Predixy proxy and a standalone instance.

## Services
- **valkey-node-1, 2, 3**: Valkey cluster nodes.
- **valkey-predixy**: Proxy for the Valkey cluster.
- **valkey-cluster-exporter**: Prometheus exporter for the cluster.
- **valkey-standalone**: A standalone Valkey instance.
- **valkey-standalone-exporter**: Prometheus exporter for the standalone instance.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `VALKEY_PORT`: Container port.
- `VALKEY_PREDIXY_HOST_PORT`: Host port for the cluster proxy.
- `VALKEY_STANDALONE_HOST_PORT`: Host port for the standalone instance.
- `VALKEY_PASSWORD`: Authentication password.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Cluster (via Proxy)**: `localhost:${VALKEY_PREDIXY_HOST_PORT}`
- **Standalone**: `localhost:${VALKEY_STANDALONE_HOST_PORT}`

## Volumes
- `valkey-node*-data-volume`: Data for cluster nodes.
- `valkey-standalone-data-volume`: Data for standalone instance.
