# ../50_config/main.tf
############################################
# Ansible - inventory.yml
############################################
resource "local_file" "ansible_inventory_bootstrap" {
  filename = "${path.root}/../../../../ansible/inventories/dev/inventory.yml"
  content = yamlencode({
    all = {
      children = {
        ykk_infra = {
          hosts = {
            "${data.terraform_remote_state.compute.outputs.infra_private_ip}" = {
              ansible_user                  = "ec2-user"
              ansible_ssh_private_key_file  = "~/.ssh/${data.terraform_remote_state.compute.outputs.infra_key_name}.pem"
            }
          }
        }
        ykk_was = {
          hosts = {
            "${data.terraform_remote_state.compute.outputs.was01_private_ip}" = {
              ansible_user                  = "ec2-user"
              ansible_ssh_private_key_file  = "~/.ssh/${data.terraform_remote_state.compute.outputs.was_key_name}.pem"
            }
            "${data.terraform_remote_state.compute.outputs.was02_private_ip}" = {
              ansible_user                  = "ec2-user"
              ansible_ssh_private_key_file  = "~/.ssh/${data.terraform_remote_state.compute.outputs.was_key_name}.pem"
            }
          }
        }
        ykk_db = {
          hosts = {
            "${data.terraform_remote_state.compute.outputs.db_private_ip}" = {
              ansible_user                  = "ec2-user"
              ansible_ssh_private_key_file  = "~/.ssh/${data.terraform_remote_state.compute.outputs.db_key_name}.pem"
            }
          }
        }
      }
    }
  })
}

resource "local_file" "ansible_config" {
  filename = "${path.root}/../../../../ansible/ansible.cfg"
  content  = <<-EOF
    [defaults]
    inventory = ./inventories/dev/inventory.yml
    roles_path = ./roles
    host_key_checking = False
  EOF
}
