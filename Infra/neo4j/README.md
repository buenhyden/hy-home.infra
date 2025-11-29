# Neo4j

## 개요

이 디렉토리는 그래프 데이터베이스인 Neo4j를 실행하기 위한 Docker Compose 구성을 포함합니다. Bitnami 이미지를 사용합니다.

## 서비스

- **neo4j**: Neo4j 데이터베이스 서버.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `NEO4J_HOST_BOLT_PORT`: Bolt 프로토콜 호스트 포트.
- `NEO4J_BOLT_PORT`: 컨테이너 Bolt 포트 (기본값 7687).
- `NEO4J_PASSWORD`: 관리자 비밀번호.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Bolt**: `bolt://localhost:${NEO4J_HOST_BOLT_PORT}`
- **HTTP/HTTPS**: 현재 `docker-compose.yml`에서 HTTP/HTTPS 포트 매핑은 주석 처리되어 있습니다. 필요 시 주석을 해제하거나 내부 네트워크를 통해 접근해야 합니다.

## 볼륨

- `neo4j-volume`: Neo4j 데이터의 영구 저장소.
