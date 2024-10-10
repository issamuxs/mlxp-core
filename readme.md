### Description


This project aims to deploy and validate the setup of an MLflow server on a AWS EC2 instance and provide a public IP and port to access the server for machine learning experiments management.

The major steps of the deployment are the following:
1. The file config.sh must be updated with the user AWS and project information.
2. Running the main.sh file, which references all other *.sh files, will initialize an EC2 instance, a S3 bucket, deploy an MLflow server on the EC2 instance and provide a public IP and port to access it.
3. Running the xp_test.py file allows the user to check that the MLflow server is working properly: creation of experiments, training of logistic regression models using the Iris dataset and model registration.

### Technical setup

The technical steps for the project deployment are the following.

1. Create a conda environment with project dependencies:
```
conda env create -f conda.yaml
````

2. Check the conda environment Python path:
```
which python 
```

3. If needed, create a Python alias that points to the conda environment Python path, example:
```
echo 'alias python="/opt/homebrew/anaconda3/envs/mlxp-core/bin/python"' >> ~/.bashrc
````

4. Check the AWS profiles:
```
cat /Users/YourUser/.aws/credentials
````

5. Add the project AWS profile to the AWS credentials file:
```
[ml-components-demo]
aws_access_key_id = ************
aws_secret_access_key = *************
```

6. Add the project AWS config to the AWS config file:
```
[profile ml-components-demo]
region = eu-west-3
output = json
```

7. Run the following command to select the project AWS profile:
```
export AWS_PROFILE=ml-components-demo
```

8. Execute the main.sh file:
```
bash main.sh
```

9. Test that MLflow is working properly by creating an experiment and registering a model:
```
python xp_test.py -en xp-test -mn model-test -r true
```
