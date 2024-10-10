#!/bin/bash

source ./config.sh
source ./init-ec2-server.sh

#Ensure the MLflow setup script exists

config_transfer() {
    if [ ! -f "server-setup.sh" ]; then
        echo "Server setup script not found in current directory."
        exit 1
    fi

    #Transfer script to EC2 instance
    echo "Transferring Server Setup script to EC2 instance..."
    scp -i ~/.ssh/"${SSH_KEY_NAME}.pem" -o StrictHostKeyChecking=no config.sh server-setup.sh $SSH_USER@$PUBLIC_IP:~

    #Execute the script on EC2 instance
    echo "Executing the script on EC2 instance..."
    ssh -i ~/.ssh/"${SSH_KEY_NAME}.pem" -o StrictHostKeyChecking=no $SSH_USER@$PUBLIC_IP 'bash server-setup.sh'

    echo "Server setup complete on EC2 instance $INSTANCE_ID"
    echo "You can access the MLflow UI at http://$PUBLIC_IP:$MLFLOW_PORT"

    echo "{\"INSTANCE_ID\": \"$INSTANCE_ID\", \"PUBLIC_IP\": \"$PUBLIC_IP\", \"MLFLOW_PORT\": \"$MLFLOW_PORT\"}" > ec2_config.json

}



