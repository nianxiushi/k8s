## 组件
* Horizon 图形组件
* Nova 计算组件
* Heat 编排组件

* Keystone 认证组件
* Neutron 网络组件
* Ceilometer 计费组件

* Swift 对象存储组件
* Cinder 块存储组件
* Glance 镜像组件

## 安装
* 单节点部署
```
sudo dnf update -y
sudo dnf config-manager --enable crb
sudo systemctl disable firewalld --now
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sudo setenforce 0
sudo yum install -y https://repos.fedorapeople.org/repos/openstack/archived/openstack-antelope/rdo-release-antelope-2.el9s.noarch.rpm
sudo dnf update -y
sudo dnf install -y openstack-packstack
sudo packstack --allinone
```