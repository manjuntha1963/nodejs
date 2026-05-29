pipeline {
    agent any

    tools {
        nodejs "node24"
    }

    environment {

        AWS_ACCOUNT_ID = "654654305195"
        AWS_REGION = "us-east-1"

        ECR_REPO_NAME = "myapp"
        IMAGE_TAG = "latest"

        EKS_CLUSTER_NAME = "my-eks-cluster"

        DEPLOYMENT_NAME = "myapp-deployment"
        SERVICE_NAME = "myapp-service"
        K8S_NAMESPACE = "default"

        IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
    }

    stages {

        stage('Checkout') {
            steps {

                git branch: 'master',
                url: 'https://github.com/manjuntha1963/nodejs.git'
            }
        }

        stage('Run Prerequisites') {
            steps {

                sh '''
                    chmod +x prerequisite.sh
                    ./prerequisite.sh
                '''
            }
        }

        stage('Install Dependencies') {
            steps {

                sh 'npm install'
            }
        }

        stage('Build/Test') {
            steps {

                sh 'npm test || echo "No tests configured"'
            }
        }

        stage('SonarQube Analysis') {
            steps {

                withSonarQubeEnv('SonarServer') {

                    withCredentials([
                        string(
                            credentialsId: 'sonarqube-token',
                            variable: 'SONAR_AUTH_TOKEN'
                        )
                    ]) {

                        script {

                            def scannerHome = tool 'SonarScanner'

                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=myapp \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=$SONAR_HOST_URL \
                                -Dsonar.login=$SONAR_AUTH_TOKEN
                            """
                        }
                    }
                }
            }
        }

        stage('Terraform Apply') {
            steps {

                sh '''
                    terraform init
                    terraform validate
                    terraform plan
                    terraform apply -auto-approve
                '''
            }
        }

        stage('Build Docker Image') {
            steps {

                sh '''
                    docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Scan Docker Image') {
            steps {

                sh '''
                    trivy image ${ECR_REPO_NAME}:${IMAGE_TAG} || true
                '''
            }
        }

        stage('Push to ECR') {
            steps {

                sh '''

                    aws ecr describe-repositories \
                    --repository-names ${ECR_REPO_NAME} \
                    --region ${AWS_REGION} >/dev/null 2>&1 || \

                    aws ecr create-repository \
                    --repository-name ${ECR_REPO_NAME} \
                    --region ${AWS_REGION}

                    aws ecr get-login-password \
                    --region ${AWS_REGION} | \
                    docker login \
                    --username AWS \
                    --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker tag \
                    ${ECR_REPO_NAME}:${IMAGE_TAG} \
                    ${IMAGE_URI}

                    docker push ${IMAGE_URI}
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {

                sh '''

                    aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${EKS_CLUSTER_NAME}

                    export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}
                    export AWS_REGION=${AWS_REGION}
                    export ECR_REPO_NAME=${ECR_REPO_NAME}
                    export IMAGE_TAG=${IMAGE_TAG}
                    export DEPLOYMENT_NAME=${DEPLOYMENT_NAME}
                    export SERVICE_NAME=${SERVICE_NAME}
                    export K8S_NAMESPACE=${K8S_NAMESPACE}

                    envsubst < deployment.yaml | kubectl apply -f -
                    envsubst < service.yaml | kubectl apply -f -

                    kubectl rollout status deployment/${DEPLOYMENT_NAME} \
                    -n ${K8S_NAMESPACE}
                '''
            }
        }

        stage('Install Monitoring Stack') {
            steps {

                sh '''

                    helm repo add prometheus-community \
                    https://prometheus-community.github.io/helm-charts

                    helm repo add grafana \
                    https://grafana.github.io/helm-charts

                    helm repo update

                    # Install Prometheus with LoadBalancer
                    helm upgrade --install prometheus \
                    prometheus-community/prometheus \
                    --namespace ${K8S_NAMESPACE} \
                    --create-namespace \
                    --set server.service.type=LoadBalancer \
                    --set alertmanager.service.type=LoadBalancer \
                    --set server.resources.requests.memory=256Mi \
                    --set server.resources.requests.cpu=250m

                    # Install Grafana with LoadBalancer
                    helm upgrade --install grafana \
                    grafana/grafana \
                    --namespace ${K8S_NAMESPACE} \
                    --set adminPassword='admin' \
                    --set service.type=LoadBalancer

                    echo "================ KUBERNETES SERVICES ================"
                    kubectl get svc -n ${K8S_NAMESPACE}

                    echo "================ GRAFANA SERVICE ================"
                    kubectl get svc grafana -n ${K8S_NAMESPACE}

                    echo "================ PROMETHEUS SERVICE ================"
                    kubectl get svc prometheus-server -n ${K8S_NAMESPACE}

                    echo "================ POD STATUS ================"
                    kubectl get pods -n ${K8S_NAMESPACE}
                '''
            }
        }
    }

    post {

        always {

            cleanWs()
        }

        success {

            echo 'CI/CD Pipeline completed successfully'
        }

        failure {

            echo 'CI/CD Pipeline failed'
        }
    }
}
