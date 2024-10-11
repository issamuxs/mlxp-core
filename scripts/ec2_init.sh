#!/bin/bash

source ./config/base_config.sh

#Function to create key pair

create_key_pair() {
        local key_name=$1
        echo "Creating new key pair: $key_name"
        aws ec2 create-key-pair --key-name "$key_name" --query 'KeyMaterial' --output text --region $AWS_REGION > ~/.ssh/"${key_name}.pem"
        chmod 400 ~/.ssh/"${key_name}.pem"
        echo "Created new key pair: $key_name. Private key saved to ~/.ssh/$key_name.pem"
}

conditional_create_key_pair() {
    echo "Fetching existing pairs..."
    key_pairs=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output text)

    if echo "$key_pairs" | grep -qw "$SSH_KEY_NAME" || [ -f ~/.ssh/"${SSH_KEY_NAME}.pem" ]; then   
        echo "Error: Key pair '$SSH_KEY_NAME' already exists."

        while true; do
            echo -n "Enter new key name to update SSH_KEY_NAME in config.sh file or press Enter to list existing key pairs: "
            read new_key_name

            if [ -z "$new_key_name" ]; then
                echo "Existing key pairs on AWS:" 
                echo "$key_pairs" | tr ' ' '\n'
                echo "Existing key pairs in ~/.ssh:" 
                ls ~/.ssh/*.pem
                continue
            fi
        
            if echo "$key_pairs" | grep -qw "$new_key_name"; then   
                echo "Error: Key pair '$new_key_name' already exists. Please choose a different name."
            else
                SSH_KEY_NAME="$new_key_name"
                sed -i '' "s/SSH_KEY_NAME=.*/SSH_KEY_NAME=\"$SSH_KEY_NAME\"/" config/base_config.sh
                echo "Updated SSH_KEY_NAME in base_config.sh to '$SSH_KEY_NAME'"
                create_key_pair "$SSH_KEY_NAME"
                break
            fi
        done
    else    
        echo "Key pair '$SSH_KEY_NAME' from base_config.sh file does not exist. Proceeding with key pair creation."
        create_key_pair "$SSH_KEY_NAME"
    fi
}

create_iam_role_from_group() {
    local role_name=$EC2_ROLE_NAME
    local group_name=$SECURITY_GROUP
    local profile_name=$EC2_PROFILE_NAME

    # Check if the role already exists
    if ! aws iam get-role --role-name $role_name &>/dev/null; then
        echo "Creating IAM role: $role_name"
        
        # Create the role
        if ! aws iam create-role \
            --role-name $role_name \
            --assume-role-policy-document '{
                "Version": "2012-10-17",
                "Statement": [{
                    "Effect": "Allow",
                    "Principal": {"Service": "ec2.amazonaws.com"},
                    "Action": "sts:AssumeRole"
                }]
            }' &>/dev/null; then
            echo "Failed to create role. Make sure you have the necessary permissions."
            return 1
        fi

        # Attempt to attach the group's policies to the role
        echo "Attempting to attach policies from group $group_name to role $role_name"
        
        # Try to list group policies
        if group_policies=$(aws iam list-group-policies --group-name $group_name --query 'PolicyNames[]' --output text); then
            for policy in $group_policies; do
                echo "Processing policy: $policy"
                policy_json=$(aws iam get-group-policy --group-name $group_name --policy-name "$policy" --query 'PolicyDocument' --output json)
                if [ $? -eq 0 ]; then
                    echo "Attaching policy $policy to role $role_name"
                    aws iam put-role-policy \
                        --role-name "$role_name" \
                        --policy-name "$policy" \
                        --policy-document "$policy_json"
                    if [ $? -ne 0 ]; then
                        echo "Failed to attach policy $policy. Error in policy document."
                        echo "Policy document content:"
                        echo "$policy_json"
                    fi
                else
                    echo "Failed to get policy document for $policy. Skipping."
                fi
            done
        else
            echo "Failed to list group policies or no policies found. Make sure you have the necessary permissions."
        fi

        # Try to attach managed policies
        if attached_policies=$(aws iam list-attached-group-policies --group-name $group_name --query 'AttachedPolicies[].PolicyArn' --output text); then
            for arn in $attached_policies; do
                echo "Attaching policy-arn $arn to role $role_name"
                aws iam attach-role-policy --role-name $role_name --policy-arn $arn
            done
        else
            echo "Failed to list attached group policies. Make sure you have the necessary permissions."
        fi
    else
        echo "IAM role $role_name already exists."

    # Create an instance profile and add the role to it
    if ! aws iam create-instance-profile --instance-profile-name $profile_name &>/dev/null; then
        echo "Failed to create instance profile. It may already exist."
    fi

    if ! aws iam add-role-to-instance-profile --instance-profile-name $profile_name --role-name $role_name &>/dev/null; then
        echo "Failed to add role to instance profile. It may already be added."
    fi
    echo "IAM role $role_name created and configured based on available permissions."
    
    fi
}


create_ec2_instance() {

    #Check if security group exists
    if aws ec2 describe-security-groups --group-names "$SECURITY_GROUP" 2>&1 | grep -q "NotFound"; then
        
        #If not, create one
        echo "Creating a security group..."
        aws ec2 create-security-group --group-name $SECURITY_GROUP --description "Security group for $PROJECT_TAG project"

        #Add inbound rules
        echo "Configuring security group rules..."
        aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 22 --cidr 0.0.0.0/0
        aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP --protocol tcp --port 8080 --cidr 0.0.0.0/0

    else
        echo "Security group $SECURITY_GROUP already exists. Proceeding with installation..."
    fi

    #Create IAM role from group
    create_iam_role_from_group

    # Add a delay to allow IAM changes to propagate
    echo "Waiting for IAM instance profile to propagate..."
    sleep 15 

    #Launch EC2 instance
    echo "Launching EC2 instance..."
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --count 1 \
        --instance-type $INSTANCE_TYPE \
        --key-name $SSH_KEY_NAME \
        --iam-instance-profile Name=$EC2_PROFILE_NAME \
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
    echo "You can connect to your instance using: ssh -i ~/.ssh/${SSH_KEY_NAME}.pem ec2-user@$PUBLIC_IP"

    export INSTANCE_ID
    export PUBLIC_IP
}



