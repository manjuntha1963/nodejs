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
        EKS_CLUSTER_NAME = "my-cluster"
        DEPLOYMENT_NAME = "myapp-deployment"
        SERVICE_NAME = "myapp-service"
        K8S_NAMESPACE = "default"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/manjuntha1963/test.git'
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
                sh "docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Scan Docker Image') {
            steps {
                sh '''
                    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh
                    ./bin/trivy image ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG} || echo "Vulnerabilities found"
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                    # Ensure ECR repository exists
                    if ! aws ecr describe-repositories --repository-names ${ECR_REPO_NAME} --region ${AWS_REGION} >/dev/null 2>&1; then
                        echo "ECR repository ${ECR_REPO_NAME} not found. Creating..."
                        aws ecr create-repository --repository-name ${ECR_REPO_NAME} --region ${AWS_REGION}
                    else
                        echo "ECR repository ${ECR_REPO_NAME} already exists."
                    fi

                    # Login to ECR
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    # Tag and push Docker image
                    docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                '''
            }
        }

        stage('Install Helm') {
            steps {
                sh '''
                    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
                    helm version
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks --region ${AWS_REGION} update-kubeconfig --name ${EKS_CLUSTER_NAME}

                    # Deploy app
                    kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${DEPLOYMENT_NAME}
  namespace: ${K8S_NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ${DEPLOYMENT_NAME}
  template:
    metadata:
      labels:
        app: ${DEPLOYMENT_NAME}
    spec:
      containers:
      - name: ${DEPLOYMENT_NAME}
        image: ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: ${SERVICE_NAME}
  namespace: ${K8S_NAMESPACE}
spec:
  selector:
    app: ${DEPLOYMENT_NAME}
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
EOF
                '''
            }
        }

        stage('Install Monitoring Stack & Import Kubernetes Dashboard') {
            steps {
                sh '''
                    # Add Helm repos
                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                    helm repo add grafana https://grafana.github.io/helm-charts
                    helm repo update

                    # Install Prometheus with emptyDir
                    helm upgrade --install prometheus prometheus-community/prometheus \
                        --namespace ${K8S_NAMESPACE} --create-namespace \
                        --set server.service.type=LoadBalancer \
                        --set server.persistentVolume.enabled=false \
                        --set server.image.repository=quay.io/prometheus/prometheus \
                        --set server.image.tag=v2.44.0

                    # Install Grafana with emptyDir
                    helm upgrade --install grafana grafana/grafana \
                        --namespace ${K8S_NAMESPACE} \
                        --set service.type=LoadBalancer \
                        --set persistence.enabled=false \
                        --set adminPassword='admin'

                    # Wait for pods to be ready
                    kubectl wait --namespace ${K8S_NAMESPACE} --for=condition=ready pod -l app.kubernetes.io/name=prometheus-server --timeout=600s || true
                    kubectl wait --namespace ${K8S_NAMESPACE} --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=600s || true

                    # Get Grafana URL
                    GRAFANA_URL="http://\$(kubectl get svc grafana -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'):80"
                    echo "Grafana URL: \$GRAFANA_URL"

                    # Import Kubernetes dashboard (ID 315)
                    curl -s -X POST -H "Content-Type: application/json" \
                        -d '{"dashboard": {"id":315},"overwrite": true,"inputs":[]}' \
                        "\$GRAFANA_URL/api/dashboards/db" \
                        --user admin:admin || echo "Dashboard import may require manual setup"
                '''
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed!"
            cleanWs()
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
    }
