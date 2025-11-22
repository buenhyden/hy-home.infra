# Ollama & Local AI Stack

**Ollama**는 로컬에서 LLM(Large Language Model)을 실행하기 위한 도구입니다.
이 구성은 **Ollama**를 중심으로 **Open WebUI**(채팅 UI), **Qdrant**(벡터 DB), **n8n**(자동화)을 통합하여 RAG(Retrieval-Augmented Generation) 파이프라인을 구축합니다.
또한 **Ollama Exporter**를 통해 메트릭을 수집하여 모니터링할 수 있습니다.

### 설치 및 실행 (Step-by-Step)

#### 1단계: 컨테이너 실행

기존 컨테이너가 있다면 지우고 새로 시작.

```powershell
docker compose down
docker compose up -d
```

#### 2단계: 필수 모델 다운로드 (중요\!)

자동화를 하려면 **대화용 모델**과 **임베딩용 모델** 두 가지가 반드시 필요.

```powershell
# 대화용 모델 (Llama 3) 다운로드
docker compose exec ollama ollama pull llama3

# 임베딩 모델 (nomic-embed-text) 다운로드 - RAG 핵심
docker compose exec ollama ollama pull nomic-embed-text
```

-----

### 3\. 접속 및 설정 가이드

이제 3개의 대시보드에 접속할 수 있다.

#### 1\. Open WebUI (채팅)

  * **주소:** `http://localhost:3000`
  * **확인:** 채팅창에 문서를 업로드하고 질문해 보세요. 내부적으로 Qdrant에 저장.

#### 2\. Qdrant (데이터베이스 시각화)

  * **주소:** `http://localhost:6333/dashboard`
  * **기능:** Open WebUI나 n8n이 데이터를 잘 넣고 있는지 눈으로 확인할 수 있는 관리자 화면. (초기에는 비어있을 수 있다.)

#### 3\. n8n (자동화 툴) - 여기가 핵심\!

  * **주소:** `http://localhost:5678`
  * **초기 설정:** 계정 생성(로컬 전용) 후 "Start from scratch"를 선택.

**[n8n에서 Qdrant 연결하는 법]**
n8n 캔버스에서 `Qdrant` 노드를 추가할 때 'Credential'을 물어본다. 

1.  **Credential Type:** `Qdrant API` 선택
2.  **URL:** `http://qdrant:6333` (도커 내부 주소이므로 `localhost`가 아닌 `qdrant`를 쓴다.)
3.  **API Key:** 비워두세요 (로컬 설정이라 비밀번호 없음).

**[n8n에서 Ollama 연결하는 법]**

1.  **Credential Type:** `Ollama API` 불가 시 `No Auth` 선택 가능(노드 버전에 따라 다름)
2.  **Base URL:** `http://ollama:11434`



