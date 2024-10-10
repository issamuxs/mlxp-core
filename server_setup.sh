#!/bin/bash
source ./config.sh

#Update the system
sudo yum update -y

#Install pip and MLflow
sudo amazon-linux-extras install python3 -y
sudo yum install python3-pip -y
pip install mlflow boto3 pymysql

#Create a directory for MLflow
sudo mkdir -p $MLFLOW_DIR
sudo chown $SSH_USER:$SSH_USER $MLFLOW_DIR

#Create a configuration file for MLflow
cat << EOF > $MLFLOW_CONF
MLFLOW_TRACKING_URI=http://0.0.0.0:$MLFLOW_PORT
BACKEND_STORE_URI=$MLFLOW_BACKEND_STORE
DEFAULT_ARTIFACT_ROOT=s3://$BUCKET_NAME/artifacts/
EOF

#Create a systemd service file for MLflow
sudo tee /etc/systemd/system/mlflow.service > /dev/null << EOF
[Unit]
Description=MLflow Tracking Server
After=network.target

[Service]
User=ec2-user
WorkingDirectory=$MLFLOW_DIR
EnvironmentFile=$MLFLOW_CONF
ExecStart=/home/ec2-user/.local/bin/mlflow ui \
--host 0.0.0.0 \
--port $MLFLOW_PORT \
--backend-store-uri \${BACKEND_STORE_URI} \
--default-artifact-root \${DEFAULT_ARTIFACT_ROOT}
Restart=always

[Install]
WantedBy=multi-user.target
EOF

#Reload systemd, enable and start MLflow service
sudo systemctl daemon-reload
sudo systemctl enable mlflow
sudo systemctl start mlflow

echo "MLflow setup complete: running as a service."
echo "You can check its status with: sudo systemctl status mlflow"
echo "Access the MLflow UI at port 8080"