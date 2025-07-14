#!/bin/bash

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

growpart /dev/nvme0n1 4
lvextend -l +50%FREE /dev/RootVG/rootVol
lvextend -l +50%FREE /dev/RootVG/varVol
xfs_growfs /
xfs_growfs /var

set -e

echo "Installing Docker on RHEL-based system..."

# Step 1: Install dnf plugins
echo "Installing dnf plugins..."
sudo dnf -y install dnf-plugins-core || sudo yum install -y yum-utils

# Step 2: Add Docker repo
if ! sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo; then
  echo "Failed to add Docker repo. Exiting."
  exit 1
fi

# Step 3: Install Docker and dependencies
echo "Installing Docker packages..."
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || {
  echo "Docker installation failed. Trying with --nobest..."
  sudo dnf -y install docker-ce --nobest
}

# Step 4: Enable and start Docker
echo "Starting Docker service..."
sudo systemctl enable --now docker

# Step 5: Add user to Docker group
echo "Adding user to Docker group..."
sudo usermod -aG docker ec2-user

echo "Docker installation completed successfully!"

# Install kubectl

# Step 1: Download kubectl
echo "Downloading kubectl..."
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.33.0/2025-05-01/bin/linux/amd64/kubectl

# Step 2: Change permissions
echo "Granting execute permissions to kubectl..."
chmod +x ./kubectl

# Step 3: Move kubectl to ust/local/bin
echo "move kubectl to /usr/local/bin/kubectl..."
mv kubectl /usr/local/bin/kubectl

echo "kubectl installation completed successfully!"

# Install eksctl

# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`

# Step 4: Download eksctl
echo "Downloading eksctl..."
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# Step 5: untar the downloaded file
echo "untar eksctl..."
tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

# Step 6: Move eksctl to /usr/local/bin
echo "move eksctl to /usr/local/bin..."
mv /tmp/eksctl /usr/local/bin

echo "eksctl installation completed successfully!"