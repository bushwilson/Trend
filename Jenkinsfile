pipeline {
    agent any

    environment {
        DOCKERHUB_USER = 'bushwilson'
        IMAGE_NAME     = 'trendify-app'
        IMAGE_TAG      = "${env.BUILD_NUMBER}"
        CLUSTER_NAME   = 'trendify-cluster'
        AWS_REGION     = 'ap-south-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG -t $DOCKERHUB_USER/$IMAGE_NAME:latest .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DH_USER',
                                                  passwordVariable: 'DH_PASS')]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG
                        docker push $DOCKERHUB_USER/$IMAGE_NAME:latest
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                    sed -i "s|image: .*|image: $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG|" k8s/deployment.yaml
                    kubectl apply -f k8s/
                    kubectl rollout status deployment/trendify-deployment --timeout=180s
                    kubectl get pods
                    kubectl get svc trendify-service
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
