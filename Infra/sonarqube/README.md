# SonarQube

## 개요

이 디렉토리는 SonarQube Community Edition을 실행하기 위한 Docker Compose 구성을 포함합니다. 외부 PostgreSQL 데이터베이스를 사용하도록 구성되어 있습니다.

## 서비스

- **sonarqube**: SonarQube 서버.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- 외부 PostgreSQL 서비스 실행 필요.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `SONARQUBE_PORT`: 컨테이너 포트.
- `SONAR_JDBC_URL`: 데이터베이스 연결 문자열.
- `SONAR_JDBC_USERNAME`, `SONAR_JDBC_PASSWORD`: 데이터베이스 자격 증명.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **SonarQube UI**: 구성된 포트 또는 Traefik을 통해 접근 가능 (설정에 따라 다름).

## 볼륨

- `sonarqube-data-volume`: 데이터 저장소.
- `sonarqube-extensions-volume`: 플러그인 저장소.
- `sonarqube-logs-volume`: 로그 저장소.
