pipeline {
    agent { label 'slave1' }

    environment { 
        DOCKERHUB_CREDENTIALS = credentials('dockerhublogin')
        IMAGE_NAME = "archana035/hello-worldapp"
        BUILD_TAG = "${BUILD_NUMBER}"
        K8S_DEPLOYMENT = "hello-deployment"   // Kubernetes deployment name
        K8S_CONTAINER = "hello" // Container name inside deployment
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
        sshPublisher(
            publishers: [sshPublisherDesc(
                configName: 'k8s-master',
                transfers: [
                    sshTransfer(
                        cleanRemote: false,
                        excludes: '',
                        execCommand: """
                            echo "🔍 Checking if deployment '${K8S_DEPLOYMENT}' exists..."

                            if kubectl get deployment ${K8S_DEPLOYMENT} >/dev/null 2>&1; then
                                echo "✅ Deployment exists. Updating image..."
                                kubectl set image deployment/${K8S_DEPLOYMENT} ${K8S_CONTAINER}=${IMAGE_NAME}:${BUILD_TAG} --record
                                kubectl rollout status deployment/${K8S_DEPLOYMENT} --timeout=120s || exit 1
                                echo "🎉 Deployment updated successfully!"
                            else
                                echo "🚀 Deployment not found. Preparing YAMLs..."
                                sed -i "s|REPLACE_WITH_ECR_REPO:latest|${IMAGE_NAME}:${BUILD_TAG}|g" k8s/deployment.yaml
                                echo "📦 Applying deployment, service, and ingress..."
                                kubectl apply -f k8s/deployment.yaml
                                kubectl apply -f k8s/service.yaml
                                kubectl apply -f k8s/ingress.yaml
                                kubectl rollout status deployment/${K8S_DEPLOYMENT} --timeout=120s || exit 1
                                echo "🎉 First-time deployment successful!"
                            fi
                        """,
                        execTimeout: 300000,
                        flatten: false,
                        makeEmptyDirs: false,
                        noDefaultExcludes: false,
                        patternSeparator: '[, ]+',
                        remoteDirectory: '.',
                        remoteDirectorySDF: false,
                        removePrefix: '',
                        sourceFiles: ''
                    )
                ],
                usePromotionTimestamp: false,
                useWorkspaceInPromotion: false,
                verbose: true
            )]
        )
    }
}

    post {
        success {
            echo '✅ Pipeline completed successfully! App is live on Kubernetes.'
        }
        failure {
            echo '❌ Pipeline failed. Check Jenkins logs for errors.'
        }
    }
}
