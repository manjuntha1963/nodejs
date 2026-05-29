```bash
#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

echo "Updating system..."

sudo apt update -y
sudo apt upgrade -y

# Install required packages
sudo apt install -y \
    curl \
    wget \
    unzip \
    git \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    gettext-base

# Install Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo bash -

sudo apt install -y nodejs

# Install PM2
sudo npm install -g pm2


# Install or Update AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
-o "awscliv2.zip"

unzip -o awscliv2.zip

if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI already installed. Updating..."
    sudo ./aws/install --update
else
    echo "Installing AWS CLI..."
    sudo ./aws/install
fi

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

# Install eksctl
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO \
"https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp

sudo install -m 0755 /tmp/eksctl /usr/local/bin

# Install Terraform only if missing
if ! command -v terraform >/dev/null 2>&1; then

    echo "Installing Terraform..."

    curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com \
    $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

    sudo apt update

    sudo apt install -y terraform

else
    echo "Terraform already installed"
fi

# Install Helm
curl -fsSL \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Trivy
curl -sfL \
https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

sudo mv bin/trivy /usr/local/bin/

# Verify installations
echo "Checking versions..."

node -v
npm -v
terraform --version
kubectl version --client
aws --version
trivy --version
helm version
eksctl version

echo "Prerequisites installed successfully."
