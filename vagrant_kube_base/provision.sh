#!/bin/bash -x

# Configure kernel
cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

# Add official Kubernetes repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/  kubernetes-xenial main
EOF

# Add official Docker repository
curl -s https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
cat << EOF > /etc/apt/sources.list.d/docker.list
deb https://download.docker.com/linux/ubuntu bionic	 stable
EOF

# Install packages 
apt update -y
apt install -y containerd.io
apt install -y kubeadm=1.19.1-00 kubelet=1.19.1-00 kubectl=1.19.1-00
apt-mark hold kubeadm kubelet kubectl

# Configure containerd
containerd config default > /etc/containerd/config.toml
systemctl restart containerd

