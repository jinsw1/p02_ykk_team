# 1. 파이썬 3.10 버전의 가벼운(slim) 운영체제를 베이스로 사용합니다.
FROM python:3.10-slim

# 2. 컨테이너 내부의 작업 폴더를 /app으로 지정합니다.
WORKDIR /app

# 3. 라이브러리 설치 명세서를 먼저 복사하고 설치합니다.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. 현재 폴더(lunch_app)의 모든 소스코드를 컨테이너 안으로 복사합니다.
COPY . .

# 5. FastAPI가 사용할 8000번 포트를 열어둡니다.
EXPOSE 8000

# 6. 컨테이너가 켜질 때 서버를 실행하는 명령어입니다.
CMD ["uvicorn", "app_fastapi:app", "--host", "0.0.0.0", "--port", "8000"]