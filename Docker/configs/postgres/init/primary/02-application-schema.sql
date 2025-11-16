-- 02-application-schema.sql
--
-- hy_home 애플리케이션용 최소 스키마 예시
-- (필요에 맞춰 자유롭게 수정)

\c hy_home

CREATE SCHEMA IF NOT EXISTS app;

-- 예시: 사용자 테이블
CREATE TABLE IF NOT EXISTS app.users (
  id          BIGSERIAL PRIMARY KEY,
  email       TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 예시: 이벤트 로그 테이블
CREATE TABLE IF NOT EXISTS app.event_logs (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT REFERENCES app.users(id),
  event_type  TEXT NOT NULL,
  payload     JSONB,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 업데이트 트리거 예시 (선택)
CREATE OR REPLACE FUNCTION app.set_updated_at()
RETURNS TRIGGER AS
$$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON app.users;

CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON app.users
FOR EACH ROW EXECUTE FUNCTION app.set_updated_at();
