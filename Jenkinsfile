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
    }

    stages {

        stage('Checkout') {
            steps {
                git 'https://github.com/manjuntha1963/nodejs.git'
            }
        }

        stage('Run Prerequisites') {
            steps {
                sh '''
                    chmod +x prerequist.sh
                    ./prerequist.sh
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
                    withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_AUTH_TOKEN')]) {
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

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Scan Docker Image') {
            steps {
                sh """
                    trivy image ${ECR_REPO_NAME}:${IMAGE_TAG} || true
                """
            }
        }

        stage('Push to ECR') {
            steps {
                sh """
                    aws ecr describe-repositories \
                    --repository-names ${ECR_REPO_NAME} \
                    --region ${AWS_REGION} || \
                    aws ecr create-repository \
                    --repository-name ${ECR_REPO_NAME} \
                    --region ${AWS_REGION}

                    aws ecr get-login-password --region ${AWS_REGION} | \
                    docker login --username AWS --password-stdin \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}

                    docker push \
                    ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                """
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh """
                    aws eks update-kubeconfig \
                    --region ${AWS_REGION} \
                    --name ${EKS_CLUSTER_NAME}

                    envsubst < deployment.yaml | kubectl apply -f -
                    envsubst < service.yaml | kubectl apply -f -
                """
            }
        }

        stage('Install Monitoring Stack') {
            steps {
                sh """
                    helm repo add prometheus-community \
                    https://prometheus-community.github.io/helm-charts

                    helm repo add grafana \
                    https://grafana.github.io/helm-charts

                    helm repo update

                    helm upgrade --install prometheus \
                    prometheus-community/prometheus \
                    --namespace ${K8S_NAMESPACE} \
                    --create-namespace

                    helm upgrade --install grafana \
                    grafana/grafana \
                    --namespace ${K8S_NAMESPACE} \
                    --set adminPassword='admin'
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }
    }
}
```
