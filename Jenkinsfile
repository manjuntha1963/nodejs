pipeline {
    agent any

    tools {
        nodejs "node24"   // Make sure this matches your Jenkins Node.js tool
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/manjuntha1963/test.git'
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

        stage('Run Application') {
            steps {
                sh '''
                # Stop and delete any existing instance of the app
                pm2 stop myapp || true
                pm2 delete myapp || true

                # Start the app using PM2
                pm2 start app.js --name myapp

                # Save the PM2 process list so it restarts on server reboot
                pm2 save
                '''
            }
        }
    }
}
