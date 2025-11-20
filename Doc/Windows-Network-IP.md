# Windows network IP 확인

- netsh interface ipv4 show excludedportrange protocol=tcp
- netsh int ipv4 add excludedportrange protocol=tcp startport=2181 numberofports=1 store=persistent
