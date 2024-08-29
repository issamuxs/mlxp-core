from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
import mlflow
import argparse
from utils import get_next_version, register_model

def train_lr_model(model_name):
    iris = load_iris()
    X = iris['data']
    y = iris['target']

    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3)

    with mlflow.start_run(run_name=model_name) as run:
        model_version = get_next_version(model_name)
        model_lr = LogisticRegression()
        model_lr.fit(X_train, y_train)
        acc = model_lr.score(X_test, y_test)

        mlflow.log_param("model_type", "sklearn logistic regression")
        mlflow.log_metric("accuracy", acc)
        mlflow.sklearn.log_model(model_lr, model_name)
        mlflow.set_tags({"version": str(model_version)})

    #register_model(run.info.run_id, model_name)

def main():
    parser = argparse.ArgumentParser(description="Train and log a logistic regression model in Mlflow")
    parser.add_argument("--model_name", type=str)
    args = parser.parse_args()
    train_lr_model(model_name=args.model_name)

if __name__ == "__main__":
    main()

