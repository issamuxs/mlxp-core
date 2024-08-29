import mlflow
from mlflow.exceptions import MlflowException
from mlflow.tracking import MlflowClient

def get_next_version(model_name):
    client = MlflowClient()
    try: 
        versions = client.search_model_versions(f"name = '{model_name}'")
        if versions:
            return max(int(v.version) for v in versions) +1
        else:
            return 1
    except MlflowException as e:
            print(f'Error retrieving model version: {e}')
            return -1


def register_model(run_id, model_name):
    client = MlflowClient()
    registered_model = mlflow.register_model(f"runs:/{run_id}/model", model_name)


