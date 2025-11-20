# Valkey

## Valkey Cluster 설정

```
valkey-cli --pass $PASSWORD --cluster call valkey-node-1:6379 flushall
valkey-cli --pass $PASSWORD --cluster call valkey-node-1:6379 cluster reset
valkey-cli --pass $PASSWORD --cluster call valkey-node-2:6379 cluster reset
valkey-cli --pass $PASSWORD --cluster call valkey-node-3:6379 cluster reset
```

```
valkey-cli --pass $PASSWORD --cluster create valkey-node-1:6379 valkey-node-2:6379 valkey-node-3:6379
```

```
valkey-cli --pass $PASSWORD --cluster add-node valkey-node-0-slave:6380 valkey-node-0:6379 --cluster-slave
valkey-cli --pass $PASSWORD --cluster add-node valkey-node-1-slave:6382 valkey-node-1:6381 --cluster-slave
valkey-cli --pass $PASSWORD --cluster add-node valkey-node-2-slave:6384 valkey-node-2:6383 --cluster-slave

valkey-cli --pass $PASSWORD --cluster create valkey-node-0:6379 valkey-node-1:6381 valkey-node-2:6383 valkey-node-0-slave:6380 valkey-node-1-slave:6382 valkey-node-2-slave:6384 --cluster-replicas 1

valkey-cli --pass $PASSWORD --cluster check valkey-node-0:6379

valkey-cli --pass $PASSWORD -h predixy -p 7617 info
valkey-cli --pass $PASSWORD -h predixy -p 7617 info

valkey-cli --pass $PASSWORD -h predixy -p 7617 set test success
valkey-cli --pass $PASSWORD -p 7617 -h predixy get **hello**
```
