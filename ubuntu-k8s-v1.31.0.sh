# echo  "---------------- 配置静态 IP ---------------"
# network:
#   version: 2
#   renderer: networkd
#   ethernets:
#     ens33:
#       dhcp4: false
#       addresses:
#         - 192.168.52.141/24
#       routes:
#         - to: default
#           via: 192.168.52.2
#       nameservers:
#         addresses:
#           - 8.8.8.8
#           - 8.8.4.4
# netplan apply 
echo  "---------------- 安装 docker ---------------"
sed -i 's/http:\/\/cn.archive.ubuntu.com/http:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources
sed -i 's/http:\/\/security.ubuntu.com/http:\/\/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository  -y "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get -y update
sudo apt-get -y install docker-ce socat
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
apt-get update && apt-get install -y apt-transport-https
curl -fsSL https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.31/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://mirrors.aliyun.com/kubernetes-new/core/stable/v1.31/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
systemctl enable kubelet --now
systemctl disable ufw --now
timedatectl set-timezone Asia/Shanghai
cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system
sysctl net.ipv4.ip_forward
sudo swapoff -a
sed -i '$s/^/#/' /etc/fstab
apt-get install ipset ipvsadm -y
cat << EOF | tee /etc/modules-load.d/ipvs.conf
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_sh
nf_conntrack
EOF
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack
lsmod | grep ip_vs
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
            echo  "----------------请确认所有node已加入master，开始安装istio---------------"
            mkdir -p /opt/k8s/istio 
            cd /opt/k8s/istio
            wget https://github.com/istio/istio/releases/download/1.23.2/istio-1.23.2-linux-amd64.tar.gz
            tar -xzf istio-1.23.2-linux-amd64.tar.gz
            sed -i '$ a export PATH="$PATH:/opt/k8s/istio/istio-1.23.2/bin"' ~/.bashrc
            export PATH="$PATH:/opt/k8s/istio/istio-1.23.2/bin"
            kubectl get node
            istioctl profile list
            istioctl install --set profile=demo -y
            #istioctl manifest apply --set components.cni.enabled=true 
            kubectl create ns istio-injection
            kubectl label namespace istio-injection istio-injection=enabled
            ls
            cd /opt/k8s/istio/istio-1.23.2
            kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml -n istio-injection
            kubectl get pods -n istio-injection
            kubectl get services -n istio-injection
            source ~/.bashrc
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


