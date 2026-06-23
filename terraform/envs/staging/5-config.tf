# ../envs/dev/config.tf
############################################
# ANSIBLE INVENTORY GENERATION (IaC bootstrap)
############################################
# Bootstrap inventory (SSH root access / ubuntu user)
resource "local_file" "ansible_inventory_bootstrap" {
  filename = "${path.root}/../../../ansible/inventories/staging/inventory_bootstrap.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_was = {
          hosts = {
            "${module.project02_staging_was01_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/project02-was-key.pem"
            }

            "${module.project02_staging_was02_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              #ansible_ssh_private_key_file = "~/.ssh/${module.project02_was_ec2_key.key_name}.pem"
			  ansible_ssh_private_key_file = "~/.ssh/project02-was-key.pem"
            }
          }
        }

        ykk_db = {
          hosts = {
            "${module.project02_staging_db_ec2.private_ip}" = {
              ansible_user                 = "ubuntu"
              #ansible_ssh_private_key_file = "~/.ssh/${module.project02_db_ec2_key.key_name}.pem"
			  ansible_ssh_private_key_file = "~/.ssh/project02-db-key.pem"
            }
          }
        }
      }
    }
  })
}

# Dev inventory (admin access layer)
resource "local_file" "ansible_inventory_staging" {
  filename = "${path.root}/../../../ansible/inventories/staging/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_was = {
          hosts = {
            "${module.project02_staging_was01_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }

            "${module.project02_staging_was02_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }

        ykk_db = {
          hosts = {
            "${module.project02_staging_db_ec2.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }
      }
    }
  })
}