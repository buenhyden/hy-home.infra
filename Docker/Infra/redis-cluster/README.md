# Redis Cluster

## Overview
This directory contains the Docker Compose configuration for a 6-node Redis Cluster (3 Masters, 3 Replicas). It includes RedisInsight for management and a Redis Exporter for monitoring.

## Services
- **redis-node-0 to redis-node-5**: Redis cluster nodes.
- **redis-cluster-init**: One-shot container to initialize the cluster.
- **redis-exporter**: Prometheus exporter for Redis metrics.
- **redisinsight**: GUI for managing Redis.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `REDIS_HOST_PORT`: Host port for the first node (for debugging).
- `REDIS_INSIGHT_HOST_PORT`: Host port for RedisInsight.
- `REDIS_EXPORTER_HOST_PORT`: Host port for metrics.
- `REDIS_PASSWORD`: Password for Redis authentication (via Docker secrets).

## Usage
To start the services:
```bash
docker-compose up -d
```
The `redis-cluster-init` service will automatically configure the cluster topology.

## Access
- **RedisInsight**: `http://localhost:${REDIS_INSIGHT_HOST_PORT}`
- **Redis Node 0**: `localhost:${REDIS_HOST_PORT}`

## Volumes
- `redis-data-*`: Persistent storage for each node.
