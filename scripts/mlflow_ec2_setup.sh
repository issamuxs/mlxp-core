#!/bin/bash
source base_config.sh

#Update the system
sudo yum update -y

#Install pip and MLflow
sudo amazon-linux-extras install python3 -y
sudo yum install python3-pip -y
pip install -r ec2_requirements.txt

#Create a directory for MLflow
sudo mkdir -p $MLFLOW_DIR
sudo chown $SSH_USER:$SSH_USER $MLFLOW_DIR

#Create a systemd service file for MLflow
sudo tee /etc/systemd/system/mlflow-server.service > /dev/null << EOF
[Unit]
Description=MLflow Tracking Server (Server-side logging)
After=network.target

[Service]
User=ec2-user
WorkingDirectory=$MLFLOW_DIR
ExecStart=/home/ec2-user/.local/bin/mlflow server \
    --host 0.0.0.0 \
    --port $MLFLOW_PORT \
    --backend-store-uri $MLFLOW_BACKEND_STORE \
    --default-artifact-root $DEFAULT_ARTIFACT_ROOT \
    --no-serve-artifacts
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Reload systemd, enable and start MLflow service
sudo systemctl daemon-reload
sudo systemctl enable mlflow-server
sudo systemctl start mlflow-server

echo "MLflow server setup complete: running as a service."
echo "You can check its status with: sudo systemctl status mlflow-server"
echo "Access the MLflow UI at port 8080"