# Syncthing

## 개요

이 디렉토리는 지속적인 파일 동기화 프로그램인 Syncthing을 실행하기 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **syncthing**: Syncthing 서버.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `SYNCTHING_SYNC_HOST_PORT`: 동기화 트래픽용 포트.
- `SYNCTHING_GUI_PORT`: 웹 GUI용 포트.
- `SYNCTHING_USERNAME`, `SYNCTHING_PASSWORD`: 웹 GUI 자격 증명.
- `PUID`, `PGID`: 파일 권한을 위한 사용자/그룹 ID.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **Web GUI**: `http://localhost:${SYNCTHING_GUI_PORT}`

## 볼륨

- `syncthing-volume`: 설정 및 메타데이터 저장.
- `resources-contents-volume`: 실제 동기화되는 디렉토리.
