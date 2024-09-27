## 安装
```
dnf -y install epel-release
dnf -y install ansible
ansible --version
```
## 测试
```
echo '[all]' >> /etc/ansible/hosts
hostname -I >> /etc/ansible/hosts
ansible all -m ping
cat << EOF >> ping_test.yml
---
- name: 测试与主机的连通性
  hosts: all
  gather_facts: no

  tasks:
    - name: Ping 远程主机
      ansible.builtin.ping:
EOF
ansible-playbook ping_test.yml
```
