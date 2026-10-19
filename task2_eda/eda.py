"""
CodeAlpha Data Analytics Internship - Task 2: Exploratory Data Analysis (EDA)
Candidate: Kanchan Wadhonkar

Performs EDA on books_dataset.csv:
- data structure & types
- missing values & duplicates
- summary statistics
- distributions & outliers
- correlation analysis
- hypothesis checks

Requirements:
    pip install pandas numpy matplotlib seaborn
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style("whitegrid")
OUT = os.path.join(os.path.dirname(__file__), "outputs")
os.makedirs(OUT, exist_ok=True)

# ------------------------------------------------------------
# 1. Load data
# ------------------------------------------------------------
df = pd.read_csv(os.path.join(os.path.dirname(__file__), "books_dataset.csv"))
print("=== First 5 rows ===")
print(df.head())
print("\nShape:", df.shape)

# ------------------------------------------------------------
# 2. Structure, types, missing values
# ------------------------------------------------------------
print("\n=== Data types ===")
print(df.dtypes)

print("\n=== Missing values ===")
missing = df.isnull().sum()
print(missing)

print("\n=== Duplicate titles ===")
print(df["title"].duplicated().sum())

# ------------------------------------------------------------
# 3. Summary statistics
# ------------------------------------------------------------
summary = df[["price_gbp", "rating", "in_stock", "stock_count"]].describe()
print("\n=== Summary statistics ===")
print(summary)
summary.to_csv(os.path.join(OUT, "summary_statistics.csv"))

# ------------------------------------------------------------
# 4. Distribution & outliers
# ------------------------------------------------------------
print("\n=== Price skewness ===", round(df["price_gbp"].skew(), 3))

q1, q3 = df["price_gbp"].quantile([0.25, 0.75])
iqr = q3 - q1
lower, upper = q1 - 1.5 * iqr, q3 + 1.5 * iqr
outliers = df[(df["price_gbp"] < lower) | (df["price_gbp"] > upper)]
print(f"Price outliers (IQR method): {len(outliers)}")
print(outliers[["title", "price_gbp"]].head(10))

# ------------------------------------------------------------
# 5. Questions / hypotheses
# ------------------------------------------------------------
corr = df[["price_gbp", "rating"]].corr().iloc[0, 1]
print(f"\nCorrelation between price and rating: {corr:.3f}")

avg_by_rating = df.groupby("rating")["price_gbp"].mean().sort_index()
print("\nAverage price by rating:")
print(avg_by_rating.round(2))
avg_by_rating.to_csv(os.path.join(OUT, "avg_price_by_rating.csv"))

# ------------------------------------------------------------
# 6. Plots
# ------------------------------------------------------------
fig, axes = plt.subplots(1, 2, figsize=(14, 5))
sns.histplot(df["price_gbp"], bins=25, kde=True, ax=axes[0], color="steelblue")
axes[0].set_title("Price Distribution")
sns.boxplot(x=df["price_gbp"], ax=axes[1], color="salmon")
axes[1].set_title("Price Boxplot (outliers visible)")
plt.tight_layout()
plt.savefig(os.path.join(OUT, "price_distribution.png"), dpi=150)
plt.close()

plt.figure(figsize=(8, 5))
sns.countplot(x="rating", data=df, color="seagreen")
plt.title("Number of Books per Rating")
plt.tight_layout()
plt.savefig(os.path.join(OUT, "rating_counts.png"), dpi=150)
plt.close()

plt.figure(figsize=(8, 5))
sns.barplot(x=avg_by_rating.index, y=avg_by_rating.values, color="mediumpurple")
plt.title("Average Price by Rating")
plt.xlabel("Rating")
plt.ylabel("Average Price (GBP)")
plt.tight_layout()
plt.savefig(os.path.join(OUT, "avg_price_by_rating.png"), dpi=150)
plt.close()

print(f"\nEDA complete. Outputs saved to {OUT}")
