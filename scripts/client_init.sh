#!/bin/bash

source ./config/base_config.sh

create_s3_user() {
    local s3_user=$1
    echo "Creating IAM user $s3_user to access artifacts storage"

    # Create an IAM user
    aws iam create-user --user-name $s3_user

    # Attach a policy (you can create a custom policy or use AmazonS3FullAccess for full access)
    aws iam attach-user-policy --user-name $s3_user --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

    # Create access key
    ACCESS_KEY=$(aws iam create-access-key --user-name $s3_user)

    ACCESS_KEY_ID=$(echo $ACCESS_KEY | jq -r '.AccessKey.AccessKeyId')
    SECRET_ACCESS_KEY=$(echo $ACCESS_KEY | jq -r '.AccessKey.SecretAccessKey')

    echo "Successfully created IAM user $s3_user with access key"
}

conditional_create_s3_user() {
    
    # Check if the IAM user exists
    if aws iam get-user --user-name "$S3_USER" &>/dev/null; then
        echo "Error: user $S3_USER already exists. Retrieving key..."
        EXISTING_KEYS=$(aws iam list-access-keys --user-name "$S3_USER" 2>&1)
        echo "$EXISTING_KEYS" | jq -r '.AccessKeyMetadata[] | "AccessKeyId: \(.AccessKeyId), Created: \(.CreateDate)"'
        read -p "Do you have at least one secret key? [y/n]: " has_secret_key
        if [[ "$has_secret_key" =~ ^[Yy]$ ]]; then
            echo "Using existing IAM user $S3_USER. Please add secret key in outputs/client_config.json file."
        else
            while true; do
                echo -n "Enter new AWS user name for MLflow artifacts storage access: "
                read new_s3_user

                if [ -z "$new_s3_user" ]; then
                    echo "Existing users on AWS:" 
                    echo aws iam list-users | jq -r '.Users[].UserName'
                    continue
                fi

                if aws iam get-user --user-name "$new_s3_user" &>/dev/null; then   
                    echo "Error: AWS user '$new_s3_user' already exists. Please choose a different name."
                else
                    S3_USER="$new_s3_user"
                    sed -i.bak "s/S3_USER=.*/S3_USER=\"$S3_USER\"/" config/base_config.sh
                    echo "Updated S3_USER in base_config.sh to '$S3_USER'"
                    create_s3_user "$S3_USER"
                    break
                fi
            done
        fi
    else
        echo "User '$S3_USER' from base_config.sh file does not exist. Proceeding with AWS user creation."
        create_s3_user "$S3_USER"
    fi
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