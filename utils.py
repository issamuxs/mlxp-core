#import libraries
import mlflow
from mlflow.exceptions import MlflowException
from mlflow.tracking import MlflowClient

def get_next_version(model_name):
    """
    Determine the next version number for a given model in MLflow.

    Parameters:
    model_name (str): Name of the model to check

    Returns:
    int: Next version number, or 1 if no versions exist, or -1 on error

    This function queries MLflow for existing versions of the model
    and calculates the next version number.
    """
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
    """
    Register a model in MLflow Model Registry.

    Parameters:
    run_id (str): MLflow run ID where the model is logged
    model_name (str): Name to register the model under

    Returns:
    RegisteredModel: The registered model object

    This function registers a model from a specific MLflow run
    to the MLflow Model Registry.
    """
    client = MlflowClient()
    registered_model = mlflow.register_model(f"runs:/{run_id}/model", model_name)


