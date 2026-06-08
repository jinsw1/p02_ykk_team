
all:
  hosts:
    bastion:
      ansible_host: ${bastion_ip}
      ansible_user: ${ansible_user}
      ansible_ssh_private_key_file: ~/.ssh/id_rsa

  children:
    proxy:
      hosts:
        proxy:
          ansible_host: ${proxy_ip}
          ansible_user: ${ansible_user}
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_ssh_common_args: '-o ProxyJump=${ansible_user}@${bastion_ip}'

    app:
      hosts:
        app:
          ansible_host: ${app_ip}
          ansible_user: ${ansible_user}
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_ssh_common_args: '-o ProxyJump=${ansible_user}@${bastion_ip}'

    db:
      hosts:
        db:
          ansible_host: ${db_ip}
          ansible_user: ${ansible_user}
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_ssh_common_args: '-o ProxyJump=${ansible_user}@${bastion_ip}'