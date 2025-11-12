# proxy SQL

## proxy에서 hostgroup에 db 서버 정보 입력

### 쓰기 그룹(10)

```SQL
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES(10, 'mysql-rep1', 3306);
```

### 읽기 그룹(20)

```SQL
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES(20, 'mysql-rep1', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES(20, 'mysql-rep2', 3306);
```

## 호스트 그룹 설정

### VALUES(쓰기,읽기,쓰기/읽기 구분 기준, '')

```SQL
INSERT INTO mysql_replication_hostgroups VALUES(10, 20, 'read_only', '');
```

### 로드

```SQL
LOAD MYSQL SERVERS TO RUNTIME;
```

### 설정 영구적인 저장

```SQL
SAVE MYSQL SERVERS TO DISK;
```

### proxy에서 어플리케이션 user 정보 입력

````SQL
INSERT INTO mysql_users(username, password, default_hostgroup, transaction_persistent) VALUES('hyden', 'pbM5UUTVao4S9Hr', 10, 0);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

### proxy에서 쿼리 룰 정보 입력
```SQL
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup) VALUES(1, 1, '^SELECT.*FOR UPDATE$', 10);
INSERT INTO mysql_query_rules(rule_id, active, match_pattern, destination_hostgroup) VALUES(2, 1, '^SELECT', 20);
LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
````
