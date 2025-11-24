# Docker Infrastructure & Projects

## Overview
This repository contains the Docker Compose configurations for the entire infrastructure and development projects. It is organized into two main sections:
- **Docker/Infra**: Infrastructure services (Databases, Message Brokers, Observability, etc.).
- **Docker/Projects**: Development project templates and environments.

## Prerequisites
- **Docker**: Ensure Docker Engine is installed.
- **Docker Compose**: Ensure Docker Compose is installed.
- **Environment Variables**: A `.env` file in `Docker/Infra` is **REQUIRED**. This file contains all the necessary environment variables (ports, passwords, paths) for the services to run.

## Directory Structure

### Docker/Infra
Infrastructure services are categorized by their function. Each directory contains a `docker-compose.yml` and a `README.md` with specific instructions.

| Service | Description |
| :--- | :--- |
| [airflow](./airflow) | Apache Airflow for workflow orchestration. |
| [cassandra](./cassandra) | Apache Cassandra NoSQL database. |
| [harbor](./harbor) | Harbor container registry. |
| [influxdb](./influxdb) | InfluxDB time-series database. |
| [kafka](./kafka) | Apache Kafka (KRaft mode) with Schema Registry, Connect, and UI. |
| [keycloak](./keycloak) | Keycloak Identity and Access Management. |
| [ksql](./ksql) | ksqlDB for stream processing. |
| [locust](./locust) | Locust for load testing. |
| [minio](./minio) | MinIO object storage (S3 compatible). |
| [mongodb](./mongodb) | MongoDB Replica Set with Mongo Express. |
| [n8n](./n8n) | n8n workflow automation tool. |
| [neo4j](./neo4j) | Neo4j graph database. |
| [observability](./observability) | Full stack: Prometheus, Loki, Tempo, Grafana, Alloy. |
| [ollama](./ollama) | Local LLM runner with Qdrant and Open WebUI. |
| [opensearch](./opensearch) | OpenSearch suite (Search + Dashboards). |
| [postgresql](./postgresql) | PostgreSQL HA cluster (Patroni + Etcd + HAProxy). |
| [redis-cluster](./redis-cluster) | Redis Cluster (6 nodes) with RedisInsight. |
| [sonarqube](./sonarqube) | SonarQube for code quality inspection. |
| [storybook](./storybook) | Storybook configurations for UI development. |
| [supabase](./supabase) | Self-hosted Supabase stack. |
| [syncthing](./syncthing) | Syncthing for file synchronization. |
| [traefik](./traefik) | Traefik reverse proxy and load balancer. |
| [valkey](./valkey) | Valkey (Redis fork) cluster and standalone. |

### Docker/Projects
Development environments for various languages and frameworks.

| Project | Description |
| :--- | :--- |
| [Django](../Projects/Django) | Python Django development environment. |
| [ExpressJS](../Projects/ExpressJS) | Node.js Express development environment. |
| [FastAPI](../Projects/FastAPI) | Python FastAPI development environment. |
| [Gradle](../Projects/Gradle) | Java Spring Boot (Gradle) environment. |
| [Maven](../Projects/Maven) | Java Spring Boot (Maven) environment. |
| [NestJS](../Projects/NestJS) | Node.js NestJS development environment. |
| [NextJS](../Projects/NextJS) | Node.js NextJS development environment. |
| [ReactJS](../Projects/ReactJS) | ReactJS (Vite) development environment. |

## Getting Started

1. **Configure Environment**:
   Copy the example environment file (if available) or create a `.env` file in `Docker/Infra` with the required variables.

2. **Run a Service**:
   Navigate to the service directory and run:
   ```bash
   cd Docker/Infra/redis-cluster
   docker-compose up -d
   ```

3. **Run a Project**:
   Navigate to the project directory and run:
   ```bash
   cd Docker/Projects/ReactJS
   docker-compose up -d
   ```

## Network
Most services are connected via shared Docker networks (e.g., `infra_net`, `nt-databases`, `nt-webserver`) to allow communication between containers. Ensure your network configurations in `docker-compose.yml` files match your requirements.
