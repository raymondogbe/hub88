#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating and installing essentials..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y python3 python3-pip git unzip curl software-properties-common wget apt-transport-https gpg

# Install Java (required for Jenkins)
sudo apt-get install -y fontconfig openjdk-17-jre

# Setup directory for Ansible
sudo -u ubuntu mkdir -p /home/ubuntu/ansible

# Setup private SSH key
sudo -u ubuntu mkdir -p /home/ubuntu/.ssh
if [ -n "${private_key}" ]; then
  echo "${private_key}" | base64 --decode | sudo tee /home/ubuntu/.ssh/id_rsa > /dev/null
  sudo chmod 400 /home/ubuntu/.ssh/id_rsa
  sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
else
  echo "Private key not provided."
fi

# Disable SSH strict host key checking
echo "Host *" | sudo tee /home/ubuntu/.ssh/config > /dev/null
echo "    StrictHostKeyChecking no" | sudo tee -a /home/ubuntu/.ssh/config > /dev/null
echo "    UserKnownHostsFile /dev/null" | sudo tee -a /home/ubuntu/.ssh/config > /dev/null
sudo chmod 600 /home/ubuntu/.ssh/config
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/config
