"""
Task 1: Exploratory Data Analysis (EDA)
CodeAlpha Data Science Internship

This script performs a complete EDA on a synthetic housing dataset.
It is fully self-contained (generates its own data) so it runs without
any external CSV file.
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

# ------------------------------------------------------------
# Settings
# ------------------------------------------------------------
sns.set_style("whitegrid")
plt.rcParams["figure.figsize"] = (10, 6)

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "outputs")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ------------------------------------------------------------
# 1. Load / Generate dataset
# ------------------------------------------------------------
np.random.seed(42)
n_samples = 500

df = pd.DataFrame({
    "square_feet": np.random.normal(2000, 500, n_samples).clip(500, 5000),
    "bedrooms": np.random.randint(1, 6, n_samples),
    "bathrooms": np.random.randint(1, 4, n_samples),
    "age": np.random.randint(0, 51, n_samples),
    "location_score": np.random.uniform(1, 10, n_samples).round(1),
})

# Target: price with a real (noisy) relationship to features
df["price"] = (
    df["square_feet"] * 150
    + df["bedrooms"] * 10000
    + df["bathrooms"] * 15000
    - df["age"] * 1000
    + df["location_score"] * 5000
    + np.random.normal(0, 20000, n_samples)
).clip(50000, 1000000).round(2)

# Intentionally inject a few missing values to demonstrate handling
df.loc[df.sample(frac=0.02, random_state=1).index, "bathrooms"] = np.nan
df.loc[df.sample(frac=0.02, random_state=2).index, "location_score"] = np.nan

print("=== Dataset Loaded ===")
print(df.head())
print("\nShape:", df.shape)

# ------------------------------------------------------------
# 2. Basic info & missing values
# ------------------------------------------------------------
print("\n=== Data Types & Non-Null Counts ===")
print(df.info())

missing = df.isnull().sum()
missing = missing[missing > 0]
print("\n=== Missing Values ===")
print(missing if not missing.empty else "No missing values")

missing_df = pd.DataFrame({"column": missing.index, "missing_count": missing.values})
missing_df.to_csv(os.path.join(OUTPUT_DIR, "missing_values.csv"), index=False)

# ------------------------------------------------------------
# 3. Univariate analysis
# ------------------------------------------------------------
numeric_cols = df.select_dtypes(include=[np.number]).columns.tolist()

desc = df[numeric_cols].describe()
print("\n=== Summary Statistics ===")
print(desc)
desc.to_csv(os.path.join(OUTPUT_DIR, "summary_statistics.csv"))

# Distribution plots
fig, axes = plt.subplots(2, 3, figsize=(18, 10))
axes = axes.flatten()
for i, col in enumerate(numeric_cols):
    sns.histplot(df[col].dropna(), kde=True, ax=axes[i], color="steelblue")
    axes[i].set_title(f"Distribution of {col}")
# Hide unused subplot
if len(axes) > len(numeric_cols):
    axes[-1].set_visible(False)
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, "distributions.png"), dpi=150)
plt.close()

# Boxplots
fig, axes = plt.subplots(1, len(numeric_cols), figsize=(18, 5))
for i, col in enumerate(numeric_cols):
    sns.boxplot(x=df[col].dropna(), ax=axes[i], color="salmon")
    axes[i].set_title(f"Boxplot of {col}")
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, "boxplots.png"), dpi=150)
plt.close()

# ------------------------------------------------------------
# 4. Bivariate analysis
# ------------------------------------------------------------
# Correlation matrix
corr = df[numeric_cols].corr()
print("\n=== Correlation Matrix ===")
print(corr.round(3))

plt.figure(figsize=(8, 6))
sns.heatmap(corr, annot=True, cmap="coolwarm", center=0, fmt=".2f")
plt.title("Feature Correlation Heatmap")
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, "correlation_matrix.png"), dpi=150)
plt.close()

# Scatter matrix of key features vs price
key_features = ["square_feet", "bedrooms", "age", "location_score"]
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
axes = axes.flatten()
for i, feat in enumerate(key_features):
    sns.scatterplot(x=df[feat], y=df["price"], ax=axes[i], alpha=0.6, color="darkgreen")
    axes[i].set_title(f"Price vs {feat}")
    axes[i].set_xlabel(feat)
    axes[i].set_ylabel("Price")
plt.tight_layout()
plt.savefig(os.path.join(OUTPUT_DIR, "scatter_price_vs_features.png"), dpi=150)
plt.close()

print("\n=== EDA Complete ===")
print(f"All outputs saved to: {OUTPUT_DIR}")
