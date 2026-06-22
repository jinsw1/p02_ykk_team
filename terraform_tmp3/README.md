
### 스크립트 실행

#### 실행 권한 부여 (최초 1회)
chmod +x script.sh

- 실행 디렉토리 : terraform/
####  공통 실행
```bash
./script.sh
    # 스크립트 내부 실행 순서
    # 1. envs/backend/ 디렉토리 프로비저닝 (s3 & dynamoDB 생성)
    # 2. envs/infra/ 디렉토리 프로비저닝 (기본 인프라 생성 및 infra.tfstate 저장)

# dev 환경 실행
./script.sh dev

# staging 환경 실행
./script.sh staging

# prod 환경 실행
./script.sh prod
```


### 삭제
- 실행 디렉토리 : terraform/

```bash
# dev 삭제
./script.sh dev --destroy
# infra -> backend 순 삭제
./script.sh --destroy

# staing 삭제
./script.sh staing --destroy
./script.sh --destroy

# prod 삭제
./script.sh dev --destroy
./script.sh --destroy
```
