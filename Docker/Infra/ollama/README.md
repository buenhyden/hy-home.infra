# Ollama & AI Stack

## Overview
This directory contains the Docker Compose configuration for running local LLMs using Ollama, along with Qdrant for vector storage and Open WebUI for a chat interface.

## Services
- **ollama**: The local LLM runner (GPU enabled).
- **qdrant**: Vector database for RAG (Retrieval-Augmented Generation).
- **open-webui**: Web interface for interacting with Ollama.
- **ollama-exporter**: Prometheus exporter for Ollama metrics.

## Prerequisites
- Docker and Docker Compose installed.
- NVIDIA GPU and Container Toolkit (for GPU support).
- A `.env` file in the `Docker/Infra` root directory.

## Configuration
The service relies on the following environment variables (defined in `.env`):
- `OLLAMA_HOST_PORT`: Host port for Ollama API.
- `QDRANT_HOST_PORT`: Host port for Qdrant.
- `OLLAMA_WEBUI_HOST_PORT`: Host port for Open WebUI.
- `OLLAMA_EXPORTER_HOST_PORT`: Host port for metrics.

## Usage
To start the services:
```bash
docker-compose up -d
```

## Access
- **Open WebUI**: `http://localhost:${OLLAMA_WEBUI_HOST_PORT}`
- **Ollama API**: `http://localhost:${OLLAMA_HOST_PORT}`
- **Qdrant**: `http://localhost:${QDRANT_HOST_PORT}`

## Volumes
- `ollama-data`: Stores LLM models.
- `qdrant-data`: Stores vector data.
- `ollama-webui`: Stores WebUI data.
