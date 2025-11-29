# Redis Cluster

## 개요

이 디렉토리는 6노드 Redis 클러스터(마스터 3개, 레플리카 3개)를 위한 Docker Compose 구성을 포함합니다. 관리를 위한 RedisInsight와 모니터링을 위한 Redis Exporter도 포함되어 있습니다.

## 서비스

- **redis-node-0 ~ redis-node-5**: Redis 클러스터 노드.
- **redis-cluster-init**: 클러스터를 초기화하는 일회성 컨테이너.
- **redis-exporter**: Redis 메트릭을 위한 Prometheus Exporter.
- **redisinsight**: Redis 관리를 위한 GUI.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `REDIS_HOST_PORT`: 첫 번째 노드의 호스트 포트 (디버깅용).
- `REDIS_INSIGHT_HOST_PORT`: RedisInsight 호스트 포트 (Traefik 사용 시 주석 처리됨).
- `REDIS_EXPORTER_HOST_PORT`: 메트릭 호스트 포트.
- `REDIS_PASSWORD`: Redis 인증 비밀번호 (Docker secrets를 통해 전달).

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

`redis-cluster-init` 서비스가 자동으로 클러스터 토폴로지를 구성합니다.

## 접속

- **RedisInsight**: `https://redisinsight.${DEFAULT_URL}` (Traefik을 통해 접근)
- **Redis Node 0**: `localhost:${REDIS_HOST_PORT}`

## 볼륨

- `redis-data-*`: 각 노드의 영구 저장소.
