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
               
                    def image = docker.build("availability-tracker:${IMAGE_TAG}")
                    
               
                    ECR_REPOSITORY_URI = sh(
                        script: "cd terraform && terraform output -raw ecr_repository_url",
                        returnStdout: true
                    ).trim()
                    
             
                    sh """
                        aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | \\
                        docker login --username AWS --password-stdin ${ECR_REPOSITORY_URI}
                    """
                    
              
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
                   
                    env.ECR_REPOSITORY_URI = sh(
                        script: "cd terraform && terraform output -raw ecr_repository_url",
                        returnStdout: true
                    ).trim()
                    
                    env.REDIS_ENDPOINT = sh(
                        script: "cd terraform && terraform output -raw redis_endpoint",
                        returnStdout: true
                    ).trim()
                    
                   
                    sh 'sleep 60'
                    
       
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
            echo " Deployment failed. Check logs for details."
        }
    }
}