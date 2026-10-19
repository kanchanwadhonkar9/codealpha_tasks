# Task 3 – Data Visualization

**CodeAlpha Data Analytics Internship**

## Objective
Turn the raw scraped dataset into clear, decision-oriented visuals and a data story using **Matplotlib** and **Seaborn**.

## Dataset
`books_dataset.csv` – 400 books scraped from books.toscrape.com
Fields: `title`, `price_gbp`, `rating`, `in_stock`, `stock_count`, `product_url`

## Visuals (in `charts/`)
| # | Chart | Insight |
|---|-------|---------|
| 01 | Price distribution | Most books sit in the £20–£40 range with a right tail |
| 02 | Rating distribution | Ratings are fairly balanced across 1–5 stars |
| 03 | Average price by rating | Shows whether higher-rated books cost more |
| 04 | Price spread by rating | Boxplot reveals spread and outliers per rating |
| 05 | Price vs rating scatter | Visual check of any relationship |
| 06 | Top 10 most expensive books | Identifies premium titles |
| 07 | Price band share (pie) | Budget / Mid / Premium / Luxury split |
| 08 | Correlation heatmap | Quantifies relationships between numeric fields |

## Run
```bash
pip install pandas numpy matplotlib seaborn
python visualization.py
```

Charts are written to `charts/`.

## Data story
The catalogue is dominated by mid-priced books, price is only weakly related to rating,
and a small set of premium titles drives the high end of the price range. These visuals
help a retailer decide how to position stock, promotions, and premium collections.
