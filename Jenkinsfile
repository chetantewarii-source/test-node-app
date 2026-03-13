pipeline {

    agent any

    environment {
        DOCKERHUB_USER = "chetantewari"
        IMAGE_NAME = "square-node-app"
    }

    stages {

        stage('Build Docker Image') {
            steps {
                sh '''
                /usr/local/bin/docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER .
                /usr/local/bin/docker tag $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh 'echo $PASSWORD | /usr/local/bin/docker login -u $USERNAME --password-stdin'
                }
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                /usr/local/bin/docker push $DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER
                /usr/local/bin/docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                /usr/local/bin/kubectl set image deployment/square-node-app \
                square-node-app=$DOCKERHUB_USER/$IMAGE_NAME:$BUILD_NUMBER

                /usr/local/bin/kubectl rollout status deployment/square-node-app
                '''
            }
        }

    }
}