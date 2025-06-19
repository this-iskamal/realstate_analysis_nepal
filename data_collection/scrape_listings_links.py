from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from webdriver_manager.chrome import ChromeDriverManager
import time

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))

all_links = []
url = f"https://lalpurjanepal.com.np/buyHouse/?page=1"
driver.get(url)
time.sleep(2)

pagination_links = driver.find_elements(By.CSS_SELECTOR, "a.pagination-link")


page_numbers = []

for link in pagination_links:
    text = link.text.strip()
    if text.isdigit():
        page_numbers.append(int(text))

max_page = max(page_numbers) if page_numbers else 1


for page in range(1, max_page + 1):  
    url = f"https://lalpurjanepal.com.np/buyHouse/?page={page}"
    driver.get(url)
    time.sleep(2)

    elements = driver.find_elements(By.CSS_SELECTOR, "a.card-image")
    for el in elements:
        href = el.get_attribute("href")
        with open("data_collection/raw_output/listings.txt", "a") as file:
            file.write(href + "\n")

driver.quit()

# Print or save links
for link in all_links:
    print(link)
