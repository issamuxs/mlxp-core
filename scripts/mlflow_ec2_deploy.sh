#!/bin/bash

source ./config/base_config.sh
source ./scripts/ec2_init.sh

#Ensure the MLflow setup script exists

mlflow_ec2_deploy() {
    if [ ! -f "scripts/mlflow_ec2_setup.sh" ]; then
        echo "Script mlflow_ec2_setup.sh not found in scripts directory. Installation is interrupted."
        exit 1
    fi

    #Transfer script to EC2 instance
    echo "Transferring mlflow_ec2_setup.sh script to EC2 instance..."
    scp -i ~/.ssh/"${SSH_KEY_NAME}.pem" -o StrictHostKeyChecking=no config/base_config.sh config/ec2_requirements.txt scripts/mlflow_ec2_setup.sh $SSH_USER@$PUBLIC_IP:~

    #Execute the script on EC2 instance
    echo "Executing the script on EC2 instance..."
    ssh -i ~/.ssh/"${SSH_KEY_NAME}.pem" -o StrictHostKeyChecking=no $SSH_USER@$PUBLIC_IP 'bash mlflow_ec2_setup.sh'

    echo "Server setup complete on EC2 instance $INSTANCE_ID"
    echo "You can access the MLflow UI at http://$PUBLIC_IP:$MLFLOW_PORT"

}



