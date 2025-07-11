#!/bin/bash

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

# set -e  # Exit immediately if a command exits with a non-zero status

# echo "Installing Docker on RHEL-based system..."

# # Step 1: Install required plugins
# echo "Installing dnf plugins..."
# sudo dnf -y install dnf-plugins-core

# # Step 2: Add Docker repository
# echo "Adding Docker repository..."
# sudo dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# # Step 3: Install Docker and dependencies
# echo "Installing Docker packages..."
# sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# # Step 4: Enable and start Docker service
# echo "Enabling and starting Docker service..."
# sudo systemctl start docker
# sudo systemctl enable docker

# # Step 5: Change user to current user

# sudo usermod -aG docker ec2-user

# echo "Docker installation complete!"