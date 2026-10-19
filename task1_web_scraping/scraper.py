"""
CodeAlpha Data Analytics Internship - Task 1: Web Scraping
Candidate: Kanchan Wadhonkar

Scrapes book data (title, price, rating, availability, URL) from
http://books.toscrape.com and saves it to books_dataset.csv.

Requirements:
    pip install requests beautifulsoup4 pandas
"""

import csv
import time
import requests
from bs4 import BeautifulSoup

BASE_URL = "http://books.toscrape.com/catalogue/page-{}.html"
PAGES = 20  # 20 pages x 20 books = 400 books

RATING_MAP = {"One": 1, "Two": 2, "Three": 3, "Four": 4, "Five": 5}


def parse_book(article, page_url):
    title_tag = article.find("h3").find("a")
    title = title_tag.get("title", "").strip()
    relative_url = title_tag.get("href", "")
    product_url = requests.compat.urljoin(page_url, relative_url)

    price_text = article.find("p", class_="price_color").get_text(strip=True)
    price = float("".join(ch for ch in price_text if ch.isdigit() or ch == "."))

    rating_tag = article.find("p", class_="star-rating")
    rating_word = rating_tag["class"][1]
    rating = RATING_MAP.get(rating_word, 0)

    availability = article.find("p", class_="instock availability").get_text(strip=True)
    in_stock = 1 if "In stock" in availability else 0

    return {
        "title": title,
        "price_gbp": price,
        "rating": rating,
        "in_stock": in_stock,
        "stock_count": 1 if in_stock else 0,
        "product_url": product_url,
    }


def main():
    rows = []
    for page in range(1, PAGES + 1):
        url = BASE_URL.format(page)
        print(f"Scraping page {page}/{PAGES}: {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()

        soup = BeautifulSoup(response.text, "html.parser")
        articles = soup.find_all("article", class_="product_pod")
        for article in articles:
            rows.append(parse_book(article, url))

        time.sleep(0.3)  # be polite to the server

    with open("books_dataset.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=rows[0].keys())
        writer.writeheader()
        writer.writerows(rows)

    print(f"\nDone. Saved {len(rows)} books to books_dataset.csv")


if __name__ == "__main__":
    main()
