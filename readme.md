### Description


This project aims to deploy and validate the setup of an MLflow server on a AWS EC2 instance and provide a public IP and port to access the server for machine learning experiments management.

The major steps of the deployment are the following:
1. The file base_config.sh must be updated with the user AWS and project information.
2. Running the main.sh file, which references all *.sh files in scripts folder, will initialize an EC2 instance, a S3 bucket, deploy an MLflow server on the EC2 instance and provide a public IP and port to access it.
3. Running the mlflow_server_test.py file allows the user to check that the MLflow server is working properly: creation of experiments, training of logistic regression models using the Iris dataset and model registration.

### Technical setup

The technical steps for the project deployment are the following.

0. #### TODO
Currently, security group, associated policy and project user attached to security group are created through AWS console. Next step is to add terraform file to setup these and automate key retrieval to update AWS credentials, config and profile.

1. Check the AWS profiles:
```
cat /Users/YourUser/.aws/credentials
````

2. Add the project AWS profile to the AWS credentials file:
```
[mlxp-core]
aws_access_key_id = ************
aws_secret_access_key = *************
```

3. Add the project AWS config to the AWS config file:
```
[profile mlxp-core]
region = eu-west-3
output = json
```

4. Run the following command to select the project AWS profile:
```
export AWS_PROFILE=mlxp-core
```

5. Create a conda environment with project dependencies:
```
conda env create -f conda.yaml
````

6. Check the conda environment Python path:
```
where python 
```

7. If needed, create a Python alias that points to the conda environment Python path, example:
```
echo 'alias python="/opt/homebrew/anaconda3/envs/mlxp-core/bin/python"' >> ~/.bashrc
source ~/.bashrc
````

8. Execute the main.sh file:
```
bash main.sh
```

9. Once the setup is finished, the MLflow server IP address and port can be found in the ec2_params.json file located in the config folder. Copy "http://$PUBLIC_IP:$MLFLOW_PORT" to the web browser to navigate through the MLflow UI.

10. Test that MLflow is working properly by creating an experiment and registering a model:
```
python mlflow_server_test.py -en xp-test -mn model-test -r true
```

