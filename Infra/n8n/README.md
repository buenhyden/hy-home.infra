# n8n

## 개요

이 디렉토리는 워크플로우 자동화 도구인 n8n을 실행하기 위한 Docker Compose 구성을 포함합니다. PostgreSQL을 데이터베이스로 사용하며, 큐 관리를 위해 전용 Redis 인스턴스를 사용합니다.

## 서비스

- **n8n**: n8n 워크플로우 자동화 서버 (메인).
- **n8n-worker**: 워크플로우 실행을 담당하는 워커 노드.
- **n8n-redis**: n8n 내부 큐 관리를 위한 Redis.
- **n8n-redis-exporter**: Redis 메트릭을 위한 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- 외부 PostgreSQL 서비스 실행 필요 (`.env`에 설정됨).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `N8N_HOST_PORT`: n8n 호스트 포트.
- `N8N_ENCRYPTION_KEY`: 자격 증명 암호화 키.
- `POSTGRES_HOSTNAME`, `POSTGRES_WRITE_PORT`, `N8N_DB_USER`, `N8N_DB_PASSWORD`: 데이터베이스 연결 정보.
- `REDIS_PASSWORD`: 내부 Redis 인스턴스 비밀번호.
- `DEFAULT_URL`: 기본 도메인 URL.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **n8n UI**: `https://n8n.${DEFAULT_URL}` (Traefik을 통해 접근) 또는 `http://localhost:${N8N_HOST_PORT}`

## 볼륨

- `n8n-data`: n8n 데이터의 영구 저장소.
- `n8n-redis-data`: Redis 데이터의 영구 저장소.
