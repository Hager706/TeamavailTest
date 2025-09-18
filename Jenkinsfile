pipeline {
    agent any

    environment {
        IMAGE_NAME = "hagert/teamavail"
        TAG = "${BUILD_NUMBER}"
    }
    
    tools {
        nodejs "18"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Code checked out successfully"
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Code Quality') {
            steps {
                sh 'npm run lint || true'
                sh 'npm run format:check || true'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                script {
                    def image = docker.build("${IMAGE_NAME}:${TAG}")
                    sh "docker tag ${IMAGE_NAME}:${TAG} ${IMAGE_NAME}:latest"
                    
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        image.push("${TAG}")
                        image.push("latest")
                    }
                }
            }
        }
        
        stage('Deploy') {
            steps {
                sh """
                  export IMAGE_NAME=${IMAGE_NAME}
                  export TAG=${TAG}
                  docker-compose down || true
                  docker-compose pull
                  docker-compose up -d
                """
            }
        }
    }
    
    post {
        always {
            echo "Pipeline completed!"
        }
        success {
            echo "Build successful!"
        }
        failure {
            echo "Build failed!"
        }
    }
}