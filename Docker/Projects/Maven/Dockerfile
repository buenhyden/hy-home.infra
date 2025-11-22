# Base off the official python image
# Define a common stage for dev and prod images called base
FROM openjdk:22-jdk-slim AS java_maven_base
LABEL version="0.1" creator="chochyjj@gmail.com" description="Java Spring"
# /////////////////////////////////////////////////////////////////
ENV TZ=Asia/Seoul
# Set the Maven version
ARG DEBIAN_FRONTEND=noninteractive
ARG JAR_FILE=*.jar
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates systemd default-libmysqlclient-dev build-essential libpq-dev apt-utils git git-flow curl wget openssh-server locales gcc \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && update-ca-certificates \
    && localedef -i ko_KR -c -f UTF-8 -A /usr/share/locale/locale.alias ko_KR.UTF-8
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN systemctl enable ssh
RUN groupadd docker
# Project
RUN mkdir /project/
COPY ./Build-Default-Settings/_Spring-Settings-Files/.vscode .vscode
COPY ./Build-Default-Settings/_Spring-Settings-Files/README.maven.md ./README.md
# /////////////////////////////////////////////////////////////////
# /////////////////////////////////////////////////////////////////
FROM java_maven_base AS dev_spring_maven
LABEL version="0.1" creator="chochyjj@gmail.com" description="Java Spring"
WORKDIR /project/
RUN mkdir /project/test
RUN mkdir /project/docs
RUN mkdir /project/styles
COPY ./Default-Spring-Maven/.env.dev.example ./.env
COPY ./Default-Spring-Maven/project/.mvn /project/.mvn
COPY ./Default-Spring-Maven/project/src /project/src
COPY ./Default-Spring-Maven/project/mvnw /project/mvnw
COPY ./Default-Spring-Maven/project/pom.xml /project/pom.xml
# /////////////////////////////////////////////////////////////////
# github SSH key 사용
# /////////////////////////////////////////////////////////////////
COPY ./Build-Default-Settings/_Common-Settings-Files/.ssh /root/.ssh
COPY ./Build-Default-Settings/_Spring-Settings-Files/.gitignore.spring.maven .gitignore
RUN git config --global core.editor "code --wait"
RUN git config --global user.email "chochyjj@gmail.com"
RUN git config --global user.name "Hyunyoun Jo"
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa.pub
# /////////////////////////////////////////////////////////////////
# zsh 설치 : 삭제 가능
# /////////////////////////////////////////////////////////////////
COPY ./Build-Default-Settings/_Common-Settings-Files/zsh-in-docker.sh .
RUN chmod 755 /project/zsh-in-docker.sh
RUN bash /project/zsh-in-docker.sh \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'
# /////////////////////////////////////////////////////////////////
ENTRYPOINT [ "zsh" ]
# /////////////////////////////////////////////////////////////////