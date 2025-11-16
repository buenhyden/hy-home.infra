-- 01-replication-and-exporter.sql
--
-- primary 노드 최초 생성 시 실행된다.
-- replication 전용 계정 + exporter 계정 + 기본 replication 설정 세팅

------------------------------
-- 1) replication 계정 생성
------------------------------
DO
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'replicator'
  ) THEN
    CREATE ROLE replicator
      WITH REPLICATION LOGIN PASSWORD 'pbM5UUTVao4S9Hr';
  END IF;
END
$$;

------------------------------
-- 2) replication 관련 파라미터 튜닝
------------------------------
-- 작은 테스트 클러스터라 적당히 여유 있게 설정
ALTER SYSTEM SET wal_level = 'replica';
ALTER SYSTEM SET max_wal_senders = '10';
ALTER SYSTEM SET max_replication_slots = '10';
ALTER SYSTEM SET hot_standby = 'on';
ALTER SYSTEM SET wal_keep_size = '512MB';

-- 설정 반영
SELECT pg_reload_conf();

------------------------------
-- 3) Prometheus Exporter 계정 생성
------------------------------
DO
$$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_roles WHERE rolname = 'postgres_exporter'
  ) THEN
    CREATE ROLE postgres_exporter
      WITH LOGIN PASSWORD 'TF6NJa8Sp8tN8oy'
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT;
  END IF;
END
$$;

-- exporter가 필요한 통계/상태 뷰에 접근할 수 있게 권한 부여
GRANT CONNECT ON DATABASE hy_home TO postgres_exporter;

\c hy_home

GRANT USAGE ON SCHEMA public TO postgres_exporter;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres_exporter;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT ON TABLES TO postgres_exporter;

-- 추가적으로 pg_monitor 역할을 부여하면 다양한 통계 뷰를 패키지로 얻을 수 있음
GRANT pg_monitor TO postgres_exporter;
