
```bash
##############################
DEV-세팅
##############################
# 인프라 구성
  1. terraform/envs/dev 디렉토리 이동
  2. terraform.tfvars 아래 내용 값 넣어 파일추가 (.gitignore)
     - 경로 : terraform/envs/dev/terraform.tfvars 
	 - 내용

		host_name          = "project02"
		tailnet_name       = ""
		tailscale_api_key  = ""
		tailscale_auth_key = ""

		cloudflare_api_token = ""
		domain_name          = ""
		cloudflare_zone_id   = ""

  3. terraform apply
    - terraform/envs/dev 위치에서
	> terraform init
	> terraform plan
  	> terraform apply --auto-approve

	- apply 완료시 anisble 폴더에 inventory 생성됨

# 앤서블 실행_dev ( 초기 서버구성 및 초기 서비스 구동 )
  1. bootstrap.yml 실행
    - 경로 : ansible 디렉토리에서 실행
	> ansible-playbook -i inventories/bootstrap/inventory.yml playbooks/bootstrap.yml -e env=dev

  2. site.yml 실행
    - 경로 : ansible 디렉토리에서 실행
	> ansible-playbook -i inventories/dev/inventory.yml playbooks/site.yml -e env=dev

# 웹서비스 접속
  - https://www.도메인


##############################
Staging-세팅
##############################

# 인프라 구성
  1. terraform/envs/staging 디렉토리 이동
  2. terraform.tfvars 아래 내용 값 넣어 파일추가 (.gitignore)
     - 경로 : terraform/envs/staging/terraform.tfvars 
	 - 내용

		host_name          = "project02"
		#tailnet_name       = ""
		#tailscale_api_key  = ""
		#tailscale_auth_key = ""

		cloudflare_api_token = ""
		domain_name          = ""
		cloudflare_zone_id   = ""

  3. terraform apply
    - terraform/envs/staging 위치에서
	> terraform init
	> terraform plan	
  	> terraform apply --auto-approve

	- apply 완료시 anisble/inventories/staging 폴더에 inventory 생성됨


# 앤서블 실행_staging ( 초기 서버구성 및 초기 서비스 구동 )
  1. bootstrap.yml 실행
    - 경로 : ansible 디렉토리에서 실행
	> ansible-playbook -i inventories/staging/inventory-bootstrap.yml playbooks/bootstrap.yml

  2. site.yml 실행
    - 경로 : ansible 디렉토리에서 실행
	> ansible-playbook -i inventories/staging/inventory.yml playbooks/site.yml -e env=staging

ansible-playbook -i inventories/staging/inventory-bootstrap.yml


```