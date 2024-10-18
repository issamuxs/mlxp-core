#!/bin/bash

source ./config/base_config.sh

check_aws_connection() {
    echo "Checking AWS connection for user $SERVER_USER using profile '$AWS_PROFILE'..."
    if ! aws_identity=$(aws sts get-caller-identity 2>&1); then
        echo "Error: Unable to connect to AWS using profile '$AWS_PROFILE', exiting"
        exit
    else
        echo "Successfully connected to AWS as $aws_identity"
    fi
}

#Function to check if security group exists
check_security_group() {
    echo "Checking security group $SECURITY_GROUP in region $AWS_REGION..."
    
    if ! security_group_check=$(aws ec2 describe-security-groups --group-names "$SECURITY_GROUP" --region "$AWS_REGION" 2>&1); then
        if [[ "$security_group_check" =~ "NotFound" ]]; then
            echo "Security group $SECURITY_GROUP does not exist in region $AWS_REGION. Unable to retrieve critical permissions, exiting."
            exit 1
        elif [[ -z "$security_group_check" ]]; then
            echo "No information returned for security group $SECURITY_GROUP in region $AWS_REGION, exiting."
            exit 1
        else
            echo "Error checking security group in region $AWS_REGION: $security_group_check"
            exit 1
        fi
    else
        echo "Security group $SECURITY_GROUP retrieved from region $AWS_REGION. Proceeding with installation..."
    fi
}