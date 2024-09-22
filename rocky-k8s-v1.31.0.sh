echo  "---------------- 安装 docker ---------------"
dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
dnf install docker-ce socat -y
systemctl enable docker --now
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml 
sed -i 's/registry.k8s.io\/pause:3.8/registry.aliyuncs.com\/google_containers\/pause:3.10/' /etc/containerd/config.toml 
sed -i '162s/.*/      config_path = "\/etc\/containerd\/certs.d"/' /etc/containerd/config.toml

mkdir -p /etc/containerd/certs.d/docker.io
cat << EOF | sudo tee /etc/containerd/certs.d/docker.io/hosts.toml 
server = "https://docker.io"

[host."https://dockerproxy.cn"]
  capabilities = ["pull", "resolve"]

[host."https://docker.m.daocloud.io"]
  capabilities = ["pull", "resolve"]

[host."https://reg-mirror.qiniu.com"]
  capabilities = ["pull", "resolve"]

[host."https://registry.docker-cn.com"]
  capabilities = ["pull", "resolve"]

[host."http://hub-mirror.c.163.com"]
  capabilities = ["pull", "resolve"]
EOF

mkdir -p /etc/containerd/certs.d/registry.k8s.io
cat << EOF | tee /etc/containerd/certs.d/registry.k8s.io/hosts.toml 
server = "https://registry.k8s.io"

[host."https://k8s.m.daocloud.io"]
  capabilities = ["pull", "resolve"]
EOF
systemctl restart containerd
docker version
echo  "---------------- docker 安装完毕 ---------------"
echo  "------------ 安装 k8s ----------------"
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.31/rpm/
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.31/rpm/repodata/repomd.xml.key
EOF
yum install -y kubelet kubeadm kubectl
systemctl enable kubelet --now
systemctl disable firewalld --now
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward
sudo swapoff -a
sed -i '$s/^/#/' /etc/fstab
hostname=$(hostname)
local_ip=$(hostname -I | awk '{print $1}')
echo "${local_ip}    ${hostname}" >> /etc/hosts

echo  "----------------输入数字 1 使用创建集群环境，首次安装输入 1 创建---------------"
echo  "----------------输入数字 2 使用加入集群环境，二次安装输入 2 加入---------------"
echo  "----------------输入数字 3 使用加入集群环境，三次安装输入 3 加入---------------"

user_input=""
while true
do
    echo  "请输入数字( 1 | 2 | 3 )："
    read user_input
    case $user_input in
        1)
            echo "k8s-master-01" > /etc/hostname
            hostnamectl set-hostname k8s-master-01
            kubeadm init --pod-network-cidr=10.244.0.0/16 --image-repository registry.aliyuncs.com/google_containers
            mkdir -p $HOME/.kube
            sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
            sudo chown $(id -u):$(id -g) $HOME/.kube/config
            export KUBECONFIG=/etc/kubernetes/admin.conf
            kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
            kubectl get node
            break
            ;;
        2)
            echo "k8s-worker-01" > /etc/hostname
            hostnamectl set-hostname k8s-worker-01
            break
            ;;
        3)
            echo "k8s-worker-02" > /etc/hostname
            hostnamectl set-hostname k8s-worker-02
            break
            ;;
        *)
            echo "请检查输入是否正确"
            ;;
    esac
done
echo  "----------------k8s 安装完毕---------------"
