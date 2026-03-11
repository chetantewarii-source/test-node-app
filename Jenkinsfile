pipeline {
    agent any

    environment {
        IMAGE_NAME = "test-node-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/chetantewarii-source/test-node-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t test-node-app .'
            }
        }

        stage('Push Docker Image') {
            steps {
                sh 'docker push chetantewari/test-node-app:latest'
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
                sh 'kubectl apply -f k8s/service.yaml'
            }
        }
    }
}