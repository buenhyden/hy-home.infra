# ksqlDB

## 개요

이 디렉토리는 스트림 처리 애플리케이션을 위해 구축된 데이터베이스인 ksqlDB를 실행하기 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **ksqldb-node1**: ksqlDB 서버 노드.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- 실행 중인 Kafka 클러스터 (ksqlDB가 의존함).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `KSQLDB_HOST_PORT`: ksqlDB 호스트 포트.
- `KSQLDB_PORT`: 컨테이너 포트.
- `KAFKA_PORT`: Kafka 브로커 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **ksqlDB Server**: `http://localhost:${KSQLDB_HOST_PORT}`

## 볼륨

- `ksqldb-node-1-data-volume`: ksqlDB 데이터의 영구 저장소.
