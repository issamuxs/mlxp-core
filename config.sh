#!/bin/bash

#Tagging
PROJECT_TAG="ml-components-demo"

#AWS configuration
AWS_REGION="eu-west-3"
INSTANCE_TYPE="t2.micro"
AMI_ID="ami-021c1ea7d34cd5363"
SECURITY_GROUP="ml-components-demo"
IAM_ROLE_NAME="personal-projects"
ACCOUNT_ID="882335105845"
BUCKET_PREFIX="mlxp-core"
BUCKET_NAME="${BUCKET_PREFIX}-${ACCOUNT_ID}-${AWS_REGION}"

#MLflow configuration
MLFLOW_CONF=/opt/mlflow/mlflow.conf
MLFLOW_DIR=/opt/mlflow
MLFLOW_PORT=8080
MLFLOW_BACKEND_STORE="sqlite:////opt/mlflow/mlflow.db"

#SSH configuration
SSH_USER="ec2-user"
SSH_KEY_NAME="mlxp-core06"

#Logging
LOG_FILE="/tmp/ml-components-demo.log"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_FILE
}

#Export variables
export PROJECT_TAG
export AWS_REGION
export INSTANCE_TYPE
export AMI_ID
export KEY_NAME
export SECURITY_GROUP
export IAM_ROLE_NAME
export ACCOUNT_ID
export BUCKET_PREFIX
export BUCKET_NAME
export MLFLOW_CONF
export MLFLOW_PORT
export MLFLOW_BACKEND_STORE
export SSH_USER
export SSH_KEY_NAME
export LOG_FILE



