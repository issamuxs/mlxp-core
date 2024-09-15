#!/bin/bash

source ./config.sh

#Function to create key pair
create_key_pair() {
    echo "Fetching existing pairs..."
    key_pairs=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text)

    if echo "$key_pairs" | grep -qw "$SSH_KEY_NAME"; then   
            echo "Error: Key pair '$SSH_KEY_NAME' already exists."

        while true; do
            echo -n "Enter new key name to update SSH_KEY_NAME in config.sh file or press Enter to list existing key pairs: "
            read new_key_name

            if [ -z "$new_key_name" ]; then
                echo "Existing key pairs:" 
                echo "$key_pairs" | tr ' ' '\n'
                continue
            fi
        
            if echo "$key_pairs" | grep -qw "$new_key_name"; then   
                echo "Error: Key pair '$new_key_name' already exists. Please choose a different name."
            else
                SSH_KEY_NAME="$new_key_name"
                sed -i "s/SSH_KEY_NAME=.*/SSH_KEY_NAME=\"$SSH_KEY_NAME\"/" config.sh
                echo "Updated SSH_KEY_NAME in config.sh to '$SSH_KEY_NAME'"
                break
            fi
        done
    else    
        echo "Key pair '$SSH_KEY_NAME' from config.sh file does not exist. Proceeding with key pair creation."
        echo "Creating new key pair: $SSH_KEY_NAME"
        aws ec2 create-key-pair --key-name "$SSH_KEY_NAME" --query 'KeyMaterial' --output text --region $AWS_REGION > "${SSH_KEY_NAME}.pem"
        chmod 400 "${SSH_KEY_NAME}.pem"
        echo "Created new key pair: $SSH_KEY_NAME. Private key saved to $SSH_KEY_NAME.pem"
    fi
}

create_ec2_instance() {

    #Create a security group
    echo "Creating a security group..."
    aws ec2 create-security-group --group-name $SECURITY_GROUP --description "Security group for $PROJECT_TAG project"

    #Add inbound rules
    echo "Configuring security group rules..."
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 8080 --cidr 0.0.0.0/0

    #Launch EC2 instance
    echo "Launching EC2 instance..."
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $SSH_KEY_NAME \
        --security-groups $SECURITY_GROUP \
        --query 'Instances[0].InstanceId' \
        --output text)

    echo "Launched Instance $INSTANCE_ID"

    #Wait for instance to be running
    echo "Waiting for instance to be in running state..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_ID

    #Get public IP address
    PUBLIC_IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCE_ID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)

    echo "Instance is running, public IP : $PUBLIC_IP"
    echo "You can connect to your instance using: ssh -i ${SSH_KEY_NAME}.pem ec2-user@$PUBLIC_IP"

    export INSTANCE_ID
    export PUBLIC_IP
}



