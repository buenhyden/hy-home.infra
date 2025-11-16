# === Stage 1: "base" ===
# Python 설치 및 Poetry 설치, 환경 변수 설정
FROM python:3.12-slim as base
LABEL version="0.1" creator="chochyjj@gmail.com" description="Python 3.12"
# Prevent Python from writing .pyc files
ENV PYTHONDONTWRITEBYTECODE=1
# Ensure Python output is sent straight to terminal (good for logs)
ENV PYTHONUNBUFFERED=1
# Poetry configurations
ENV POETRY_VERSION=1.8.3
ENV POETRY_HOME="/opt/poetry"
# Create a virtual env in the project's root
ENV POETRY_VIRTUALENVS_IN_PROJECT=true
# Do not interactively ask questions
ENV POETRY_NO_INTERACTION=1
ENV TZ=Asia/Seoul
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
# Add Poetry to the system path
ENV PATH="$POETRY_HOME/bin:$PATH"
# Install Poetry
RUN pip install "poetry==$POETRY_VERSION"
# 4. 작업 디렉터리 설정
WORKDIR /app
RUN mkdir /app/test
RUN mkdir /app/docs 
# === Stage 2: "prod-deps" (Production Build Stage) ===
# "base" 스테이지를 상속받아 프로덕션 의존성만 설치
FROM base AS prod-deps

# Copy only the files needed to install dependencies
# This leverages Docker's layer caching
COPY ./pyproject.toml ./
# COPY ./poetry.lock ./

# Install *only* production dependencies
RUN poetry install --no-root --no-dev

# === Stage 3: "dev-deps" (Development Build Stage) ===
# "prod-deps" 스테이지를 상속받아 개발 의존성을 추가로 설치
FROM prod-deps AS dev-deps

# Copy files again in case they changed (though cache should hold)
COPY ./pyproject.toml ./
# COPY ./poetry.lock ./

# Install *all* dependencies (including dev)
# This will be fast as it only adds dev deps to the existing prod venv
RUN poetry install --no-root

# === Stage 4: "release" (Final Release Image) ===
# "base"의 깨끗한 환경에서 다시 시작 (Poetry 등 빌드 도구 제외)
FROM python:3.12-slim AS release

# Set the virtual env path created in the builder
ENV VIRTUAL_ENV=/app/.venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
# Ensure non-buffered output for logging
ENV PYTHONUNBUFFERED=1

# Create a non-root user for security
RUN useradd -m -s /bin/bash appuser
WORKDIR /app
USER appuser

# Copy the production virtual environment from the "prod-deps" stage
COPY --from=prod-deps --chown=appuser:appuser /app/.venv /app/.venv

# Copy the application source code
COPY --chown=appuser:appuser ./src ./src

# Command to run the application in production
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]


# === Stage 5: "dev" (Final Development Image) ===
# "dev-deps" 스테이지(모든 의존성 포함)에서 시작
FROM dev-deps AS dev
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates default-libmysqlclient-dev git git-flow \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && apt-get clean 
# Copy the application source code
# This is useful for VS Code devcontainers or if not using volume mounts
RUN mkdir /app/scripts/
COPY ./src ./src
COPY ./README.md ./README.md
COPY ./.gitignore ./
COPY ./.dockerignore ./
COPY ./.vscode/ ./.vscode/
COPY ./.pre-commit-config.yaml .
COPY ./.gitmessage .
COPY ./.ssh /root/.ssh
COPY scripts/zsh-in-docker.sh scripts/
# /////////////////////////////////////////////////////////////////
# github SSH key 사용
# /////////////////////////////////////////////////////////////////
RUN git config --global core.editor "code --wait"
RUN git config --global user.email "chochyjj@gmail.com"
RUN git config --global user.name "Hyunyoun Jo"
RUN chmod 600 /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa.pub
# /////////////////////////////////////////////////////////////////
# zsh 설치 : 삭제 가능
# /////////////////////////////////////////////////////////////////
RUN chmod 755 /app/scripts/zsh-in-docker.sh
RUN /app/scripts/zsh-in-docker.sh \
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
# Command to run the application in development mode
# --reload: Enables hot-reloading
# CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
# /////////////////////////////////////////////////////////////////
CMD [ "zsh" ]
# /////////////////////////////////////////////////////////////////