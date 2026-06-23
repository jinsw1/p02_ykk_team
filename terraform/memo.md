

### 스크립트 실행


- 실행 디렉토리 : ykk_team/terraform/
- 실행 권한 부여 (최초 1회)
    chmod +x script.sh

#### 프로비저닝
```bash
# 전체 apply (backend → infra → prod)
./script.sh


# staging apply
./script.sh staging
```

#### 삭제
```bash
# staging destroy
./script.sh staging --destroy

# 전체 destroy (prod → infra → backend)
./script.sh --destroy
```


```bash
# ansible 실행 디렉토리 : ykk_team/ansible/
# infra
ansible-playbook -i inventories/infra/inventory_bootstrap.yml playbooks/bootstrap.yml
ansible-playbook -i inventories/infra/inventory.yml playbooks/infra_site.yml
# prod
ansible-playbook -i inventories/prod/inventory_bootstrap.yml playbooks/bootstrap.yml
ansible-playbook -i inventories/prod/inventory.yml playbooks/site.yml -e env=prod

# staging
ansible-playbook -i inventories/staging/inventory_bootstrap.yml playbooks/bootstrap.yml
ansible-playbook -i inventories/staging/inventory.yml playbooks/site.yml -e env=staging
```