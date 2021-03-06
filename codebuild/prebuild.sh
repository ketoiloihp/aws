#!/usr/bin/env bash

echo "=== Login to Amazon ECR ==="
aws --version
aws ecr get-login --no-include-email --region $AWS_DEFAULT_REGION
aws configure set region $AWS_DEFAULT_REGION
aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY

echo "=== Generating Docker Image Name & Version ==="
export DOCKER_IMAGE_NAME=$(gradle properties -q | grep "^group:" | awk '{print $2}').$(gradle properties -q | grep "^name:" | awk '{print $2}')
export DOCKER_IMAGE_VERSION=v$(gradle properties -q | grep "^version:" | awk '{print $2}')
export AWS_ECR_REPO=$AWS_REGISTRY_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com
echo $AWS_ECR_REPO
echo $DOCKER_IMAGE_NAME
echo $DOCKER_IMAGE_VERSION
echo "======="
echo $(gradle properties -q | grep "^group:" | awk '{print $2}').$(gradle properties -q | grep "^name:" | awk '{print $2}')
echo "=== Checking Docker Image Existence ==="
aws ecr describe-images --repository-name $DOCKER_IMAGE_NAME --image-ids=imageTag=$DOCKER_IMAGE_VERSION --region $AWS_DEFAULT_REGION --registry-id $AWS_REGISTRY_ID 2> /dev/null
if [[ $? == 0 ]]; then
  echo "Docker Image with name $1:$2 found. Stop Build"
  exit 1
fi
