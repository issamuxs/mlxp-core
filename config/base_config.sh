#!/bin/bash

#Tagging
SERVER_TAG="mlxp-core"

#AWS configuration
SERVER_USER="${SERVER_TAG}-user" #Created manually or via Terraform
SECURITY_GROUP="platform-team" #Created manually or via Terraform
AWS_PROFILE="${SERVER_USER}"
AWS_REGION="eu-west-3"
AWS_OUTPUT="json"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-021c1ea7d34cd5363"
EC2_ROLE_NAME="${SERVER_TAG}-ec2-role" 
EC2_PROFILE_NAME="${SERVER_TAG}-profile" 
ACCOUNT_ID="882335105845"
BUCKET_PREFIX="${SERVER_TAG}-artifacts"
BUCKET_NAME="${BUCKET_PREFIX}-${ACCOUNT_ID}-${AWS_REGION}"
CLIENT_USER="ml"

#MLflow configuration
MLFLOW_DIR=/opt/mlflow
MLFLOW_PORT=8080
MLFLOW_BACKEND_STORE="sqlite:////opt/mlflow/mlflow.db"
DEFAULT_ARTIFACT_ROOT=s3://$BUCKET_NAME/artifacts/

#SSH configuration
SSH_USER="ec2-user"
SSH_KEY_NAME="21"

#Export variables
export SERVER_TAG
export SERVER_USER
export SECURITY_GROUP
export AWS_PROFILE
export AWS_REGION
export AWS_OUTPUT
export INSTANCE_TYPE
export AMI_ID
export EC2_ROLE_NAME
export EC2_PROFILE_NAME
export ACCOUNT_ID
export BUCKET_PREFIX
export BUCKET_NAME
export CLIENT_USER
export MLFLOW_CONF
export MLFLOW_DIR
export MLFLOW_PORT
export MLFLOW_BACKEND_STORE
export SSH_USER
export SSH_KEY_NAME



