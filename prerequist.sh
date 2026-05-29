curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

### Install Chocolatey to Install Terraform on Windows Server
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install terraform -y

terraform -version

# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js (LTS recommended)
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

sudo npm install -g pm2

Verify installation:

pm2 -v

# Check versions
node -v
npm -v


# Install AWS CLI v2

sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install


# Install kubectl

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/


# EKSCTl  cli instalation

ARCH=amd64
PLATFORM=$(uname -s)_$ARCH

curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz"

# (Optional) Verify checksum
curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check

tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz

sudo install -m 0755 /tmp/eksctl /usr/local/bin && rm /tmp/eksctl


# Install Docker
sudo apt update
sudo apt  install docker.io -y

# Allow jenkins and ubuntu users to run docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# Restart Jenkins to apply group changes
sudo systemctl restart jenkins

Step 2: Run SonarQube in Docker
# Pull and run SonarQube (LTS version)
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  sonarqube:lts
