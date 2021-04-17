#!/bin/bash -x

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/  kubernetes-xenial main
EOF

apt update -y

apt install -y docker.io
systemctl enable docker.service

apt install -y kubeadm=1.19.1-00 kubelet=1.19.1-00 kubectl=1.19.1-00
apt-mark hold kubeadm kubelet kubectl

