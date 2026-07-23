"""
FitMotionAI - Native Python XGBoost Recovery Intensity Model Trainer
---------------------------------------------------------------------
Trains a real xgboost.XGBRegressor on data/synthetic_recovery_dataset.csv (3,000 athlete rows),
evaluates RMSE and MAE metrics on an 80/20 train-test split, and exports model parameters.
"""

import os
import json
import numpy as np
import pandas as pd
import xgboost as xgb
from sklearn.model_selection import train_test_split

def train_xgboost_model():
    csv_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'synthetic_recovery_dataset.csv')
    if not os.path.exists(csv_path):
        print(f"Error: Dataset file not found at {csv_path}")
        return

    print(f"Reading synthetic dataset from {csv_path}...")
    df = pd.read_csv(csv_path)
    print(f"Loaded {len(df)} dataset rows.")

    X = df.drop(columns=['target_recovery_score'])
    y = df['target_recovery_score']

    # 80% Train / 20% Test Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

    print(f"Dataset Split: {len(X_train)} training rows, {len(X_test)} testing rows.")
    print("Training native XGBoost Regressor (xgb.XGBRegressor, 100 estimators)...")

    # Fit real XGBoost Regressor
    model = xgb.XGBRegressor(
        n_estimators=100,
        max_depth=4,
        learning_rate=0.1,
        random_state=42
    )
    model.fit(X_train, y_train)

    # Evaluate Model Predictions on Unseen Test Set
    y_pred = model.predict(X_test)
    y_pred = np.clip(y_pred, 0.20, 1.00)

    rmse = np.sqrt(np.mean((y_test - y_pred) ** 2))
    mae = np.mean(np.abs(y_test - y_pred))

    print("\n====================================================")
    print("Native Python XGBoost Regressor Evaluation Summary")
    print("====================================================")
    print(f"Model Class:     xgboost.XGBRegressor")
    print(f"Estimators:      100 trees (max_depth=4)")
    print(f"Evaluation RMSE: {rmse:.4f}")
    print(f"Evaluation MAE:  {mae:.4f}")
    print("Status:          SUCCESSFULLY TRAINED WITH NATIVE XGBOOST")

    # Export Model Parameters Metadata
    export_metadata = {
        "modelType": "XGBoostRegressorNative",
        "features": list(X.columns),
        "nEstimators": 100,
        "maxDepth": 4,
        "learningRate": 0.1,
        "evalRmse": float(rmse),
        "evalMae": float(mae),
        "status": "TRAINED_WITH_NATIVE_PYTHON_XGBOOST"
    }

    assets_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'ml')
    os.makedirs(assets_dir, exist_ok=True)
    params_path = os.path.join(assets_dir, 'xgboost_native_metrics.json')

    with open(params_path, 'w') as f:
        json.dump(export_metadata, f, indent=2)

    print(f"Saved native model metrics to: {params_path}")

if __name__ == '__main__':
    train_xgboost_model()
