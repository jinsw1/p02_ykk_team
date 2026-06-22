# ../envs/staging/config.tf
resource "local_file" "ansible_inventory_bootstrap" {
  filename = "${path.root}/../../../ansible/inventories/staging/inventory-bootstrap.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_was = {
          hosts = {
            "${module.stg_was01.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/project02-was-key.pem"
            }
            "${module.stg_was02.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/project02-was-key.pem"
            }
          }
        }
        ykk_db = {
          hosts = {
            "${module.stg_db.private_ip}" = {
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = "~/.ssh/project02-db-key.pem"
            }
          }
        }
      }
    }
  })
}

resource "local_file" "ansible_inventory_staging" {
  filename = "${path.root}/../../../ansible/inventories/staging/inventory.yml"

  content = yamlencode({
    all = {
      children = {
        ykk_was = {
          hosts = {
            "${module.stg_was01.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
            "${module.stg_was02.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }
        ykk_db = {
          hosts = {
            "${module.stg_db.private_ip}" = {
              ansible_user                 = "ykk-admin"
              ansible_ssh_private_key_file = "~/.ssh/ykkadmin-key.pem"
            }
          }
        }
      }
    }
  })
}