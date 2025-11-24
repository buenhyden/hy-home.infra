# MongoDB

## Overview
This directory contains the Docker Compose configuration for running a MongoDB Replica Set. It includes Mongo Express for web-based administration and a MongoDB Exporter for Prometheus monitoring.

## Services
- **mongodb-rep1**: Primary/Secondary node of the replica set.
- **mongodb-rep2**: Primary/Secondary node of the replica set.
- **mongo-express**: Web-based MongoDB admin interface.
- **mongodb-exporter**: Prometheus exporter for MongoDB metrics.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `NOSQL_ROOT_USER`: MongoDB root username.
- `NOSQL_ROOT_PASSWORD`: MongoDB root password.
- `MONGODB_HOST_REPLICASET_1_PORT`, `MONGODB_HOST_REPLICASET_2_PORT`: Host ports for the nodes.
- `MONGO_EXPRESS_PORT`: Host port for Mongo Express.
- `MONGO_EXPORTER_PORT`: Host port for the exporter.
- `MONGO_EXPRESS_CONFIG_BASICAUTH_USERNAME`, `MONGO_EXPRESS_CONFIG_BASICAUTH_PASSWORD`: Basic auth for Mongo Express.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Mongo Express**: `http://localhost:${MONGO_EXPRESS_PORT}` (or via Traefik if configured)
- **MongoDB**: Connect via `mongodb-rep1` or `mongodb-rep2` on their respective ports.

## Volumes
- `replicaset-*-mongo-data-volume`: Persistent storage for database data.
- `replicaset-*-mongo-conf-volume`: Configuration storage.
