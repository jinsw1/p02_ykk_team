#~/project/docker/images/was/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 파이썬 패키지 설치 (캐시를 남기지 않아 이미지 용량 최적화)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 소스 복사
COPY main.py .

# 컨테이너 구동 시 실행할 명령어 (8000번 포트 개방)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]