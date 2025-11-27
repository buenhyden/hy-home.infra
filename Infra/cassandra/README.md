# Apache Cassandra

## Overview
This directory contains the Docker Compose configuration for running Apache Cassandra using the Bitnami image. It also includes a Cassandra Exporter for Prometheus monitoring.

## Services
- **cassandra-node1**: The Cassandra database node.
- **cassandra-exporter**: Exports Cassandra metrics for Prometheus.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_USERNAME`: Cassandra user.
- `CASSANDRA_PASSWORD`: Cassandra password.
- `CASSANDRA_EXPORTER_PORT`: Port for the exporter.
- `DEFAULT_DATABASE_DIR`: Base directory for persistent storage.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Cassandra**: Accessible internally via `cassandra-node1` on port `9042` (default client port).
- **Metrics**: Accessible via `cassandra-exporter` on port `${CASSANDRA_EXPORTER_PORT}`.

## Volumes
- `cassandra-node1-volume`: Persistent storage for Cassandra data.
- `cassandra-exporter-volume`: Configuration for the exporter.
