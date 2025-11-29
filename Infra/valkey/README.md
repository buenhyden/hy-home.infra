# Valkey (Redis Alternative)

## 개요

이 디렉토리는 고성능 키-값 저장소인 Valkey(Redis 포크)를 실행하기 위한 Docker Compose 구성을 포함합니다. Predixy 프록시를 포함한 클러스터 구성과 독립형(Standalone) 인스턴스를 모두 포함합니다.

## 서비스

- **valkey-node-1, 2, 3**: Valkey 클러스터 노드.
- **valkey-predixy**: Valkey 클러스터용 프록시.
- **valkey-cluster-exporter**: 클러스터용 Prometheus Exporter.
- **valkey-standalone**: 독립형 Valkey 인스턴스.
- **valkey-standalone-exporter**: 독립형 인스턴스용 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `VALKEY_PORT`: 컨테이너 포트.
- `VALKEY_PREDIXY_HOST_PORT`: 클러스터 프록시 호스트 포트.
- `VALKEY_STANDALONE_HOST_PORT`: 독립형 인스턴스 호스트 포트.
- `VALKEY_PASSWORD`: 인증 비밀번호.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Cluster (via Proxy)**: `localhost:${VALKEY_PREDIXY_HOST_PORT}`
- **Standalone**: `localhost:${VALKEY_STANDALONE_HOST_PORT}`

## 볼륨

- `valkey-node*-data-volume`: 클러스터 노드 데이터.
- `valkey-standalone-data-volume`: 독립형 인스턴스 데이터.
