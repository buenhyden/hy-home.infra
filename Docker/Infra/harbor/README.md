# Harbor

## Description

- [releases](https://github.com/goharbor/harbor/releases)

## 설치방법

1. Harbor 다운로드

   ```bash
   wget https://github.com/goharbor/harbor/releases/download/vx.xx.x/harbor-offline-installer-vx.xx.x.tgz
   ```

2. 압축해제

   ```bash
   tar xvf harbor-offline-installer-vx.xx.x.tgz
   ```

3. harbor 폴더 이동후 harbor.yml.tmpl → harbor.yml 복사

   ```bash
   cd harbor
   cp harbor.yml.tmpl harbor.yml
   ```

4. harbor.yml 파일 수정

   ```bash
   vi harbor.yml
   ```

   ```yml
   # 왼쪽은 숫자는 2.9.1 버전의 yml 파일 기준 라인 No
   # 수정해야할 부분은
   # 5. hostname
   # 10. http용 port
   # 15. https용 port
   # 17. https용 certificate
   # 18. https용 private_key
   # 36. harbor_admin_password : 관리자용 비밀번호
   1 # Configuration file of Harbor
   2
   3 # The IP address or hostname to access admin UI and registry service.
   4 # DO NOT use localhost or 127.0.0.1, because Harbor needs to be accessed by external clients.
   5 hostname: dev.eq4all.co.kr
   6
   7 # http related config
   8 http:
   9 # port for http, default is 80. If https enabled, this port will redirect to https port
   10 port: 5001
   11
   12 # https related config
   13 https:
   14 # https port for harbor, default is 443
   15 port: 5000
   16 # The path of cert and key files for nginx
   17 certificate: /etc/nginx/ssl/cms.suzitown.com.crt.pem
   18 private_key: /etc/nginx/ssl/cms.suzitown.com.key.pem
   19
   20 # # Uncomment following will enable tls communication between all harbor components
   21 # internal_tls:
   22 # # set enabled to true means internal tls is enabled
   23 # enabled: true
   24 # # put your cert and key files on dir
   25 # dir: /etc/harbor/tls/internal
   26 # # enable strong ssl ciphers (default: false)
   27 # strong_ssl_ciphers: false
   28
   29 # Uncomment external_url if you want to enable external proxy
   30 # And when it enabled the hostname will no longer used
   31 #external_url: <https://dev.eq4all.co.kr:5001>
   32
   33 # The initial password of Harbor admin
   34 # It only works in first time to install harbor
   35 # Remember Change the admin password from UI after launching Harbor.
   36 harbor_admin_password: $PASSWORD
   ```

5. harbor 설치

   ```bash
   # 준비
   ./prepare

   # 설치 document를 참조하여 --with-trivy --with-chartmuseum등을 추가 할 수 있습니다
   ./install.sh
   ```

6. harbor 접속

   ```
   hostname
   ```

## Docker

### Docker Login

- Log in to a registry.
- container Registry에 빌드한 Image를 넣기 위해서는 docker에 login이 필요함
- [docker login](https://docs.docker.com/reference/cli/docker/login/)

```bash

docker login <docker container registry server>
Username:
Password:

Authenticating with existing credentials...
WARNING! Your password will be stored unencrypted in /home/hyden/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```

### Docker Image Push

- build된 docker image 명 앞에 내부 Registry 주소를 붙인다.
- 내부 registry 주소가 붙은 이미지를 docker push 명령어를 이용하여 container registry에 집어넣는다
- [docker image tag](https://docs.docker.com/reference/cli/docker/image/tag/)
- [docker image push](https://docs.docker.com/reference/cli/docker/image/push/)

```bash
docker tag <IMAGE NAME> <Registry 주소>/<Project 이름>/<IMAGE NAME>
docker push <Registry 주소>/<Project 이름>/<IMAGE NAME>
```

### Kubernetes Harbor 인증 등록

- kubernetes의 특정 namespace에 harbor 인증 등록
- 여기에서는 regcred 로 등록
- [kubectl create secret docker-registry](https://kubernetes.io/docs/reference/kubectl/generated/kubectl_create/kubectl_create_secret_docker-registry/)

```bash
kubectl create secret docker-registry <docker-registry secret NAME> --namespace <NAMESPACE> --docker-server=<docker container registry server> --docker-username=<docker container registry username> --docker-password=<docker container registry password> --docker-email=<email>
```
