import csv
import os
import time
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager

# Setup driver
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))

# Read links
with open("data_collection/raw_output/listings.txt", "r") as f:
    links = [line.strip() for line in f.readlines()]

# Define CSV fields
csv_headers = [
    "PropertyID", "PropertyName", "Bedrooms", "Bathrooms", "Kitchen", "Living Room", "Total Floors",
    "Property Type", "Property Face", "Year Built", "Negotiable", "City & Area", "Pricing", "Built Up Area"
]

# Check if CSV already exists
file_exists = os.path.isfile("data_collection/raw_output/scraped_data1.csv")

# Open CSV file in append mode
with open("data_collection/raw_output/scraped_data1.csv", "a", newline='', encoding="utf-8",buffering=1) as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=csv_headers)

    # Only write header if file is new
    if not file_exists:
        writer.writeheader()

    # Scraping loop
    for url in links:
        driver.get(url)
        time.sleep(2)

        data = {key: "" for key in csv_headers}

        try:
            data["PropertyID"] = driver.find_element(By.CSS_SELECTOR, "div.info-title p span span.color").text
        except:
            pass

        try:
            data["PropertyName"] = driver.find_element(By.CSS_SELECTOR, "div.info-title h2").text
        except:
            pass

        # House info
        items = driver.find_elements(By.CSS_SELECTOR, "ul li div div")
        for item in items:
            try:
                key = item.find_element(By.CSS_SELECTOR, "small").text
                value = item.find_element(By.CSS_SELECTOR, "h2").text
                if key in data:
                    data[key] = value
            except:
                continue

        # Overview section
        overview_items = driver.find_elements(By.CSS_SELECTOR, ".overview-content ul li")
        for item in overview_items:
            try:
                key = item.find_elements(By.TAG_NAME, "div")[0].text.strip().replace(":", "")
                value = item.find_elements(By.TAG_NAME, "div")[1].text.strip().replace("\n", " ")
                if key in data:
                    data[key] = value
            except:
                continue

        writer.writerow({key: data.get(key, "") or 'N/A' for key in csv_headers})
        csv_file.flush()


# Close browser
driver.quit()
