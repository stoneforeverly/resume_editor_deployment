#!/bin/bash

AWS_DEFAULT_REGION="ap-southeast-2"
AWS_ACCOUNT_ID="539247470249"

# Docker login
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Stop and remove containers
docker stop resume-frontend  resume-backend  
docker rm resume-frontend  resume-backend
# docker stop editor-frontend editor-backend market-frontend market-backend
# docker rm editor-frontend editor-backend market-frontend market-backend

docker network create resume-network || true

# Pull the latest images
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:backend-latest
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:frontend-latest
# docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/market-frontend:latest
# docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/market-backend:latest

# Run the new containers
docker run -d --name resume-frontend --network my-app-network --network-alias backend -p 80:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:frontend-latest
docker run -d --name resume-backend --network my-app-network --network-alias backend -p 8080:8080 -e OPENAI_API_KEY=${OPENAI_API_KEY} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:frontend-latest
# docker run -d --name market-frontend -p 3000:3000 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/market-frontend:latest
# docker run -d --name market-backend -p 5001:5001 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/market-backend:latest

# Clean up old images
docker image prune -f

# 健康检查（等待服务启动）
sleep 10
docker ps -a
echo "=== 前端日志 ==="
docker logs resume-frontend --tail 20
echo "=== 后端日志 ==="
docker logs resume-backend --tail 20

docker ps
