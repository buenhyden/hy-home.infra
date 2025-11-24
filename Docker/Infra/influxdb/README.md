# InfluxDB

## Overview
This directory contains the Docker Compose configuration for running InfluxDB v2.7, a time series database.

## Services
- **influxdb**: The InfluxDB server.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `INFLUXDB_HOST_PORT`: Host port for InfluxDB.
- `INFLUXDB_PORT`: Container port (default 8086).
- `INFLUXDB_DB_NAME`: Database name.
- `INFLUXDB_USERNAME`, `INFLUXDB_PASSWORD`: Admin credentials.
- `INFLUXDB_ORG`: Organization name.
- `INFLUXDB_BUCKET`: Default bucket name.
- `INFLUXDB_API_TOKEN`: Admin API token.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **InfluxDB UI**: `http://localhost:${INFLUXDB_HOST_PORT}`

## Volumes
- `influxdb-data`: Persistent storage for InfluxDB data.
