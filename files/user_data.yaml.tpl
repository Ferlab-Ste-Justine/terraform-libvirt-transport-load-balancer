#cloud-config
merge_how:
 - name: list
   settings: [append, no_replace]
 - name: dict
   settings: [no_replace, recurse_list]

%{ if admin_user_password != "" ~}
ssh_pwauth: false
chpasswd:
  expire: False
  users:
    - name: ${ssh_admin_user}
      password: "${admin_user_password}"
      type: text
%{ endif ~}
preserve_hostname: false
hostname: ${hostname}
users:
  - default
  - name: ${ssh_admin_user}
    ssh_authorized_keys:
      - "${ssh_admin_public_key}"

%{ if length(custom_certificates) > 0 ~}
write_files:
%{ for custom_certificate in custom_certificates ~}
  - path: ${custom_certificate.certificate.path}
    owner: root:root
    permissions: "0400"
    content: |
      ${indent(6, custom_certificate.certificate.content)}
  - path: ${custom_certificate.key.path}
    owner: root:root
    permissions: "0400"
    content: |
      ${indent(6, custom_certificate.key.content)}
%{ endfor ~}

runcmd:
%{ for custom_certificate in custom_certificates ~}
  - chown transport-load-balancer:transport-load-balancer ${custom_certificate.certificate.path}
  - chown transport-load-balancer:transport-load-balancer ${custom_certificate.key.path}
%{ endfor ~}
%{ endif ~}