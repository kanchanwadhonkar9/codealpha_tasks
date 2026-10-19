# Task 1 – Web Scraping

**CodeAlpha Data Analytics Internship**

## Objective
Collect a custom dataset from a public website using Python (`requests` + `BeautifulSoup`).

## What it does
- Scrapes **20 catalogue pages** of [books.toscrape.com](http://books.toscrape.com)
- Extracts: title, price (GBP), star rating, availability, product URL
- Saves **400 books** to `books_dataset.csv`

## Run
```bash
pip install requests beautifulsoup4
python scraper.py
```

## Output
`books_dataset.csv` with columns:
`title`, `price_gbp`, `rating`, `in_stock`, `stock_count`, `product_url`

## Notes
- Only public data is collected.
- A short delay between requests keeps the scraper polite.
