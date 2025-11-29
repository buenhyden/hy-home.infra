# MongoDB

## 개요

이 디렉토리는 MongoDB 레플리카 셋을 실행하기 위한 Docker Compose 구성을 포함합니다. 웹 기반 관리를 위한 Mongo Express와 Prometheus 모니터링을 위한 MongoDB Exporter도 포함되어 있습니다.

## 서비스

- **mongodb-rep1**: 레플리카 셋의 첫 번째 노드 (Primary/Secondary).
- **mongodb-rep2**: 레플리카 셋의 두 번째 노드 (Primary/Secondary).
- **mongo-express**: 웹 기반 MongoDB 관리 인터페이스.
- **mongodb-exporter**: MongoDB 메트릭을 위한 Prometheus Exporter.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `NOSQL_ROOT_USER`: MongoDB 루트 사용자 이름.
- `NOSQL_ROOT_PASSWORD`: MongoDB 루트 비밀번호.
- `MONGODB_HOST_REPLICASET_1_PORT`, `MONGODB_HOST_REPLICASET_2_PORT`: 각 노드의 호스트 포트.
- `MONGO_EXPRESS_PORT`: Mongo Express 호스트 포트.
- `MONGO_EXPORTER_PORT`: Exporter 호스트 포트.
- `MONGO_EXPRESS_CONFIG_BASICAUTH_USERNAME`, `MONGO_EXPRESS_CONFIG_BASICAUTH_PASSWORD`: Mongo Express 접속을 위한 Basic Auth 정보.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Mongo Express**: `https://mongo-express.${DEFAULT_URL}` (Traefik을 통해 접근) 또는 `http://localhost:${MONGO_EXPRESS_PORT}`
- **MongoDB**: `mongodb-rep1` 또는 `mongodb-rep2` 포트를 통해 직접 연결 가능.

## 볼륨

- `replicaset-*-mongo-data-volume`: 데이터베이스 데이터의 영구 저장소.
- `replicaset-*-mongo-conf-volume`: 설정 파일 저장소.
