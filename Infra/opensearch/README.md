# OpenSearch

## Overview
This directory contains the Docker Compose configuration for running OpenSearch, a distributed search and analytics suite. It includes OpenSearch Dashboards and an exporter.

## Services
- **opensearch-node1**: Single-node OpenSearch instance (Cluster Manager + Data + Ingest).
- **opensearch-dashboards**: Web interface for OpenSearch.
- **opensearch-exporter**: Prometheus exporter for OpenSearch metrics.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `ES_HOST_1_PORT`: Host port for OpenSearch API.
- `KIBANA_HOST_PORT`: Host port for OpenSearch Dashboards.
- `ES_EXPORTER_HOST_PORT`: Host port for metrics.
- `ELASTIC_USERNAME`, `ELASTIC_PASSWORD`: Admin credentials.
- `OPENSEARCH_JAVA_OPTS`: JVM heap settings.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **OpenSearch Dashboards**: `http://localhost:${KIBANA_HOST_PORT}`
- **OpenSearch API**: `https://localhost:${ES_HOST_1_PORT}` (Self-signed certificate)

## Volumes
- `opensearch-data1`: Persistent storage for OpenSearch data.
