# 07_ansible.tf

resource "local_file" "ubuntu_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    bastion_ip   = module.ec2_bastion.public_ip
    proxy_ip     = module.ec2_proxy.public_ip
    app_ip       = module.ec2_app.private_ip
    db_ip        = module.ec2_db.private_ip
    ansible_user = "ubuntu"
  })
  filename = "${path.module}/../../../ansible/inventories/ubuntu_inventory.ini"
}

resource "local_file" "ykk_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    bastion_ip   = module.ec2_bastion.public_ip
    proxy_ip     = module.ec2_proxy.public_ip
    app_ip       = module.ec2_app.private_ip
    db_ip        = module.ec2_db.private_ip
    ansible_user = "ykk"
  })
  filename = "${path.module}/../../../ansible/inventories/ykk_inventory.ini"
}
