curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh

curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

### Install Chocolatey to Install Terraform on Windows Server
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install terraform -y

terraform -version

# Update and Upgrade System
    sudo apt update -y && sudo apt upgrade -y

    # Install Required Packages
    sudo apt install -y unzip maven git

    # Install kubectl
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    sudo apt-mark hold kubectl

    # Install Terraform
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y terraform

    # Install awcli
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Install eksctl
    curl -sSL "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" -o eksctl.tar.gz
    tar -xzf eksctl.tar.gz
    sudo mv eksctl /usr/local/bin
    sudo chmod +x /usr/local/bin/eksctl

    ### **Step 1: Install Helm (if not installed)**
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod +x get_helm.sh
    ./get_helm.sh

    # Install Jenkins
    # Add the Jenkins repository key
    curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian binary/" | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt update && sudo apt install jenkins -y
    sudo systemctl enable --now jenkins

    ### **Step 1: Install Trivy**
    # Add Aqua Security repository
    sudo apt install wget -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo tee /etc/apt/trusted.gpg.d/trivy.asc
    echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/trivy.list
    sudo apt update && sudo apt install trivy -y


    # Install dependencies
    sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y
    sudo usermod -aG docker $USER
    sudo systemctl enable --now jenkins
    sudo systemctl enable --now docker
    sudo usermod -aG docker jenkins
    sudo chmod 666 /var/run/docker.sock
    sudo systemctl restart jenkins  # Ensure Jenkins recognizes Docker permissions
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword

    # Sonarqube instal
    docker run --name sonarqube-custom -dp 9000:9000 sonarqube:community

     # update credntial to update
    aws eks update-kubeconfig --name my-eks-cluster --region us-east-1
    sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
    sudo chmod 600 /var/lib/jenkins/.kube/config

    jenkins --version
    docker --version
    terraform --version
    kubectl version --client
    aws --version
    trivy --version
    eksctl version
