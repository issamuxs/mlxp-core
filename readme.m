This repo is designed to deploy and validate the setup of an MLflow server on a AWS EC2 instance and provide a public IP and port to access the server for ML experiments management.

The major steps of the deployment are the following:
1. The file config.sh must be updated with the user AWS and project information.
2. Running the main.sh file, which references all other *.sh files, will initialize an EC2 instance, a S3 bucket, deploy MLflow on the EC2 instance and provide a public IP and port to access the MLflow server.
3. Running the xp_test.py file allows the user to check that the MLflow server is working properly: creation of experiments, training of logistic regression models using the Iris dataset and model registration.

The technical steps for the project deployment are the following:

Create a conda environment with project dependencies:
conda env create -f conda.yaml

Check the conda environment Python path:
which python 

If needed, create a Python alias that points to the conda environment Python path, example:
echo 'alias python="/opt/homebrew/anaconda3/envs/mlxp-core/bin/python"' >> ~/.bashrc

Check the AWS profiles:
cat /Users/YourUser/.aws/credentials

Add the project AWS profile to the AWS credentials file:
[ml-components-demo]
aws_access_key_id = ************
aws_secret_access_key = *************

Add the project AWS config to the AWS config file:
[profile ml-components-demo]
region = eu-west-3
output = json

Run the following command to select the project AWS profile:
export AWS_PROFILE=ml-components-demo

Execute the main.sh file:
bash main.sh

Test that MLflow is working properly by creating an experiment and registering a model:
python xp_test.py -en xp-test -mn model-test -r true
