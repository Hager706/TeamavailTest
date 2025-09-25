#!/bin/bash
set -e

echo " Starting deployment..."


echo "Creating AWS infrastructure..."
cd terraform
terraform plan -out=tfplan
terraform apply -auto-approve tfplan

ECR_REPOSITORY_URI=$(terraform output -raw ecr_repository_url)
REDIS_ENDPOINT=$(terraform output -raw redis_endpoint)
APP_URL=$(terraform output -raw application_url)

echo " Infrastructure created!"
echo "ECR Repository: $ECR_REPOSITORY_URI"
echo "Redis Endpoint: $REDIS_ENDPOINT"
echo "Application URL: $APP_URL"

cd ..

echo " Building and pushing Docker image..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI

docker build -t availability-tracker .
docker tag availability-tracker:latest $ECR_REPOSITORY_URI:latest
docker push $ECR_REPOSITORY_URI:latest

echo "⚙️  Deploying application with Ansible..."
cd ansible
export ECR_REPOSITORY_URI=$ECR_REPOSITORY_URI
export REDIS_ENDPOINT=$REDIS_ENDPOINT
export IMAGE_TAG=latest

echo "Waiting for EC2 instances to be ready..."
sleep 90

ansible-playbook playbooks/site.yml -i inventory/aws_ec2.yml

echo "Deployment completed!"
echo "Application URL: $APP_URL"