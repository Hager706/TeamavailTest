#!/bin/bash
yum update -y
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure AWS CLI (for ECR)
yum install -y aws-cli

# Create application directory
mkdir -p /opt/app
chown ec2-user:ec2-user /opt/app

# Environment variables
echo "ECR_REPOSITORY_URI=${ecr_repository_uri}" >> /etc/environment
echo "REDIS_ENDPOINT=${redis_endpoint}" >> /etc/environment

# Install CloudWatch agent (optional but recommended)
yum install -y amazon-cloudwatch-agent