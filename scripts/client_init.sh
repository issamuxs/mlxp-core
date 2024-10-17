#!/bin/bash

source ./config/base_config.sh

create_s3_user() {
    # Create an IAM user
    aws iam create-user --user-name $S3_USER

    # Attach a policy (you can create a custom policy or use AmazonS3FullAccess for full access)
    aws iam attach-user-policy --user-name $S3_USER --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

        # Create access key
    ACCESS_KEY=$(aws iam create-access-key --user-name $S3_USER)

    ACCESS_KEY_ID=$(echo $ACCESS_KEY | jq -r '.AccessKey.AccessKeyId')
    SECRET_ACCESS_KEY=$(echo $ACCESS_KEY | jq -r '.AccessKey.SecretAccessKey')

}

create_client_config() {
    echo "Creating client configuration file..."
    cat <<EOF > outputs/client_config.json
{
    "INSTANCE_ID": "$INSTANCE_ID",
    "PUBLIC_IP": "$PUBLIC_IP",
    "MLFLOW_PORT": "$MLFLOW_PORT",
    "AWS_PARAM": {
        "UserName": "$S3_USER",
        "AccessKeyId": "$ACCESS_KEY_ID",
        "SecretAccessKey": "$SECRET_ACCESS_KEY",
        "Region": "$AWS_REGION",
        "Output": "$AWS_OUTPUT"
    }
}
EOF

    echo "Configuration saved to outputs/client_config.json"

}