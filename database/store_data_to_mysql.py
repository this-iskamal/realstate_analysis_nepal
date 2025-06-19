import os
import mysql.connector
import pandas as pd
from dotenv import load_dotenv
load_dotenv()

# Connect to MySQL database
db_config = {
    'host': os.getenv('DB_HOST'),
    'user': os.getenv('DB_USER'),
    'password': os.getenv('DB_PASSWORD')
}

database_name = os.getenv('DB_NAME')
table_name = "bronze_real_estate_raw"

conn = mysql.connector.connect(**db_config)
cursor = conn.cursor()

# Create database and use it
cursor.execute(f"CREATE DATABASE IF NOT EXISTS {database_name}")
cursor.execute(f"USE {database_name}")

# Create table with your exact schema
create_table_query = f"""
CREATE TABLE IF NOT EXISTS {table_name} (
    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    `row number` INT,
    PropertyID VARCHAR(50),
    PropertyName TEXT,
    Bedrooms VARCHAR(50),
    Bathrooms VARCHAR(50),
    Kitchen VARCHAR(50),
    `Living Room` VARCHAR(50),
    `Total Floors` VARCHAR(50),
    `Property Type` VARCHAR(100),
    `Property Face` VARCHAR(50),
    `Year Built` VARCHAR(50),
    Negotiable VARCHAR(10),
    `City & Area` VARCHAR(200),
    Pricing VARCHAR(100),
    `Built Up Area` VARCHAR(100),
    has_missing_values BOOLEAN DEFAULT FALSE,
    data_quality_notes TEXT,
    PRIMARY KEY (PropertyID, ingestion_timestamp)
);
"""
cursor.execute(create_table_query)
print(f"Table `{table_name}` created.")

# Load CSV data
df = pd.read_csv('data_processing/processed_data/scraped_data1.csv')
df = df.fillna("")
print(f"Loaded {len(df)} records from CSV.")

# Insert query
insert_query = f"""
INSERT INTO {table_name} (
    source_file, `row number`, PropertyID, PropertyName, Bedrooms, Bathrooms, Kitchen, 
    `Living Room`, `Total Floors`, `Property Type`, `Property Face`, `Year Built`, 
    Negotiable, `City & Area`, Pricing, `Built Up Area`, has_missing_values, data_quality_notes
) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
ON DUPLICATE KEY UPDATE
    PropertyName=VALUES(PropertyName),
    Bedrooms=VALUES(Bedrooms),
    Bathrooms=VALUES(Bathrooms),
    Kitchen=VALUES(Kitchen),
    `Living Room`=VALUES(`Living Room`),
    `Total Floors`=VALUES(`Total Floors`),
    `Property Type`=VALUES(`Property Type`),
    `Property Face`=VALUES(`Property Face`),
    `Year Built`=VALUES(`Year Built`),
    Negotiable=VALUES(Negotiable),
    `City & Area`=VALUES(`City & Area`),
    Pricing=VALUES(Pricing),
    `Built Up Area`=VALUES(`Built Up Area`),
    has_missing_values=VALUES(has_missing_values),
    data_quality_notes=VALUES(data_quality_notes);
"""

# Prepare data for bulk insert
data_to_insert = []
for idx, row in df.iterrows():
    data_to_insert.append((
        'scraped_data1.csv',
        idx + 1,
        str(row.get('PropertyID', '')),
        str(row.get('PropertyName', '')),
        str(row.get('Bedrooms', '')),
        str(row.get('Bathrooms', '')),
        str(row.get('Kitchen', '')),
        str(row.get('Living Room', '')),
        str(row.get('Total Floors', '')),
        str(row.get('Property Type', '')),
        str(row.get('Property Face', '')),
        str(row.get('Year Built', '')),
        str(row.get('Negotiable', '')),
        str(row.get('City & Area', '')),
        str(row.get('price_rupees', '')),
        str(row.get('Built Up Area', '')),
        False,
        None
    ))

# Bulk insert
try:
    cursor.executemany(insert_query, data_to_insert)
    conn.commit()
    print(f"Successfully inserted {len(data_to_insert)} records")
except mysql.connector.Error as err:
    print(f"Error: {err}")
    conn.rollback()
finally:
    cursor.close()
    conn.close()
    print("Database connection closed.")
