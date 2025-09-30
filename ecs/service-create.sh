#!/bin/bash
set -e
CLUSTER=${1:-ecs-sample-cluster}
SERVICE_NAME=ecs-sample-service
TASK_DEF_FILE=task-definition.json

aws ecs register-task-definition --cli-input-json file://$TASK_DEF_FILE
aws ecs create-service \
  --cluster $CLUSTER \
  --service-name $SERVICE_NAME \
  --task-definition ecs-sample-app-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=ENABLED}"
