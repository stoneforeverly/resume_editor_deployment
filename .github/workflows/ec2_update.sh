#!/bin/bash

AWS_DEFAULT_REGION="ap-southeast-2"
AWS_ACCOUNT_ID="539247470249"

# Docker login
aws ecr get-login-password --region ap-southeast-2 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com

# Stop and remove containers
docker stop resume-frontend resume-backend market-backend
docker rm resume-frontend resume-backend market-backend
# docker stop editor-frontend editor-backend market-frontend market-backend
# docker rm editor-frontend editor-backend market-frontend market-backend

docker network rm my-app-network 2>/dev/null || true
docker network rm resume-network 2>/dev/null || true

# 创建新网络（与docker-compose.yml完全一致）
docker network create --driver bridge resume-network

# Pull the latest images
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:backend-latest
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:frontend-latest
# docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/market-frontend:latest
docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/modifier-repo:latest

# Run the new containers
docker run -d --name resume-frontend --network resume-network --network-alias backend -p 3001:80 ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:frontend-latest
docker run -d --name resume-backend --network resume-network --network-alias backend -p 5000:8080 -e OPENAI_API_KEY=${OPENAI_API_KEY} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/resume_backend-repo:backend-latest
docker run -d --name market-backend --network resume-network --network-alias backend -p 5001:5000 -e OPENAI_API_KEY=${OPENAI_API_KEY} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/modifier-repo:latest
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
