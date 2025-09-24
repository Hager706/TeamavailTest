pipeline {
    agent any
    
    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        ECR_REPOSITORY_URI = ''
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        TERRAFORM_VERSION = '1.5.0'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build Docker image
                    def image = docker.build("availability-tracker:${IMAGE_TAG}")
                    
                    // Get ECR repository URI from Terraform output
                    ECR_REPOSITORY_URI = sh(
                        script: "cd terraform && terraform output -raw ecr_repository_url",
                        returnStdout: true
                    ).trim()
                    
                    // Login to ECR
                    sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \\
                        docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}
                    """
                    
                    // Tag and push image
                    sh """
                        docker tag availability-tracker:${IMAGE_TAG} ${ECR_REPOSITORY_URI}:${IMAGE_TAG}
                        docker tag availability-tracker:${IMAGE_TAG} ${ECR_REPOSITORY_URI}:latest
                        docker push ${ECR_REPOSITORY_URI}:${IMAGE_TAG}
                        docker push ${ECR_REPOSITORY_URI}:latest
                    """
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform plan -out=tfplan'
                }
            }
        }
        
        stage('Terraform Apply') {
            when {
                branch 'main'
            }
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Deploy with Ansible') {
            steps {
                script {
                    // Export environment variables for Ansible
                    env.ECR_REPOSITORY_URI = sh(
                        script: "cd terraform && terraform output -raw ecr_repository_url",
                        returnStdout: true
                    ).trim()
                    
                    env.REDIS_ENDPOINT = sh(
                        script: "cd terraform && terraform output -raw redis_endpoint",
                        returnStdout: true
                    ).trim()
                    
                    // Wait for EC2 instances to be ready
                    sh 'sleep 60'
                    
                    // Run Ansible playbook
                    dir('ansible') {
                        sh """
                            export ECR_REPOSITORY_URI=${env.ECR_REPOSITORY_URI}
                            export REDIS_ENDPOINT=${env.REDIS_ENDPOINT}
                            export IMAGE_TAG=${IMAGE_TAG}
                            ansible-playbook playbooks/site.yml -i inventory/aws_ec2.yml
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def appUrl = sh(
                        script: "cd terraform && terraform output -raw application_url",
                        returnStdout: true
                    ).trim()
                    
                    // Wait for application to be ready
                    sh """
                        for i in {1..30}; do
                            if curl -f ${appUrl}; then
                                echo "Application is ready!"
                                break
                            else
                                echo "Waiting for application... (attempt \$i/30)"
                                sleep 10
                            fi
                        done
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Clean up Docker images
            sh 'docker system prune -f'
        }
        
        success {
            script {
                def appUrl = sh(
                    script: "cd terraform && terraform output -raw application_url",
                    returnStdout: true
                ).trim()
                
                echo "🎉 Deployment successful!"
                echo "Application URL: ${appUrl}"
            }
        }
        
        failure {
            echo "❌ Deployment failed. Check logs for details."
        }
    }
}