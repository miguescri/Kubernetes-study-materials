#!/bin/bash -x

HOSTNAME=$1
NODEIP=$2
NODETYPE=$3
MASTERIP=$4
MASTERDNS=$5

timedatectl set-timezone Europe/Madrid

{ echo 192.168.1.90 m1; 
  echo 192.168.1.93 w1; 
  echo 192.168.1.94 w2;
  echo 192.168.1.95 w3; 
  cat /etc/hosts
} > /etc/hosts.new
mv /etc/hosts{.new,}

if [ $NODETYPE = "master" ]; then
  kubeadm init \
    --apiserver-advertise-address=$MASTERIP \
    --apiserver-cert-extra-sans=$MASTERIP \
    --pod-network-cidr=192.168.0.0/24 \
    --kubernetes-version=1.19.1
  
  cp /etc/kubernetes/admin.conf /vagrant/config
  
  mkdir -p $HOME/.kube
  cp /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
  
  wget https://docs.projectcalico.org/manifests/calico.yaml
  kubectl apply -f calico.yaml
  sleep 120
  
  kubeadm token create > /vagrant/kubeadm_token
  openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
    openssl rsa -pubin -outform der 2>/dev/null | \
    openssl dgst -sha256 -hex | \
    cut -d ' ' -f 2 > /vagrant/ca_cert_hash
  
else
  KUBEADM_TOKEN=$(cat /vagrant/kubeadm_token)
  CA_CERT_HASH=$(cat /vagrant/ca_cert_hash)
  
  kubeadm join $MASTERIP:6443 \
    --token $KUBEADM_TOKEN \
    --discovery-token-ca-cert-hash sha256:$CA_CERT_HASH  
fi

