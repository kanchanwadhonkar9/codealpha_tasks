"""
CodeAlpha Data Analytics Internship - Task 3: Data Visualization
Candidate: Kanchan Wadhonkar

Transforms the scraped books dataset into clear, decision-oriented visuals
using Matplotlib and Seaborn. Saves 7 charts to charts/.

Requirements:
    pip install pandas numpy matplotlib seaborn
"""

import os
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style("whitegrid")
BASE = os.path.dirname(__file__)
OUT = os.path.join(BASE, "charts")
os.makedirs(OUT, exist_ok=True)

# ------------------------------------------------------------
# Load & prepare
# ------------------------------------------------------------
df = pd.read_csv(os.path.join(BASE, "books_dataset.csv"))
df["price_band"] = pd.cut(
    df["price_gbp"],
    bins=[0, 20, 35, 50, np.inf],
    labels=["Budget (<£20)", "Mid (£20-35)", "Premium (£35-50)", "Luxury (£50+)"],
)

def save(name):
    plt.tight_layout()
    plt.savefig(os.path.join(OUT, name), dpi=150)
    plt.close()
    print("saved", name)

# 1. Price distribution
plt.figure(figsize=(10, 6))
sns.histplot(df["price_gbp"], bins=25, kde=True, color="steelblue")
plt.title("Distribution of Book Prices")
plt.xlabel("Price (GBP)")
plt.ylabel("Number of Books")
save("01_price_distribution.png")

# 2. Rating distribution
plt.figure(figsize=(8, 5))
sns.countplot(x="rating", data=df, color="seagreen")
plt.title("Number of Books by Star Rating")
plt.xlabel("Rating (stars)")
plt.ylabel("Count")
save("02_rating_distribution.png")

# 3. Average price by rating
avg = df.groupby("rating")["price_gbp"].mean()
plt.figure(figsize=(8, 5))
sns.barplot(x=avg.index, y=avg.values, color="mediumpurple")
plt.title("Average Price by Rating")
plt.xlabel("Rating (stars)")
plt.ylabel("Average Price (GBP)")
save("03_avg_price_by_rating.png")

# 4. Price spread by rating (boxplot)
plt.figure(figsize=(9, 5))
sns.boxplot(x="rating", y="price_gbp", data=df, palette="Set2")
plt.title("Price Spread by Rating")
plt.xlabel("Rating (stars)")
plt.ylabel("Price (GBP)")
save("04_price_by_rating_boxplot.png")

# 5. Price vs rating (scatter with jitter)
plt.figure(figsize=(10, 6))
jitter = np.random.normal(0, 0.08, len(df))
sns.scatterplot(x=df["rating"] + jitter, y=df["price_gbp"], alpha=0.5, color="darkorange")
plt.title("Price vs Rating")
plt.xlabel("Rating (jittered)")
plt.ylabel("Price (GBP)")
save("05_price_vs_rating_scatter.png")

# 6. Top 10 most expensive books
top10 = df.nlargest(10, "price_gbp").sort_values("price_gbp")
plt.figure(figsize=(10, 6))
plt.barh(top10["title"].str.slice(0, 40), top10["price_gbp"], color="crimson")
plt.title("Top 10 Most Expensive Books")
plt.xlabel("Price (GBP)")
save("06_top10_expensive.png")

# 7. Price band share (pie)
counts = df["price_band"].value_counts()
plt.figure(figsize=(7, 7))
plt.pie(counts.values, labels=counts.index, autopct="%1.1f%%", startangle=140,
        colors=sns.color_palette("pastel"))
plt.title("Share of Books by Price Band")
save("07_price_band_pie.png")

# 8. Correlation heatmap
plt.figure(figsize=(6, 5))
sns.heatmap(df[["price_gbp", "rating", "in_stock"]].corr(),
            annot=True, cmap="coolwarm", center=0, fmt=".2f")
plt.title("Correlation Heatmap")
save("08_correlation_heatmap.png")

print("\nAll visualizations saved to", OUT)
