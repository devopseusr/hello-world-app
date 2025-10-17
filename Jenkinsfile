
pipeline {
    agent { label 'slave1' }

    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockercred')
        IMAGE_NAME = "archana035/hello-worldapp"
        BUILD_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('SCM Checkout') {
            steps {
                echo '📦 Performing SCM Checkout'
                git branch: 'main', url: 'https://github.com/devopseusr/hello-world-app'
            }
        }

        stage('Application Build') {
            steps {
                echo '⚙️ Building Application using Maven'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                echo '🐳 Building Docker Image'
                sh """
                    docker build -t ${IMAGE_NAME}:${BUILD_TAG} .
                    docker tag ${IMAGE_NAME}:${BUILD_TAG} ${IMAGE_NAME}:latest
                    docker image list
                """
            }
        }

        stage('Login to DockerHub') {
            steps {
                echo '🔐 Logging into DockerHub'
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }

        stage('Publish Image to DockerHub') {
            steps {
                echo '📤 Pushing Image to DockerHub'
                sh """
                    docker push ${IMAGE_NAME}:${BUILD_TAG}
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to Kubernetes Cluster') {
            steps {
                echo '🚀 Deploying to Kubernetes Cluster'
                script {
                    sshPublisher(
                        publishers: [
                            sshPublisherDesc(
                                configName: 'k8s-master',     // SSH config name in Jenkins
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: 'deployment.yaml',  // Ensure this file exists
                                        remoteDirectory: '.',                  // Remote path
                                        execCommand: '''
                                            echo "Deploying new image..."
                                            sed -i "s|IMAGE_PLACEHOLDER|${IMAGE_NAME}:${BUILD_TAG}|g" deployment.yaml
                                            kubectl apply -f deployment.yaml
                                            kubectl rollout status deployment/helloworld-app-deployment
                                        '''
                                    )
                                ]
                            )
                        ]
                    )
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment Successful! Your app is live on the cluster.'
        }
        failure {
            echo '❌ Pipeline Failed. Please check Jenkins logs for details.'
        }
    }
}
