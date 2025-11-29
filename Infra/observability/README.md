# Observability Stack

## 개요

이 디렉토리는 메트릭, 로그, 트레이스를 포함한 포괄적인 관측 가능성(Observability) 스택을 위한 Docker Compose 구성을 포함합니다.

## 서비스

- **prometheus**: 메트릭 저장 및 쿼리 시스템.
- **loki**: 로그 집계 시스템.
- **tempo**: 분산 트레이싱 백엔드.
- **grafana**: 시각화 및 분석 플랫폼.
- **alloy**: OpenTelemetry 수집기 (Grafana Alloy).
- **cadvisor**: 컨테이너 메트릭 수집기.
- **alertmanager**: Prometheus 경고 처리기.

## 필수 조건

- Docker 및 Docker Compose 설치.
- `Docker/Infra` 루트 디렉토리에 `.env` 파일.

## 설정

이 스택은 다음 환경 변수(`.env`에 정의됨)를 사용합니다:

- **포트**: `PROMETHEUS_HOST_PORT`, `LOKI_HOST_PORT`, `TEMPO_HOST_PORT`, `GRAFANA_HOST_PORT`, `ALLOY_HOST_PORT`, `ALERTMANAGER_HOST_PORT`.
- **자격 증명**: `GRAFANA_ADMIN_USERNAME`, `GRAFANA_ADMIN_PASSWORD`.
- **경고**: `SMTP_USERNAME`, `SMTP_PASSWORD`, `SLACK_ALERTMANAGER_WEBHOOK_URL`.

## 사용법

서비스 시작:

```bash
docker-compose up -d
```

## 접속

Traefik을 통해 다음 도메인으로 접근 가능합니다 (`.env`의 `DEFAULT_URL` 설정에 따라 다름):

- **Grafana**: `https://grafana.${DEFAULT_URL}` (설정된 관리자 계정 또는 Keycloak OAuth로 로그인)
- **Prometheus**: `https://prometheus.${DEFAULT_URL}`
- **Alertmanager**: `https://alertmanager.${DEFAULT_URL}`
- **Alloy UI**: `https://alloy.${DEFAULT_URL}`

로컬 포트 포워딩을 사용하는 경우 (활성화된 경우):

- **Grafana**: `http://localhost:${GRAFANA_HOST_PORT}`

## 볼륨

- Prometheus, Loki, Tempo, Grafana, Alertmanager 데이터에 대한 영구 볼륨이 구성되어 있습니다.
