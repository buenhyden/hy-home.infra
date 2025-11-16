# Base off the official python image
# Define a common stage for dev and prod images called base
FROM node:current-slim AS node_base
LABEL version="0.1" creator="chochyjj@gmail.com" description="Node current-slim"
# Set environment variables
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
# ENV NODE_VERSION=22.5.0
# ENV NVM_DIR=/root/.nvm
# ENV NVM_VERSION=v0.39.7
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates systemd openssh-server default-libmysqlclient-dev build-essential libpq-dev apt-utils gcc g++ git git-flow wget curl gfortran cmake pkg-config locales \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
    && apt-get clean \
    && update-ca-certificates \
    && localedef -i ko_KR -c -f UTF-8 -A /usr/share/locale/locale.alias ko_KR.UTF-8
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN systemctl enable ssh
RUN groupadd docker
# RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash  \
#   && . $NVM_DIR/nvm.sh \
#   && nvm install $NODE_VERSION \
#   && nvm alias default $NODE_VERSION \
#   && nvm use default
# ENV NODE_PATH=$NVM_DIR/v$NODE_VERSION/lib/node_modules
# ENV PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
# /////////////////////////////////////////////////////////////////
# /////////////////////////////////////////////////////////////////
FROM node_base AS dev_nestjs
LABEL version="0.1" creator="chochyjj@gmail.com" description="NestJS" 
WORKDIR /
RUN npm i -g @nestjs/cli
RUN nest new project --language JS --package-manager npm
# Project
WORKDIR /project/
COPY ./Build-Default-Settings/_NestJS-Settings-Files/.vscode .vscode
COPY ./Build-Default-Settings/_NestJS-Settings-Files/README.md ./README.md
COPY ./Default-NestJS/.env.dev.example ./.env
# /////////////////////////////////////////////////////////////////
# github SSH key 사용
# /////////////////////////////////////////////////////////////////
COPY ./Build-Default-Settings/_Common-Settings-Files/.ssh /root/.ssh
COPY ./Build-Default-Settings/_NestJS-Settings-Files/.pre-commit-config.yaml .
COPY ./Build-Default-Settings/_NestJS-Settings-Files/.gitignore.nestjs .gitignore
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
RUN /project/zsh-in-docker.sh \
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
FROM node_base AS prod_nestjs
LABEL version="0.1" creator="chochyjj@gmail.com" description="NestJS"
# /////////////////////////////////////////////////////////////////