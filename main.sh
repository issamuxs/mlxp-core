#!/bin/bash

source ./config/base_config.sh
source ./scripts/aws_init.sh
source ./scripts/ec2_init.sh
source ./scripts/s3_init.sh
source ./scripts/mlflow_ec2_deploy.sh
source ./scripts/client_init.sh

#Main script execution
echo "Welcome to ML platform Server Creation Script"
echo "The installation script will try to use the AWS profile $AWS_PROFILE associated to user $SERVER_USER with security group $SECURITY_GROUP"

#Check AWS connection with available credentials
check_aws_connection

#Check security group
check_security_group

#Select key pair
conditional_create_key_pair

#Create EC2 instance
create_ec2_instance

#Create S3 bucket for artifacts
create_s3_bucket
conditional_create_client_user

#Server deploy
mlflow_ec2_deploy

#Create client configuration file
create_client_config

