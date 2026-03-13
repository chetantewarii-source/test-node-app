pipeline {

    agent any

    tools {
        nodejs "node18"
    }

    environment {
        DOCKERHUB_USER = "chetantewari"
        IMAGE_NAME = "square-node-app"
    }

    stages {

        // stage('Checkout Code') {
        //     steps {
        //         git 'https://github.com/chetantewarii-source/test-node-app.git'
        //     }
        // }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'npm test'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER .
                docker tag $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                    echo $PASSWORD | docker login -u $USERNAME --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER
                docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                kubectl set image deployment/square-node-app \
                square-node-app=$DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER

                kubectl rollout status deployment/square-node-app
                '''
            }
        }

        stage('Cleanup') {
            steps {
                sh '''
                docker rmi $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER || true
                '''
    }
}

    }
}