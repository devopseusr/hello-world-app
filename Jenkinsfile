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
                                        sourceFiles: 'k8s/deployment.yaml',
                                        remoteDirectory: '/home/devopsadmin/deployments',
                                        cleanRemote: true,
                                        execCommand: """
                                            set -ex  # Exit on error, print commands

                                            # Ensure directory exists
                                            mkdir -p /home/devopsadmin/deployments
                                            cd /home/devopsadmin/deployments

                                            echo "📂 Current directory: $(pwd)"
                                            echo "📄 Listing files:"
                                            ls -l

                                            # Check deployment file exists
                                            if [ ! -f deployment.yaml ]; then
                                                echo "❌ deployment.yaml not found!"
                                                exit 1
                                            fi

                                            # Update image in deployment.yaml
                                            echo "🔄 Updating image to ${IMAGE_NAME}:${BUILD_TAG}"
                                            sed -i "s|IMAGE_PLACEHOLDER|${IMAGE_NAME}:${BUILD_TAG}|g" deployment.yaml

                                            echo "📄 Updated deployment.yaml:"
                                            cat deployment.yaml

                                            # Apply Kubernetes deployment
                                            echo "📦 Applying deployment"
                                            kubectl apply -f deployment.yaml

                                            echo "⏳ Waiting for rollout"
                                            kubectl rollout status deployment/helloworld-app-deployment
                                        """
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
            echo '❌ Pipeline Failed. Check logs for details.'
        }
    }
}

