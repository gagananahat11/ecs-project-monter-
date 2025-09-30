#!/bin/bash
set -e
AWS_REGION=${1:-us-east-1}
REPO=${2:-ecs-sample-app}
TAG=${3:-latest}
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker build -t $REPO:$TAG ./app
docker tag $REPO:$TAG ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPO:$TAG
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/$REPO:$TAG
