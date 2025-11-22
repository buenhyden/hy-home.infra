# PostgreSQL HA Cluster (Patroni)

**PostgreSQL** 고가용성(HA) 클러스터입니다.
**Patroni**를 사용하여 Failover를 관리하고, **Etcd**를 분산 저장소로 사용하며, **HAProxy**로 트래픽을 라우팅합니다.

## 🚀 서비스 구성

| 서비스명 | 역할 | 포트 |
| --- | --- | --- |
| **pg-0, pg-1, pg-2** | PostgreSQL 데이터베이스 노드 (Spilo) | `5432` (내부) |
| **etcd-1, etcd-2, etcd-3** | 분산 합의 저장소 (DCS) | `2379` |
| **pg-router** | HAProxy (Writer/Reader 분기) | `5000` (Write), `5001` (Read), `8404` (Metrics) |
| **pg-*-exporter** | 각 노드별 메트릭 Exporter | `9187` |

## 🛠 설정 및 환경 변수

- **접속 주소**:
    - **Write (Primary)**: `localhost:5000`
    - **Read (Replica)**: `localhost:5001` (Round Robin)
- **이미지**: `ghcr.io/zalando/spilo-17:4.0-p3` (PostgreSQL 17)
- **관리**: Patroni가 자동으로 리더 선출 및 복제를 관리합니다.

## 📦 볼륨 마운트

- `pg0-data`, `pg1-data`, `pg2-data`: 각 DB 노드 데이터
- `etcd1-data`, `etcd2-data`, `etcd3-data`: Etcd 데이터

## 🏃‍♂️ 실행 방법

```bash
docker compose up -d
```

## ⚠️ 주의사항
- **초기화**: 첫 실행 시 리더 선출 과정으로 인해 접속까지 약간의 시간이 소요됩니다.
- **비밀번호**: `.env.postgres` 파일 및 Docker Secret을 통해 관리됩니다.
