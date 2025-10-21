pipeline {
    agent { label 'slave1' }

    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerhublogin')
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
                                configName: 'k8s-master',
                                transfers: [
                                    sshTransfer(
                                        sourceFiles: 'k8s/*.yaml', // Deployment, Service, Ingress
                                        remoteDirectory: '.',       // Home directory of devopsadmin
                                        execCommand: '''
                                            # Update the image in deployment.yaml
                                            sed -i "s|REPLACE_WITH_ECR_REPO:latest|archana035/hello-worldapp:${BUILD_NUMBER}|g" deployment.yaml
                                            
                                            # Apply all YAMLs
                                            kubectl apply -f deployment.yaml
                                            kubectl apply -f service.yaml
                                            kubectl apply -f ingress.yaml
                                            
                                            # Wait for rollout to complete
                                            #kubectl rollout status deployment/hello-deployment
                                        ''',
                                        cleanRemote: false,
                                        flatten: false,
                                        makeEmptyDirs: false,
                                        noDefaultExcludes: false,
                                        execTimeout: 120000
                                    )
                                ],
                                usePromotionTimestamp: false,
                                useWorkspaceInPromotion: false,
                                verbose: false
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
