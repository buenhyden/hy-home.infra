# Locust

## Overview
This directory contains the Docker Compose configuration for running Locust, an open-source load testing tool. It is configured with a master-worker architecture and integrates with InfluxDB for metrics storage.

## Services
- **locust-master**: The master node that manages the test.
- **locust-worker**: Worker nodes that generate load (scaled to 2 replicas).

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.
- InfluxDB service running (for metrics).

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `LOCUST_HOST_PORT`: Host port for the Locust web interface.
- `INFLUXDB_PORT`, `INFLUXDB_ORG`, `INFLUXDB_BUCKET`, `INFLUXDB_API_TOKEN`: InfluxDB connection details.

## Usage
To start the services:
```bash
docker-compose up -d
```

To run a test, ensure your `locustfile.py` is in the mounted volume.

## Access
- **Locust Web UI**: `http://localhost:${LOCUST_HOST_PORT}`

## Volumes
- `locust-data`: Mounts the directory containing `locustfile.py`.
