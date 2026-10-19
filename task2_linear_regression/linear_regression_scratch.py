"""
Task 2: Linear Regression from Scratch
CodeAlpha Data Science Internship

Implements univariate/multivariate Linear Regression using only NumPy
(gradient descent). No sklearn.linear_model.LinearRegression is used.
"""

import numpy as np
import matplotlib.pyplot as plt


class LinearRegressionScratch:
    """Linear Regression fitted with batch gradient descent."""

    def __init__(self, learning_rate=0.01, epochs=1000):
        self.learning_rate = learning_rate
        self.epochs = epochs
        self.weights = None
        self.bias = None
        self.cost_history = []

    def fit(self, X, y):
        """
        X: ndarray of shape (n_samples, n_features)
        y: ndarray of shape (n_samples,)
        """
        n_samples, n_features = X.shape

        # Initialize parameters
        self.weights = np.zeros(n_features)
        self.bias = 0.0

        # Gradient descent
        for epoch in range(self.epochs):
            y_predicted = np.dot(X, self.weights) + self.bias

            # Mean Squared Error cost
            cost = (1 / n_samples) * np.sum((y - y_predicted) ** 2)
            self.cost_history.append(cost)

            # Gradients
            dw = -(2 / n_samples) * np.dot(X.T, (y - y_predicted))
            db = -(2 / n_samples) * np.sum(y - y_predicted)

            # Update parameters
            self.weights -= self.learning_rate * dw
            self.bias -= self.learning_rate * db

        return self

    def predict(self, X):
        return np.dot(X, self.weights) + self.bias


def mean_squared_error(y_true, y_pred):
    return np.mean((y_true - y_pred) ** 2)


def root_mean_squared_error(y_true, y_pred):
    return np.sqrt(mean_squared_error(y_true, y_pred))


def r2_score(y_true, y_pred):
    ss_res = np.sum((y_true - y_pred) ** 2)
    ss_tot = np.sum((y_true - np.mean(y_true)) ** 2)
    return 1 - (ss_res / ss_tot)


# ------------------------------------------------------------
# Generate synthetic regression data
# ------------------------------------------------------------
np.random.seed(42)
n_samples = 200
X = np.random.rand(n_samples, 1) * 10  # feature between 0 and 10
true_w = 3.5
true_b = 7.0
y = true_w * X.ravel() + true_b + np.random.normal(0, 2.0, n_samples)

# ------------------------------------------------------------
# Train model from scratch
# ------------------------------------------------------------
model = LinearRegressionScratch(learning_rate=0.1, epochs=500)
model.fit(X, y)
y_pred = model.predict(X)

# ------------------------------------------------------------
# Evaluation
# ------------------------------------------------------------
mse = mean_squared_error(y, y_pred)
rmse = root_mean_squared_error(y, y_pred)
r2 = r2_score(y, y_pred)

print("=== Linear Regression from Scratch ===")
print(f"Learned weight : {model.weights[0]:.4f}  (true: {true_w})")
print(f"Learned bias   : {model.bias:.4f}      (true: {true_b})")
print(f"Final cost (MSE): {model.cost_history[-1]:.4f}")
print(f"MSE  : {mse:.4f}")
print(f"RMSE : {rmse:.4f}")
print(f"R²   : {r2:.4f}")

# ------------------------------------------------------------
# Plots
# ------------------------------------------------------------
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# 1. Cost history
axes[0].plot(model.cost_history, color="blue")
axes[0].set_xlabel("Epoch")
axes[0].set_ylabel("MSE")
axes[0].set_title("Cost History (Gradient Descent)")
axes[0].grid(True, alpha=0.3)

# 2. Regression line vs data
axes[1].scatter(X, y, color="gray", alpha=0.6, label="Actual")
x_line = np.linspace(X.min(), X.max(), 100).reshape(-1, 1)
y_line = model.predict(x_line)
axes[1].plot(x_line, y_line, color="red", linewidth=2, label="Predicted line")
axes[1].set_xlabel("X")
axes[1].set_ylabel("y")
axes[1].set_title("Linear Regression Fit (from scratch)")
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# 3. Actual vs Predicted
axes[2].scatter(y, y_pred, color="green", alpha=0.6)
axes[2].plot([y.min(), y.max()], [y.min(), y.max()], color="red", linestyle="--")
axes[2].set_xlabel("Actual")
axes[2].set_ylabel("Predicted")
axes[2].set_title("Actual vs Predicted")
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("linear_regression_results.png", dpi=150)
plt.show()
print("Plot saved as linear_regression_results.png")
