# Apache Airflow

## 개요

이 디렉토리는 Apache Airflow 실행을 위한 Docker Compose 구성을 포함합니다. API 서버, 스케줄러, DAG 프로세서, 워커, 트리거러, 그리고 Celery 워커 모니터링을 위한 Flower 서비스를 포함합니다.

## 서비스

- **airflow-apiserver**: 웹 서버 및 API.
- **airflow-scheduler**: DAG 스케줄링 담당.
- **airflow-dag-processor**: DAG 파일 파싱 담당.
- **airflow-worker**: Celery를 사용하여 태스크 실행.
- **airflow-triggerer**: 지연 가능한(deferrable) 오퍼레이터 실행.
- **flower**: Celery 워커 모니터링 도구.
- **airflow-init**: 초기화 작업(DB 마이그레이션, 사용자 생성 등) 수행.
- **airflow-cli**: CLI 명령 실행을 위한 컨테이너.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 필요한 환경 변수가 정의된 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `AIRFLOW_IMAGE_NAME`: Airflow 이미지 태그 (기본값: `apache/airflow:3.1.3`).
- `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_HOSTNAME`: 데이터베이스 연결 정보.
- `REDIS_PASSWORD`, `REDIS_NODE_NAME`, `REDIS_PORT`: Celery 브로커를 위한 Redis 연결 정보.
- `AIRFLOW_UID`: 파일 권한을 위한 사용자 ID.
- `AIRFLOW_HOST_PORT`: Airflow UI 호스트 포트.
- `FLOWER_HOST_PORT`: Flower UI 호스트 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

로그 확인:

```bash
docker-compose logs -f
```

## 접속

- **Airflow UI**: `http://localhost:${AIRFLOW_HOST_PORT}` (`.env` 파일의 실제 포트 확인)
- **Flower UI**: `http://localhost:${FLOWER_HOST_PORT}`

## 볼륨

- `airflow-dags`: DAG 파일 저장.
- `airflow-logs`: 실행 로그 저장.
- `airflow-config`: 설정 파일 저장.
- `airflow-plugins`: 커스텀 플러그인 저장.
