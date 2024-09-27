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
## playbook
* vars 参数: 用于在执行playbook时传递变量
```
cat << EOF >> vars.yaml
- name: 直接设置变量
  hosts: all
  gather_facts: no
  
  vars:
    my_var: "Hello, Ansible!"

  tasks:
  - name: 打印变量
    ansible.builtin.debug:
      msg: "{{ my_var }}"
EOF
```
## 模块
* set_fact 模块：用于在任务执行过程中动态地设置变量
```
cat << EOF >> set_fact.yaml
- name: 使用set_fact模块设置变量
  hosts: all
  gather_facts: no

  tasks:
  - name: 设置变量
    ansible.builtin.set_fact:
      key_name: value

  - name: 打印变量
    ansible.builtin.debug:
      msg: "{{ key_name }}"
EOF
```
* stat 模块：用于获取文件或目录的状态信息
```
cat << EOF >> stat.yaml
- name: 使用stat模块检查文件状态
  hosts: all
  gather_facts: no

  tasks:
  - name: 检查文件状态
    ansible.builtin.stat:
      path: /etc/hosts
      follow: yes
      get_checksum: yes
    register: file_status

  - name: 打印文件状态
    ansible.builtin.debug:
        msg: "{{ file_status }}"
EOF
```
