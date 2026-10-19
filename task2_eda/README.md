# Task 2 – Exploratory Data Analysis (EDA)

**CodeAlpha Data Analytics Internship**

## Objective
Explore the scraped books dataset to understand its structure, spot patterns, test hypotheses, and identify data issues.

## What it does
- Loads `books_dataset.csv` (400 books)
- Checks data types, missing values, and duplicates
- Computes summary statistics
- Detects price outliers using the IQR method
- Tests the hypothesis: *"Do higher-rated books cost more?"* (correlation + group means)
- Saves plots and summary CSVs to `outputs/`

## Run
```bash
pip install pandas numpy matplotlib seaborn
python eda.py
```

## Key questions answered
1. What is the distribution of book prices?
2. How are ratings distributed?
3. Are there price outliers?
4. Is there a relationship between price and rating?

## Outputs
- `outputs/summary_statistics.csv`
- `outputs/avg_price_by_rating.csv`
- `outputs/price_distribution.png`
- `outputs/rating_counts.png`
- `outputs/avg_price_by_rating.png`
