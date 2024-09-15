#!/bin/bash

source ./config.sh

init_s3() {


    #Create the S3 bucket
    echo "Creating S3 bucket: $BUCKET_NAME"
    aws s3api create-bucket \
        --bucket $BUCKET_NAME \
        --region $AWS_REGION \
        --create-bucket-configuration LocationConstraint=$AWS_REGION

    #Check if bucket creation was successful
    if [ $? -ne 0 ]; then   
        echo "Failed to create S3 bucket. Exiting."
        exit 1
    fi


    #Enable versioning on the bucket
    echo "Enabling versioning on the bucket..."
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

    echo "S3 setup is now complete."
    echo "Bucket name: $BUCKET_NAME"
    echo "Update MLflow server configuration to store artifacts at s3://$BUCKET_NAME/artifacts"

}
