#!/bin/bash

#
# Master node setup
#
# before running: make sure hostnames and hosts files are setup
# after running: capture relevant output to facilitate joining slave nodes
#

setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/SELINUX

firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload

modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum install kubeadm docker -y

systemctl restart docker && systemctl enable docker
systemctl restart kubelet && systemctl enable kubelet

kubeadm init

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/,kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
