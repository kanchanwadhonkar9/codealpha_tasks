# CodeAlpha Data Analytics Internship

**Candidate:** Kanchan Wadhonkar

This repository contains the completed tasks for the **CodeAlpha Data Analytics Internship**.

## Tasks Completed

| Task | Title | Folder |
|------|-------|--------|
| 1 | Web Scraping | `task1_web_scraping/` |
| 2 | Exploratory Data Analysis (EDA) | `task2_eda/` |
| 3 | Data Visualization | `task3_data_visualization/` |

## Repository Structure

```
codealpha_tasks/
├── README.md
├── task1_web_scraping/
│   ├── scraper.py
│   ├── books_dataset.csv
│   └── README.md
├── task2_eda/
│   ├── eda.py
│   ├── books_dataset.csv
│   └── README.md
└── task3_data_visualization/
    ├── visualization.py
    ├── books_dataset.csv
    ├── README.md
    └── charts/            # 7 generated visuals
```

## Dataset
A real dataset of **400 books** scraped from [books.toscrape.com](http://books.toscrape.com) with the fields:
`title`, `price_gbp`, `rating`, `in_stock`, `stock_count`, `product_url`.

## How to Run

```bash
pip install pandas numpy matplotlib seaborn beautifulsoup4 requests

# Task 1 – scrape fresh data
python task1_web_scraping/scraper.py

# Task 2 – EDA
python task2_eda/eda.py

# Task 3 – visualizations
python task3_data_visualization/visualization.py
```

## CodeAlpha
Completed as part of the **CodeAlpha Data Analytics Internship**.

Repository: https://github.com/kanchanwadhonkar9/codealpha_tasks
