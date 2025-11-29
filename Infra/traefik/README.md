# Traefik

## 개요

이 디렉토리는 최신 HTTP 리버스 프록시 및 로드 밸런서인 Traefik을 실행하기 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **traefik**: Traefik 프록시.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 서비스는 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- `TRAEFIK_DASHBOARD_HOST_PORT`: Traefik 대시보드 포트.
- `HTTP_HOST_PORT`, `HTTPS_HOST_PORT`: HTTP/HTTPS 진입 포트.
- `TRAEFIK_METRICS_HOST_PORT`: 메트릭 포트.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

- **HTTP**: 포트 80 (또는 설정된 `HTTP_HOST_PORT`)
- **HTTPS**: 포트 443 (또는 설정된 `HTTPS_HOST_PORT`)
- **Dashboard**: `https://dashboard.${DEFAULT_URL}` (Traefik 자체 라우팅) 또는 `http://localhost:${TRAEFIK_DASHBOARD_HOST_PORT}`

## 볼륨

- `./traefik.yml`: 설정 파일.
- `./certs`: SSL 인증서.
- `./dynamic`: 동적 설정 파일.

## 인증서 생성 (mkcert)

로컬 개발용 인증서 생성 예시:

```bash
mkcert -key-file key.pem -cert-file cert.pem localhost 127.0.0.1 ::1 *.localhost hy-home.local *.hy-home.local *.minio.hy-home.local
```

*참고: mkcert에서 와일드카드는 1단계만 적용됩니다.*

## 해시 생성 (htpasswd)

Basic Auth 미들웨어용 해시 생성:

```bash
docker run --rm httpd:alpine htpasswd -nb admin secure_password
```
