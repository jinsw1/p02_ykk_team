```bash
##############################
# Terraform Backend 설정
##############################
1. Terraform Backend 설정
- ykk_team/terraform/envs/backend  이동 후
> terraform init
> terraform plan
> terraform apply --auto-approve

2. Terraform infra 설정
- ykk_team/terraform/envs/infra  이동 후
> terraform init
> terraform plan
> terraform apply --auto-approve

	2-1. infra - Ansible 초기구성
	- ykk_team/ansible  이동 후
	> ansible-playbook -i inventories/infra/inventory_bootstrap.yml playbooks/bootstrap.yml
	> ansible-playbook -i inventories/infra/inventory.yml playbooks/infra_site.yml

	2-2. 그라파나 / 프로메테우스 접속확인
	  - 테일스테일에 등록되어 있는 project02의 ip
	  - http:[project02 ip]:3000
	  - http:[project02 ip]:9090

3. Terraform prod 설정
- ykk_team/terraform/envs/prod  이동 후
> terraform init
> terraform plan
> terraform apply --auto-approve

	3-1. infra - Ansible 초기구성
	- ykk_team/ansible  이동 후
	> ansible-playbook -i inventories/prod/inventory_bootstrap.yml playbooks/bootstrap.yml
	> ansible-playbook -i inventories/prod/inventory.yml playbooks/site.yml	-e env=prod

	3-2. 프로메테우스 노드 추가 되었는지 확인
	  - http://[project02 ip]:9090

	3-3. 클라우드플레어 대표도메인으로 접속 테스트!!!!
		ex) www.infrastudy.store

4. Terraform staging 설정
- ykk_team/terraform/envs/staging  이동 후
> terraform init
> terraform plan
> terraform apply --auto-approve

	4-1. staging - Ansible 초기구성
	- ykk_team/ansible  이동 후
	> ansible-playbook -i inventories/staging/inventory_bootstrap.yml playbooks/bootstrap.yml
	> ansible-playbook -i inventories/staging/inventory.yml playbooks/site.yml -e env=staging

	4-2. 프로메테우스 노드 추가 되었는지 확인
	  - http:[project02 ip]:9090

	4-3. 클라우드플레어 대표도메인으로 접속 테스트!!!!
		ex) staging.infrastudy.store

5. CI/CD 는... 죄송합니다... 체력이.... (조금만 마무리 하면됩니다... )
main / dev / staging / prod 나누려구요....

6. staging Destroy 확인
- ykk_team/terraform/envs/staging  이동 후
> terraform init
> terraform plan
> terraform destroy --auto-approve

	6-1. 기존 prod 영향 없는지 확인
	  - 웹페이지 접속 및 작동확인!!!
	  - 프로메테우스 모니터링에서 제외 되는지도 확인!!!



































5. prod - Ansible 초기구성
- ykk_team/ansible  이동 후
> ansible-playbook -i inventories/infra/inventory_bootstrap.yml playbooks/bootstrap.yml
> ansible-playbook -i inventories/infra/inventory.yml playbooks/infra_site.yml








ansible-playbook -i inventories/infra/inventory_bootstrap.yml playbooks/bootstrap.yml

ansible-playbook -i inventories/prod/inventory_bootstrap.yml playbooks/bootstrap.yml
ansible-playbook -i inventories/prod/inventory.yml playbooks/site.yml -e env=prod


ansible-playbook -i inventories/staging/inventory_bootstrap.yml playbooks/bootstrap.yml

ansible-playbook -i inventories/staging/inventory.yml playbooks/site.yml -e env=staging




 > ansible-playbook -i inventories/infra/inventory.yml playbooks/bootstrap.yml -e env=dev




````



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



빈 커밋!!!

> git commit --allow-empty -m "Trigger GitHub Actions"
> git push origin dev/jinsw

```