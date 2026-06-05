
# YKK Team Security Baseline Draft
Ubuntu 환경 기준으로
기본적인 보안 설정을 검토용으로 정리한 초안

현재는 운영 영향이 적은 항목만 우선 적용
Docker / Nginx / Secret Management 관련 항목은
정책 방향 및 적용 예정 내용 위주로 작성

-------------------------------------------------

### Password Policy

* 비밀번호 최대 사용 기간 설정
* 비밀번호 최소 유지 기간 설정
* 비밀번호 만료 전 경고 설정
* 로그인 실패 횟수 제한
* 로그인 실패 잠금 시간 설정 > 검증 필요로 일단 뺀 상태

### Package Security

* telnetd 제거
* rsh-server 제거

### Audit Log

* auditd 설치
* auditd 서비스 활성화

### SYSCTL Security

* ASLR 활성화
* SYN Flood 방어
* ICMP Redirect 차단
* Source Route 차단

---------------------------------------------------

### Secret Management

* .env / pem / key / token 파일 관리 정책 검토
* GitHub Secret 사용 검토
* 운영 계정 분리 검토

### Docker Security

* Root Container 제한 검토
* Privileged 옵션 제한 검토
* 불필요 포트 최소화 검토
* Trivy 이미지 점검 검토

### Nginx Security

* server_tokens off 검토
* autoindex off 검토
* HTTPS Redirect 검토
* Security Header 적용 검토
* 업로드 크기 제한 검토
* HTTP Method 제한 검토

