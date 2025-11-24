# Apache Kafka (KRaft Mode)

## Overview
This directory contains the Docker Compose configuration for running a 3-node Apache Kafka cluster in KRaft mode (without ZooKeeper). It includes the Schema Registry, Kafka Connect, REST Proxy, Kafka UI, and Kafka Exporter.

## Services
- **kafka-1, kafka-2, kafka-3**: Three Kafka brokers acting as both brokers and controllers.
- **schema-registry**: Confluent Schema Registry.
- **kafka-connect**: Distributed Kafka Connect.
- **kafka-rest-proxy**: REST Proxy for Kafka.
- **kafka-ui**: Web UI for managing the Kafka cluster (Provectus).
- **kafka-exporter**: Prometheus exporter for Kafka metrics.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `KAFKA_CLSUTER_ID`: Unique ID for the Kafka cluster.
- `KAFKA_CLSUTER_NAME`: Name of the cluster for UI.
- `KAFKA_CONTROLLER_*_HOST_PORT`: Ports for accessing brokers.
- `SCHEMA_REGISTRY_HOST_PORT`: Port for Schema Registry.
- `KAFKA_CONNECT_HOST_PORT`: Port for Kafka Connect.
- `KAFKA_REST_PROXY_HOST_PORT`: Port for REST Proxy.
- `KAFKA_UI_HOST_PORT`: Port for Kafka UI.
- `KAFKA_EXPORTER_HOST_PORT`: Port for Kafka Exporter.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Kafka UI**: `http://localhost:${KAFKA_UI_HOST_PORT}`
- **Schema Registry**: `http://localhost:${SCHEMA_REGISTRY_HOST_PORT}`
- **Kafka Connect**: `http://localhost:${KAFKA_CONNECT_HOST_PORT}`
- **REST Proxy**: `http://localhost:${KAFKA_REST_PROXY_HOST_PORT}`
- **Metrics**: `http://localhost:${KAFKA_EXPORTER_HOST_PORT}/metrics`

## Volumes
- `kafka-1-data`, `kafka-2-data`, `kafka-3-data`: Persistent storage for Kafka brokers.
- `kafka-connect-data`: Persistent storage for Kafka Connect.
