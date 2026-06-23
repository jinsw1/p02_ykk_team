# ../envs/dev/config.tf
############################################
# ANSIBLE INVENTORY GENERATION (IaC bootstrap)
############################################
# Bootstrap inventory (SSH root access / ubuntu user)
resource "local_file" "ansible_inventory_bootstrap" {
  filename = "${path.root}/../../../ansible/inventories/bootstrap/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_infra = {
          hosts = {
            "${local.infra_private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/${local.infra_key_name}.pem"
            }
          }
        }

        ykk_was = {
          hosts = {
            "${module.project02_was01_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/${module.project02_was_ec2_key.key_name}.pem"
            }

            "${module.project02_was02_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/${module.project02_was_ec2_key.key_name}.pem"
            }
          }
        }

        ykk_db = {
          hosts = {
            "${module.project02_db_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/${module.project02_db_ec2_key.key_name}.pem"
            }
          }
        }
      }
    }
  })
}

# Dev inventory (admin access layer)
resource "local_file" "ansible_inventory_dev" {
  filename = "${path.root}/../../../ansible/inventories/dev/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_infra = {
          hosts = {
            "${local.infra_private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }

        ykk_was = {
          hosts = {
            "${module.project02_was01_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }

            "${module.project02_was02_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }

        ykk_db = {
          hosts = {
            "${module.project02_db_ec2.private_ip}" = {
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