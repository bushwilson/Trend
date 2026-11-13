#!/bin/bash
set -ex
exec > /var/log/jenkins-install.log 2>&1
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y fontconfig openjdk-21-jre git unzip curl ca-certificates docker.io
systemctl enable --now docker

# Jenkins repository (2026 signing key)
mkdir -p /etc/apt/keyrings
curl -fsSL -o /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" > /etc/apt/sources.list.d/jenkins.list
apt-get update -y
apt-get install -y jenkins

# Let Jenkins run docker commands
usermod -aG docker jenkins

# AWS CLI v2
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install

# kubectl
KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

systemctl enable jenkins
systemctl restart jenkins