@Library('SharedLib') _
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "hagert/teamavail"
        DOCKER_TAG = "${BUILD_NUMBER}"
        DOCKERHUB_CRED_ID = "hagert"
    }
    
//     tools {
//         nodejs "18"
//     }
    
    stages {
        stage('Run App') {
            steps {
                sh 'node -v'
                sh 'npm install'
                sh 'npm start &'
            }
        }
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
                sh 'npm test || true'
            }
        }
        
        stage('Build & Push Docker Image') {
            steps {
                script {
                  buildImage("${DOCKER_IMAGE}", "${DOCKER_TAG}")
                    
                   pushImage("${DOCKER_IMAGE}", "${DOCKER_TAG}", "${DOCKERHUB_CRED_ID}")
                    }
                }
            }
        
        
        stage('Deploy') {
            steps {
                sh """
                  export IMAGE_NAME=${DOCKER_IMAGE}
                  export TAG=${DOCKER_TAG}
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