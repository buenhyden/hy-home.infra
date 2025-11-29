# Nginx

## 개요

이 디렉토리는 Nginx 웹 서버를 실행하기 위한 Docker Compose 구성을 포함합니다. 정적 파일을 제공하거나 리버스 프록시로 사용될 수 있습니다.

## 서비스

- **nginx**: Nginx 웹 서버.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.
- `nginx.conf` 및 SSL 인증서 파일 (`certs` 디렉토리).

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `HTTP_HOST_PORT`: HTTP 호스트 포트.
- `HTTPS_HOST_PORT`: HTTPS 호스트 포트.
- `HTTP_PORT`, `HTTPS_PORT`: 컨테이너 내부 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **HTTP**: `http://localhost:${HTTP_HOST_PORT}`
- **HTTPS**: `https://localhost:${HTTPS_HOST_PORT}`

## 볼륨

- `./nginx.conf`: Nginx 설정 파일.
- `./certs`: SSL 인증서 디렉토리.
