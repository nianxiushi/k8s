## 工作原理
1、客户端 puppetd 调用 facter，facter 会探测出这台主机的一些变量如主机名、内存大小、IP地址等，然后 puppetd 把这些信息发送到服务器。

2、服务器端的 puppetmaster 检测到客户端的主机名，然后会到 manifest 里面对应的 node 配置，然后对这段内容进行解析，facter 送过来的信息可以作为变量进行处理的，node 牵涉到的代码解析，其他的代码不解析，解析分几个过程：语法检查、然后会生成一个中间的伪代码，然后再把伪代码发给客户机。

3、客户端接收到伪代码之后就会执行，客户端再把执行结果发送给服务器。

4、服务器再把客户端的执行结果写入日志

## 安装
### Rocky Linux 9
* 服务端
```
echo "ucn-master-01" > /etc/hostname
hostnamectl set-hostname ucn-master-01
echo '192.168.52.129    ucn-master-01' >> /etc/hosts
echo '192.168.52.130    ucn-worker-01' >> /etc/hosts
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
setenforce 0
systemctl disable firewalld --now
rpm -ivh https://yum.puppetlabs.com/puppet8-release-el-9.noarch.rpm
yum install puppetserver -y
echo 'export PATH=$PATH:/opt/puppetlabs/bin/puppetserver' >> ~/.bashrc 
source ~/.bashrc
cat << EOF >> /etc/puppetlabs/puppet/puppet.conf
[main]
  server = ucn-master-01
  autosign = true
EOF
systemctl enable puppetserver --now
puppetserver ca list --all
```
* 客户端
```
echo "ucn-worker-01" > /etc/hostname
hostnamectl set-hostname ucn-worker-01
echo '192.168.52.129    ucn-master-01' >> /etc/hosts
echo '192.168.52.130    ucn-worker-01' >> /etc/hosts
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/'  /etc/selinux/config
setenforce 0
systemctl disable firewalld --now
rpm -ivh https://yum.puppetlabs.com/puppet8-release-el-9.noarch.rpm
yum install puppet-agent -y
echo 'export PATH=$PATH:/opt/puppetlabs/bin/puppet' >> ~/.bashrc 
source ~/.bashrc
cat << EOF >> /etc/puppetlabs/puppet/puppet.conf
[main]
  server = ucn-master-01
EOF
systemctl enable puppet --now
puppet agent -t
```
### Ubuntu 24.04.1 LTS
* 服务端
```
https://apt.puppetlabs.com/puppet-release-noble.deb
apt install puppetserver -y
```
* 客户端
```
https://apt.puppetlabs.com/puppet-release-noble.deb
apt install puppet-agent -y
```
