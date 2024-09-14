#!/bin/bash

REGION="eu-west-3"

#Function to create key pair
create_key_pair() {
    echo -n "Enter a name for new key pair: "
    read key_name
    echo "Creating new key pair: $key_name"
    aws ec2 create-key-pair --key-name "$key_name" --query 'KeyMaterial' --output text --region $REGION > "${key_name}.pem"
    chmod 400 "${key_name}.pem"
    echo "Created new key pair: $key_name. Private key saved to ${key_name}.pem"
    KEY_NAME="$key_name"
}

select_key_pair() {
    echo "Fetching existing key pairs..."
    key_pairs=$(aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table --region $REGION)

    if [ -z "$key_pairs" ]; then
        echo "No existing key pair found."
        create_key_pair
        return
    fi 

    echo "Existing key pairs:"
    select option in $key_pairs "Create new key pair"
    do
        case $option in 
            "Create new key pair")
                create_key_pair
                break
                ;;
            *)
                if [-n "$option" ]; then
                    echo "Selected key pair: $option"
                    KEY_NAME="$option"
                    break
                else
                    echo "Invalid selection. Please try again."
                fi
                ;;
        esac
    done
}

create_ec2_instance() {
    #Set variables
    INSTANCE_TYPE="t2.nano"
    AMI_ID="ami-021c1ea7d34cd5363"
    KEY_NAME="ml-components-demo"
    SECURITY_GROUP="ml-components-demo"
    REGION="eu-west-3"

    #Create a security group
    echo "Creating a security group..."
    aws ec2 create-security-group --group-name $SECURITY_GROUP --description "Security group for ml-components-demo project"

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
        --key-name $KEY_NAME \
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
    echo "You can connect to your instance using: ssh -i ${KEY_NAME}.pem ec2-user@$PUBLIC_IP"
}

#Main script execution
echo "Welcome to EC2 ML platform Server Creation Script"

#Select key pair
select_key_pair

#Create EC2 instance
create_ec2_instance

