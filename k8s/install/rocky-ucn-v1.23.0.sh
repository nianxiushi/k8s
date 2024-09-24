echo  "---------------- 安装 docker ---------------"
dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
dnf install -y docker-ce-cli-20.10.24 docker-ce-20.10.24
systemctl enable docker --now
cat << EOF > /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "registry-mirrors": [
      "https://dockerproxy.cn",
      "https://k8s.m.daocloud.io"
    ]
}
EOF
docker version
echo  "---------------- docker 安装完毕 ---------------"
echo  "------------ 安装 k8s ----------------"
cat << EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
dnf install --nogpgcheck -y kubelet-1.23.0 kubeadm-1.23.0 kubectl-1.23.0
systemctl enable kubelet --now
systemctl disable firewalld --now
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward
sudo swapoff -a
sed -i '$s/^/#/' /etc/fstab
hostname=$(hostname)
local_ip=$(hostname -I | awk '{print $1}')
echo "${local_ip}    ${hostname}" >> /etc/hosts
cat <<EOF> /etc/sysconfig/kubelet
KUBELET_CGROUP_ARGS="--cgroup-driver=systemd"
EOF
echo  "----------------输入数字 1 使用创建集群环境，首次安装输入 1 创建---------------"
echo  "----------------输入数字 2 使用加入集群环境，二次安装输入 2 加入---------------"
echo  "----------------输入数字 3 使用加入集群环境，三次安装输入 3 加入---------------"
user_input=""
while true
do
    echo "请输入数字( 1 | 2 | 3 )："
    read user_input
    case $user_input in
        1)
            echo "ucn-master-01" > /etc/hostname
            hostnamectl set-hostname ucn-master-01
            kubeadm init --kubernetes-version=v1.23.0 --pod-network-cidr=192.168.0.0/16 --image-repository registry.aliyuncs.com/google_containers
            mkdir -p $HOME/.kube
            sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
            sudo chown $(id -u):$(id -g) $HOME/.kube/config
            export KUBECONFIG=/etc/kubernetes/admin.conf
            kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/tigera-operator.yaml
            kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.1/manifests/custom-resources.yaml
            kubectl get node
            break
            ;;
        2)
            echo "ucn-worker-01" > /etc/hostname
            hostnamectl set-hostname ucn-worker-01
            break
            ;;
        3)
            echo "ucn-worker-02" > /etc/hostname
            hostnamectl set-hostname ucn-worker-02
            break
            ;;
        *)
            echo "请检查输入是否正确"
            ;;
    esac
done
echo  "----------------k8s 安装完毕---------------"
