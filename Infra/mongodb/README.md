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

윈도우(Windows) 환경, 특히 Docker Desktop을 사용할 때 **"파일 권한(Permission)"** 문제는 가장 큰 골칫덩어리입니다.

MongoDB는 KeyFile의 권한이 \*\*반드시 400(읽기 전용)\*\*이어야 하고, 소유자가 \*\*999(mongodb 계정)\*\*여야만 실행됩니다. 하지만 윈도우(NTFS)에서 생성한 파일을 컨테이너로 마운트(Bind Mount)하면, **권한이 777(모두 허용)로 고정되어 MongoDB가 "보안상 위험하다"며 실행을 거부**합니다.

따라서 윈도우에서는 로컬 파일을 직접 마운트하지 말고, **"도커 볼륨(Docker Volume)"을 생성해서 그 안에 키 파일을 밀어넣는 방식**을 써야 100% 성공합니다.

다음 단계를 그대로 따라 하세요. (PowerShell 기준)

-----

### 1단계: KeyFile 저장용 도커 볼륨 생성

로컬 폴더 대신 도커가 관리하는 볼륨을 만듭니다. 이 공간은 리눅스 파일 시스템이므로 권한 제어가 완벽합니다.

```powershell
# 1. 도커 볼륨 생성
docker volume create mongo-key
```

### 2단계: 임시 컨테이너를 이용해 Key 생성 및 권한 설정

이 명령어는 `mongo-key` 볼륨에 `mongodb.key`를 생성하고, 권한(400)과 소유자(999:999)를 알맞게 설정한 뒤 종료되는 **1회성 명령어**입니다. (PowerShell에 복사해서 실행하세요.)

```powershell
docker run --rm -v mongo-key:/data/configdb alpine sh -c "apk add --no-cache openssl && openssl rand -base64 756 > /data/configdb/mongodb.key && chmod 400 /data/configdb/mongodb.key && chown 999:999 /data/configdb/mongodb.key && ls -l /data/configdb/mongodb.key"
```

- **실행 결과:** 마지막에 `-r-------- ... 999 999 ... mongodb.key` 같은 로그가 나오면 성공입니다.
