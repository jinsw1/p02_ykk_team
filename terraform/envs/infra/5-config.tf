# ../envs/infra/config.tf
############################################
# ANSIBLE INVENTORY GENERATION (IaC bootstrap)
############################################
# Bootstrap inventory (SSH root access / ubuntu user)
# inventory (admin access layer)
resource "local_file" "ansible_inventory_bootstrap" {
  filename = "${path.root}/../../../ansible/inventories/infra/inventory_bootstrap.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_infra = {
          hosts = {
            "${module.project02_infra_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/${module.project02_infra_ec2_key.key_name}.pem"
            }
          }
        }
      }
    }
  })
}

resource "local_file" "ansible_inventory_infra" {
  filename = "${path.root}/../../../ansible/inventories/infra/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_infra = {
          hosts = {
            "${module.project02_infra_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }
      }
    }
  })
}

# Ansible config file
resource "local_file" "ansible_config" {
  filename = "${path.root}/../../../ansible/ansible.cfg"

  content = <<-EOF
    [defaults]
    inventory = ./inventories/dev/inventory.yml
    roles_path = ./roles
    host_key_checking = False
  EOF
}