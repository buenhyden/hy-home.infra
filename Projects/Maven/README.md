# Spring Boot (Maven) Project

## Overview
This directory contains the Docker Compose configuration for a Spring Boot development environment using Maven.

## Services
- **default-spring-maven**: The Spring Boot application container.

## Prerequisites
- Docker and Docker Compose installed.
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `DEFAULT_SPRING_MAVEN_HOST_PORT`: Host port for the Spring Boot app.
- `DEFAULT_SPRING_PORT`: Container port.
- `DEFAULT_SOURCECODE_DIR`: Base directory for source code.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **App**: `http://localhost:${DEFAULT_SPRING_MAVEN_HOST_PORT}`

## Volumes
- `default-spring-maven-volume`: Mounts the source code from `${DEFAULT_SOURCECODE_DIR}/default-Spring-Maven`.
