from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import csv
import os



driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))
wait = WebDriverWait(driver, 10)

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
with open("data_collection/raw_output/scraped_data1.csv", "a", newline='', encoding="utf-8", buffering=1) as csv_file:
    writer = csv.DictWriter(csv_file, fieldnames=csv_headers)

    # Only write header if file is new
    if not file_exists:
        writer.writeheader()

    # Scraping loop
    for url in links:
        driver.get(url)
        
        data = {key: "" for key in csv_headers}

        try:
            # Wait for property ID element to be present instead of time.sleep(2)
            property_id_element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "div.info-title p span span.color")))
            data["PropertyID"] = property_id_element.text
        except:
            pass

        try:
            # Wait for property name element to be present
            property_name_element = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "div.info-title h2")))
            data["PropertyName"] = property_name_element.text
        except:
            pass

        # House info - wait for the container to be present
        try:
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, "ul li div div")))
            items = driver.find_elements(By.CSS_SELECTOR, "ul li div div")
            for item in items:
                try:
                    key = item.find_element(By.CSS_SELECTOR, "small").text
                    value = item.find_element(By.CSS_SELECTOR, "h2").text
                    if key in data:
                        data[key] = value
                except:
                    continue
        except:
            pass

        # Overview section - wait for overview content to be present
        try:
            wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, ".overview-content ul li")))
            overview_items = driver.find_elements(By.CSS_SELECTOR, ".overview-content ul li")
            for item in overview_items:
                try:
                    key = item.find_elements(By.TAG_NAME, "div")[0].text.strip().replace(":", "")
                    value = item.find_elements(By.TAG_NAME, "div")[1].text.strip().replace("\n", " ")
                    if key in data:
                        data[key] = value
                except:
                    continue
        except:
            pass

        writer.writerow({key: data.get(key, "") or 'N/A' for key in csv_headers})
        csv_file.flush()

# Close browser
driver.quit()