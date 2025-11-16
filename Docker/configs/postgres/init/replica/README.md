# init/replica 디렉터리 안내

현재 postgres-replica 컨테이너는 다음 순서로 부팅됩니다.

1. `pg_basebackup` 로 postgres-primary의 데이터를 클론
2. 데이터 디렉터리에 `PG_VERSION` 이 생성됨
3. 이후 `docker-entrypoint.sh postgres` 실행 시,
   공식 postgres 이미지의 로직에 따라 initdb 단계가 **건너뛰어지고**,
   `/docker-entrypoint-initdb.d` 안의 스크립트도 실행되지 않습니다.

따라서 이 디렉터리(`init/replica`)에 있는 SQL/SH 스크립트는 기본적으로 실행되지 않습니다.

이 디렉터리를 사용할 수 있는 경우:

- replica 전용 튜닝을 별도 컨테이너/스크립트로 관리하고 싶을 때
- 다른 bootstrap 전략(예: initdb 후 logical replication 설정)을 시도해볼 때

지금 hy-home 인프라의 기본 전략에서는 **primary의 설정과 데이터가 복제**되므로,
별도의 replica init 스크립트는 필요하지 않습니다.
