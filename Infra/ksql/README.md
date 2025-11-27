# ksqlDB

## Overview
This directory contains the Docker Compose configuration for running ksqlDB, a database purpose-built for stream processing applications.

## Services
- **ksqldb-node1**: The ksqlDB server node.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.
- Running Kafka cluster (ksqlDB depends on it).

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `KSQLDB_HOST_PORT`: Host port for ksqlDB.
- `KSQLDB_PORT`: Container port.
- `KAFKA_PORT`: Kafka broker port.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **ksqlDB Server**: `http://localhost:${KSQLDB_HOST_PORT}`

## Volumes
- `ksqldb-node-1-data-volume`: Persistent storage for ksqlDB.
