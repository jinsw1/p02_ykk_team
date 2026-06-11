
#### packer 초기화 및 이미지 등록

```bash

packer init .
# 변수 파일 지정 packer 빌드
packer build -var-file="variables.pkrvars.hcl" .

```
