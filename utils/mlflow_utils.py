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




