#!/bin/bash

source ./config.sh
source ./init-ec2-server.sh
source ./init-s3.sh
source ./server-deploy.sh

#Main script execution
echo "Welcome to EC2 ML platform Server Creation Script"

#Select key pair
conditional_create_key_pair

#Create EC2 instance
create_ec2_instance

#Create S3 bucket for artifacts
init_s3

#Server deploy
config_transfer

