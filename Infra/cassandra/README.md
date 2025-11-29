# Apache Cassandra

## 개요

이 디렉토리는 Bitnami 이미지를 사용하여 Apache Cassandra를 실행하기 위한 Docker Compose 구성을 포함합니다. Prometheus 모니터링을 위한 Cassandra Exporter도 포함되어 있습니다.

## 서비스

- **cassandra-node1**: Cassandra 데이터베이스 노드.
- **cassandra-exporter**: Prometheus를 위한 Cassandra 메트릭 추출기.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `DEFAULT_USERNAME`: Cassandra 사용자.
- `CASSANDRA_PASSWORD`: Cassandra 비밀번호.
- `CASSANDRA_EXPORTER_PORT`: Exporter 포트.
- `DEFAULT_DATABASE_DIR`: 영구 저장을 위한 기본 디렉토리.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Cassandra**: 내부적으로 `cassandra-node1`의 `9042` 포트(기본 클라이언트 포트)를 통해 접근 가능합니다. (호스트 포트 매핑은 주석 처리되어 있음)
- **Metrics**: `cassandra-exporter`의 `${CASSANDRA_EXPORTER_PORT}` 포트를 통해 접근 가능합니다.

## 볼륨

- `cassandra-node1-volume`: Cassandra 데이터의 영구 저장소.
- `cassandra-exporter-volume`: Exporter 설정 파일.
