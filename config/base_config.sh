#!/bin/bash

#Tagging
PROJECT_TAG="mlxp-core"

#AWS configuration
AWS_REGION="eu-west-3"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-021c1ea7d34cd5363"
SECURITY_GROUP="personal-projects" #To be created manually or through Terraform file
EC2_ROLE_NAME="mlflow-server" #To be created manually or through Terraform file
EC2_PROFILE_NAME="mlflow-server-profile" #To be created manually or through Terraform file
ACCOUNT_ID="882335105845"
BUCKET_PREFIX="mlxp-core"
BUCKET_NAME="${BUCKET_PREFIX}-${ACCOUNT_ID}-${AWS_REGION}"

#MLflow configuration
MLFLOW_DIR=/opt/mlflow
MLFLOW_PORT=8080
MLFLOW_BACKEND_STORE="sqlite:////opt/mlflow/mlflow.db"
DEFAULT_ARTIFACT_ROOT=s3://$BUCKET_NAME/artifacts/

#SSH configuration
SSH_USER="ec2-user"
SSH_KEY_NAME="10"

#Logging
LOG_FILE="/tmp/mlxp-core.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

#Export variables
export PROJECT_TAG
export AWS_REGION
export INSTANCE_TYPE
export AMI_ID
export SECURITY_GROUP
export EC2_ROLE_NAME
export EC2_PROFILE_NAME
export ACCOUNT_ID
export BUCKET_PREFIX
export BUCKET_NAME
export MLFLOW_CONF
export MLFLOW_DIR
export MLFLOW_PORT
export MLFLOW_BACKEND_STORE
export SSH_USER
export SSH_KEY_NAME
export LOG_FILE



