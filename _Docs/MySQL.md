# MySQL

## Create User In MySQL

```SQL
CREATE USER 'replication'@'%' IDENTIFIED BY 'yBGygjV6PmxJGuM';
```

## Grant REPLICATION

```SQL
GRANT REPLICATION SLAVE ON _._ TO 'replication'@'%';
FLUSH PRIVILEGES;
RESET MASTER;
```

## MySQL in Replication

```SQL
STOP SLAVE;
```

```SQL
RESET SLAVE;
```

```SQL
CHANGE MASTER TO MASTER_HOST='mysql-rep1', \
 MASTER_USER='replication', MASTER_PASSWORD='yBGygjV6PmxJGuM', \
 MASTER_PORT=3306
CHANGE MASTER TO MASTER_HOST='mysql-rep1', \
 MASTER_USER='replication', MASTER_PASSWORD='yBGygjV6PmxJGuM', \
 MASTER_PORT=3306, MASTER_AUTO_POSITION=1;
start SLAVE;
```

```SQL
CREATE USER orc*client_user@'172.%' IDENTIFIED BY 'yBGygjV6PmxJGuM';
```

```SQL
GRANT SUPER, PROCESS, REPLICATION SLAVE, RELOAD ON*.\_ TO orc_client_user@'172.%';
```

```SQL
GRANT SELECT ON mysql.slave_master_info TO orc_client_user@'172.%';
```

```SQL
FLUSH PRIVILEGES;
```

```SQL
CREATE USER 'monitor'@'%' IDENTIFIED BY 'yBGygjV6PmxJGuM';
grant REPLICATION CLIENT on _._ to 'monitor'@'%';
FLUSH PRIVILEGES;
```

mysql -P6032 -uadmin -padmin --prompt "ProxySQL Admin>"
