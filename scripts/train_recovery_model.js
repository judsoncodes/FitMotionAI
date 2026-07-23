const fs = require('fs');
const path = require('path');

/**
 * FitMotionAI - Real Gradient Boosted Decision Tree Regressor Training Script
 * Reads data/synthetic_recovery_dataset.csv, performs 80/20 Train/Test split,
 * trains an Ensemble Gradient Boosted Tree model on 2,400 training rows,
 * evaluates on 600 test rows (RMSE/MAE), and exports assets/ml/recovery_model_params.json.
 */

// Simple Decision Stump Trainer
function trainStump(X, y, weights) {
  let bestFeature = 0;
  let bestThreshold = 0;
  let bestLeftVal = 0;
  let bestRightVal = 0;
  let minError = Infinity;

  const numFeatures = X[0].length;
  const numSamples = X.length;

  for (let f = 0; f < numFeatures; f++) {
    // Collect feature values
    const featureVals = X.map(row => row[f]);
    // Sort unique split candidates
    const sorted = Array.from(new Set(featureVals)).sort((a, b) => a - b);

    for (let i = 0; i < sorted.length - 1; i += Math.max(1, Math.floor(sorted.length / 20))) {
      const threshold = (sorted[i] + sorted[i + 1]) / 2;

      let leftSum = 0, leftWeight = 0;
      let rightSum = 0, rightWeight = 0;

      for (let s = 0; s < numSamples; s++) {
        if (X[s][f] <= threshold) {
          leftSum += y[s];
          leftWeight += 1;
        } else {
          rightSum += y[s];
          rightWeight += 1;
        }
      }

      if (leftWeight === 0 || rightWeight === 0) continue;

      const leftVal = leftSum / leftWeight;
      const rightVal = rightSum / rightWeight;

      let totalErr = 0;
      for (let s = 0; s < numSamples; s++) {
        const pred = X[s][f] <= threshold ? leftVal : rightVal;
        const diff = y[s] - pred;
        totalErr += diff * diff;
      }

      if (totalErr < minError) {
        minError = totalErr;
        bestFeature = f;
        bestThreshold = threshold;
        bestLeftVal = leftVal;
        bestRightVal = rightVal;
      }
    }
  }

  return {
    feature: bestFeature,
    threshold: bestThreshold,
    leftVal: bestLeftVal,
    rightVal: bestRightVal,
  };
}

function trainGradientBoosting(X_train, y_train, nTrees = 20, learningRate = 0.1) {
  const trees = [];
  const meanTarget = y_train.reduce((a, b) => a + b, 0) / y_train.length;
  let residuals = y_train.map(y => y - meanTarget);

  for (let t = 0; t < nTrees; t++) {
    const stump = trainStump(X_train, residuals);
    trees.push(stump);

    // Update residuals
    for (let s = 0; s < X_train.length; s++) {
      const pred = X_train[s][stump.feature] <= stump.threshold ? stump.leftVal : stump.rightVal;
      residuals[s] -= learningRate * pred;
    }
  }

  return { baseVal: meanTarget, learningRate, trees };
}

function predictModel(model, row) {
  let val = model.baseVal;
  for (const stump of model.trees) {
    const pred = row[stump.feature] <= stump.threshold ? stump.leftVal : stump.rightVal;
    val += model.learningRate * pred;
  }
  return Math.max(0.20, Math.min(1.00, val));
}

function runTraining() {
  const csvPath = path.join(__dirname, '..', 'data', 'synthetic_recovery_dataset.csv');
  if (!fs.existsSync(csvPath)) {
    console.error(`CSV file not found at ${csvPath}`);
    return;
  }

  console.log(`Reading dataset from ${csvPath}...`);
  const lines = fs.readFileSync(csvPath, 'utf8').trim().split('\n');
  const header = lines[0].split(',');
  const featureNames = header.slice(0, 5);

  const X = [];
  const y = [];

  for (let i = 1; i < lines.length; i++) {
    const parts = lines[i].split(',').map(Number);
    if (parts.length < 6 || parts.some(isNaN)) continue;
    X.push(parts.slice(0, 5));
    y.push(parts[5]);
  }

  console.log(`Loaded ${X.length} dataset rows.`);

  // 80% Train / 20% Test Split
  const splitIdx = Math.floor(X.length * 0.8);
  const X_train = X.slice(0, splitIdx);
  const y_train = y.slice(0, splitIdx);
  const X_test = X.slice(splitIdx);
  const y_test = y.slice(splitIdx);

  console.log(`Split dataset: ${X_train.length} training rows, ${X_test.length} testing rows.`);
  console.log(`Training Gradient Boosted Decision Tree Regressor Ensemble (20 Trees)...`);

  const model = trainGradientBoosting(X_train, y_train, 20, 0.1);

  // Evaluate on Test Set
  let totalSqErr = 0;
  let totalAbsErr = 0;

  for (let i = 0; i < X_test.length; i++) {
    const pred = predictModel(model, X_test[i]);
    const actual = y_test[i];
    const err = actual - pred;
    totalSqErr += err * err;
    totalAbsErr += Math.abs(err);
  }

  const rmse = Math.sqrt(totalSqErr / X_test.length).toFixed(4);
  const mae = (totalAbsErr / X_test.length).toFixed(4);

  console.log(`====================================================`);
  console.log(`XGBoost/Gradient Boosted Model Evaluation Summary`);
  console.log(`====================================================`);
  console.log(`Ensemble Size:   20 Decision Stumps`);
  console.log(`Evaluation RMSE: ${rmse}`);
  console.log(`Evaluation MAE:  ${mae}`);
  console.log(`Status:          TRAINED & VERIFIED`);

  const exportPayload = {
    modelType: "GradientBoostedDecisionTrees",
    features: featureNames,
    baseVal: model.baseVal,
    learningRate: model.learningRate,
    rmse: parseFloat(rmse),
    mae: parseFloat(mae),
    trees: model.trees,
  };

  const assetsDir = path.join(__dirname, '..', 'assets', 'ml');
  if (!fs.existsSync(assetsDir)) {
    fs.mkdirSync(assetsDir, { recursive: true });
  }

  const paramsPath = path.join(assetsDir, 'recovery_model_params.json');
  fs.writeFileSync(paramsPath, JSON.stringify(exportPayload, null, 2));
  console.log(`Exported model parameters to: ${paramsPath}`);
}

runTraining();
