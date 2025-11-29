# PostgreSQL HA (Patroni + Etcd + HAProxy)

## 개요

이 디렉토리는 Patroni, Etcd, HAProxy를 사용하는 고가용성(HA) PostgreSQL 클러스터를 위한 Docker Compose 구성을 포함합니다. 자동 장애 조치(Failover) 및 읽기/쓰기 분리를 제공합니다.

## 서비스

- **etcd-1, etcd-2, etcd-3**: Patroni의 클러스터 상태를 위한 분산 키-값 저장소.
- **pg-0, pg-1, pg-2**: Patroni가 관리하는 PostgreSQL 노드 (Spilo 이미지).
- **pg-router**: 트래픽을 Primary(쓰기) 또는 Replicas(읽기)로 라우팅하는 HAProxy.
- **pg-*-exporter**: 각 Postgres 노드에 대한 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `POSTGRES_WRITE_HOST_PORT`: 쓰기 작업용 호스트 포트 (Primary).
- `POSTGRES_READ_HOST_PORT`: 읽기 작업용 호스트 포트 (Replicas).
- `HAPROXY_METRICS_HOST_PORT`: HAProxy 통계 및 메트릭 호스트 포트.
- `POSTGRES_PASSWORD`: 데이터베이스 비밀번호.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Write Endpoint**: `localhost:${POSTGRES_WRITE_HOST_PORT}`
- **Read Endpoint**: `localhost:${POSTGRES_READ_HOST_PORT}`
- **HAProxy Stats**: `https://pg-haproxy.${DEFAULT_URL}` (Traefik을 통해 접근) 또는 `http://localhost:${HAPROXY_METRICS_HOST_PORT}`

## 볼륨

- `etcd*-data`: Etcd용 영구 저장소.
- `pg*-data`: PostgreSQL 데이터용 영구 저장소.
