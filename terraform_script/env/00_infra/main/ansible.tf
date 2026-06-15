############################################
# Ansible - inventory.yml
############################################

resource "local_file" "ansible_inventory_bootstrap" {
	filename = "${path.root}/../../../01_ansible/inventories/dev/inventory.yml"
    content = yamlencode({
        all = {
            children = {
                ykk_infra = {
                    hosts = {
                        "${module.project02_infra_ec2.private_ip}" = {
                            ansible_user = "ec2-user"
                            ansible_ssh_private_key_file = "~/.ssh/${module.project02_infra_ec2_key.key_name}.pem"
                        }
                    }
                }					
                ykk_was = {
                    hosts = {
                        "${module.project02_was01_ec2.private_ip}" = {
                            ansible_user = "ec2-user"
                            ansible_ssh_private_key_file = "~/.ssh/${module.project02_was_ec2_key.key_name}.pem"
                        }

					    "${module.project02_was02_ec2.private_ip}" = {
					      ansible_user = "ec2-user"
					      ansible_ssh_private_key_file = "~/.ssh/${module.project02_was_ec2_key.key_name}.pem"
					    }						
                    }
                }
                ykk_db = {
                    hosts = {
                        "${module.project02_db_ec2.private_ip}" = {
                            ansible_user = "ec2-user"
                            ansible_ssh_private_key_file = "~/.ssh/${module.project02_db_ec2_key.key_name}.pem"
                        }
                    }
                }				
            }
        }
    })
}

resource "local_file" "ansible_config"{
	filename = "${path.root}/../../../01_ansible/ansible.cfg"
    content = <<-EOF
        [defaults]
        inventory = ./inventories/dev/inventory.yml
        roles_path = ./roles
        host_key_checking = False
    EOF
}