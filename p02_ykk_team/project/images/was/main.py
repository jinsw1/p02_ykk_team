#~/project/docker/images/was/main.py
import os
from fastapi import FastAPI
from sqlalchemy import create_engine, text

app = FastAPI()

DATABASE_URL = os.getenv("DATABASE_URL")

# Nginx의 location /api/ 프록시 룰과 맞추기 위한 기본 경로
@app.get("/api/")
def hello():
    return {"message": "hello world"}

# DB 통신 테스트용 경로 (Nginx 연동 고려)
@app.get("/api/db-test")
def test_db_connection():
    if not DATABASE_URL:
        return {"status": "error", "message": "DATABASE_URL 환경 변수가 없습니다."}
    
    try:
        # SQLAlchemy로 데이터베이스 연결 시도
        engine = create_engine(DATABASE_URL)
        with engine.connect() as connection:
            # DB가 살아있는지 찔러보는 가장 단순한 쿼리
            result = connection.execute(text("SELECT 1"))
            return {
                "status": "success", 
                "message": "데이터베이스 연결에 완벽하게 성공했습니다!", 
                "result": [row[0] for row in result]
            }
    except Exception as e:
        return {"status": "error", "message": f"데이터베이스 연결 실패: {str(e)}"}