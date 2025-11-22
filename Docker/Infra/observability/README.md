# Observability Stack

이 디렉토리는 시스템의 **모니터링(Monitoring), 로깅(Logging), 트레이싱(Tracing)**을 위한 통합 관측성(Observability) 스택을 구성합니다.
**LGTM** (Loki, Grafana, Tempo, Mimir/Prometheus) 스택을 기반으로 합니다.

## 🚀 서비스 구성

| 서비스명 | 역할 | 포트 |
| --- | --- | --- |
| **prometheus** | 메트릭 수집 및 저장 | `9090` |
| **loki** | 로그 수집 및 저장 | `3100` (Host Exposed) |
| **tempo** | 분산 트레이싱 저장소 | `3200`, `4317`(OTLP) |
| **grafana** | 데이터 시각화 대시보드 | `3000` |
| **alloy** | OpenTelemetry Collector (메트릭/로그/트레이스 수집기) | `12345` |
| **cadvisor** | 컨테이너 리소스 메트릭 수집 | `8080` |
| **alertmanager** | 경고(Alert) 발송 관리 | `9093` |

## 🛠 설정 및 환경 변수

- **Grafana**: `admin` / `GRAFANA_ADMIN_PASSWORD` (환경 변수)
- **데이터 흐름**:
    - **Logs**: App -> Alloy -> Loki -> Grafana
    - **Metrics**: App/Exporters (n8n, Qdrant, Ollama, Redis, Postgres, HAProxy) -> Alloy/Prometheus -> Grafana
    - **Traces**: App -> Alloy -> Tempo (S3 Backend) -> Grafana

## 💾 스토리지 백엔드 (S3)

- **Tempo**: MinIO(`tempo-bucket`)를 백엔드 스토리지로 사용하도록 설정되었습니다.
- **Metrics Generator**: Tempo가 트레이스 데이터를 분석하여 RED(Rate, Errors, Duration) 메트릭을 생성하고 Prometheus로 전송합니다.

## 📦 볼륨 마운트

- 각 서비스(`prometheus`, `loki`, `tempo`, `grafana`, `alertmanager`)는 영구 저장을 위한 도커 볼륨을 사용합니다.
- 설정 파일들은 호스트의 서브 디렉토리(`prometheus/`, `loki/` 등)에서 마운트됩니다.

## 🏃‍♂️ 실행 방법

```bash
docker compose up -d
```

## ⚠️ 주의사항
- **리소스**: 전체 스택 실행 시 상당한 메모리와 CPU를 소모할 수 있습니다.
- **네트워크**: `infra_net` 네트워크를 통해 다른 서비스들의 메트릭을 수집합니다.
