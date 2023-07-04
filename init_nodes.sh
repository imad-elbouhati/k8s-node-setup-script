#!/bin/bash

# Disable swap
sudo swapoff -a

# Add swapoff command to crontab to run at reboot
(crontab -l 2>/dev/null; echo "@reboot /sbin/swapoff -a") | crontab - || true

# Add modules to be loaded at boot time
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Set up sysctl configuration
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl configuration
sudo sysctl --system

# Set variables
OS="xUbuntu_20.04"
VERSION="1.23"

# Add repositories to package sources
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /
EOF
cat <<EOF | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list
deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /
EOF

# Import repository keys
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key --keyring /etc/apt/trusted.gpg.d/libcontainers.gpg add -

# Update package lists
sudo apt-get update

# Install cri-o and related packages
sudo apt-get install cri-o cri-o-runc cri-tools -y

# Reload systemd configuration
sudo systemctl daemon-reload

# Enable and start cri-o service
sudo systemctl enable crio --now

# Update package lists
sudo apt-get update

# Install required packages for Kubernetes
sudo apt-get install -y apt-transport-https ca-certificates curl

# Import GPG key for Kubernetes packages
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

# Add Kubernetes package repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package lists
sudo apt-get update

# Install specific versions of kubelet, kubectl, and kubeadm
sudo apt-get install -y kubelet=1.27.3-00 kubectl=1.27.3-00 kubeadm=1.27.3-00

# Prevent automatic updates for kubelet, kubectl, and kubeadm
sudo apt-mark hold kubelet kubeadm kubectl
