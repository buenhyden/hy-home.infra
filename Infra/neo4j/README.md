# Neo4j

## Overview
This directory contains the Docker Compose configuration for running Neo4j, a graph database.

## Services
- **neo4j**: The Neo4j database server.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `NEO4J_HOST_BOLT_PORT`: Host port for the Bolt protocol.
- `NEO4J_BOLT_PORT`: Container port for Bolt.
- `NEO4J_PASSWORD`: Admin password.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Neo4j Browser**: Typically accessible via HTTP (check if HTTP port is mapped) or Bolt connection.
- **Bolt**: `bolt://localhost:${NEO4J_HOST_BOLT_PORT}`

## Volumes
- `neo4j-volume`: Persistent storage for Neo4j data.
