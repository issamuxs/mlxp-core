#!/bin/bash

source ./config/base_config.sh

create_s3_bucket() {
    #Check if S3 bucket exists already
    if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
        #If already exists, proceed with installation
        echo "S3 bucket $BUCKET_NAME already exists. MFflow servers with same storage generate unique run UUIDs. Proceeding with installation..."
    else
        #If not, create the S3 bucket
        echo "Creating S3 bucket: $BUCKET_NAME"
        aws s3api create-bucket \
            --bucket $BUCKET_NAME \
            --region $AWS_REGION \
            --create-bucket-configuration LocationConstraint=$AWS_REGION

        #Check if bucket creation was successful
        if [ $? -ne 0 ]; then   
            echo "Failed to create S3 bucket due to unknown error. Exiting."
            exit 1
        fi
    fi


    #Enable versioning on the bucket
    echo "Enabling versioning on the bucket..."
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

    echo "S3 setup is now complete."
    echo "Bucket name: $BUCKET_NAME"
    echo "Update MLflow server configuration to store artifacts at s3://$BUCKET_NAME/artifacts"

    # Add bucket policy to allow public write access (use carefully - to be replaced by VPC to manage client)
    aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration BlockPublicAcls=false
    echo "Adding public write access policy to the bucket..."
    aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy '{
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": [
                "s3:PutObject",
                "s3:PutObjectVersion"
                ],
                "Resource": "arn:aws:s3:::'"$BUCKET_NAME"'/*"
            }
        ]
    }'

}
