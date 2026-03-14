pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "iamadnanakram/adnan-test-site:latest"
        // These credentials need to be set up in Jenkins
        DOCKER_CREDS = credentials('docker-hub-credentials') 
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo \$DOCKER_CREDS_PSW | docker login -u \$DOCKER_CREDS_USR --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}"
                }
            }
        }

        stage('Deploy Infrastructure via Terraform') {
            steps {
                script {
                    sh "terraform init"
                    // Auto-approve applies the changes without asking for a manual "yes"
                    sh "terraform apply -auto-approve" 
                }
            }
        }
    }
}
