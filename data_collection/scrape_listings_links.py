from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager


# Setup driver
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
wait = WebDriverWait(driver, 10)  # 10 second timeout

# First script - collecting links
all_links = []
url = f"https://lalpurjanepal.com.np/buyHouse/?page=1"
driver.get(url)

# Wait for pagination links to be present instead of time.sleep(2)
pagination_links = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, "a.pagination-link")))

page_numbers = []

for link in pagination_links:
    text = link.text.strip()
    if text.isdigit():
        page_numbers.append(int(text))

max_page = max(page_numbers) if page_numbers else 1

for page in range(1, max_page + 1):  
    url = f"https://lalpurjanepal.com.np/buyHouse/?page={page}"
    driver.get(url)
    
    # Wait for card images to be present instead of time.sleep(2)
    elements = wait.until(EC.presence_of_all_elements_located((By.CSS_SELECTOR, "a.card-image")))
    
    for el in elements:
        href = el.get_attribute("href")
        with open("data_collection/raw_output/listings.txt", "a") as file:
            file.write(href + "\n")

driver.quit()