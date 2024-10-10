#import libraries and utils functions
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
import mlflow
import argparse
import json
from utils.mlflow_utils import get_next_version

def train_register_lr_model(experiment_name, model_name, register):
    """
    Train a logistic regression model on the Iris dataset and log to MLflow.

    Parameters:
    experiment_name (str): Name of the MLflow experiment
    model_name (str): Name for the model in MLflow
    register (str): 'true' to register the model, 'false' otherwise

    This function trains the model, logs metrics and parameters to MLflow,
    and optionally registers the model in the MLflow Model Registry.
    """
    iris = load_iris()
    X = iris['data']
    y = iris['target']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)

    mlflow.set_experiment(experiment_name)

    with mlflow.start_run() as run:
        model_version = get_next_version(model_name)
        model_lr = LogisticRegression(max_iter=1000)
        model_lr.fit(X_train, y_train)
        acc = model_lr.score(X_test, y_test)

        mlflow.log_param("model_type", "sklearn logistic regression")
        mlflow.log_metric("accuracy", acc)
        mlflow.sklearn.log_model(model_lr, model_name)
        mlflow.set_tag("model version", model_version)

    if register == 'true':
        print(f"Registering model {model_name} under version {model_version} for this run")
        mlflow.register_model(f"runs:/{run.info.run_id}/model", model_name)
    else:
        print("No model registered for this run")


def main():
    with open('config/ec2_params.json', 'r') as f:
        config = json.load(f)
        instance_id = config['INSTANCE_ID']
        public_ip = config['PUBLIC_IP']
        mlflow_port = config['MLFLOW_PORT']
    print(f"Connecting to instance {instance_id} with public IP {public_ip} with MLflow port {mlflow_port}")
    mlflow.set_tracking_uri(f"http://{public_ip}:{mlflow_port}")
    parser = argparse.ArgumentParser(description="Train and log a logistic regression model in MLflow")
    parser.add_argument("-en", "--experiment_name", type=str)
    parser.add_argument("-mn", "--model_name", type=str)
    parser.add_argument("-r", "--register", choices=['true', 'false'], default='false', type=str)
    args = parser.parse_args()
    train_register_lr_model(experiment_name=args.experiment_name, model_name=args.model_name, register=args.register)

if __name__ == "__main__":
    main()

