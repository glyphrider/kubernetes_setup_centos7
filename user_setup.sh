#!/bin/bash

USERNAME=${1}
GITHUBID=${2:-$USERNAME}

sudo useradd -m -G wheel $USERNAME

USERHOME=$(getent passwd $USERNAME | cut -d: -f6)

sudo su - $USERNAME <<EOF

# SSH Credentials from GitHub
(umask 077 && mkdir .ssh)
(umask 033 && curl -o .ssh/authorized_keys -fsSL https://github.com/${GITHUBID}.keys)

# Kube Config
mkdir -p $USERHOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $USERHOME/.kube/config
sudo chown $(id -u $USERNAME):$(id -g $USERNAME) $USERHOME/.kube/config

EOF
