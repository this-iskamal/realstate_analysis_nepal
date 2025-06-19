-- Safe database/schema creation (if needed)
CREATE DATABASE IF NOT EXISTS real_estate_dwh;
USE real_estate_dwh;



-- Safe bronze layer table creation with IF NOT EXISTS
CREATE TABLE IF NOT EXISTS bronze_real_estate_raw (
    -- System columns for data lineage
    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(255),
    `row number` INT,
    
    -- Original data columns (preserving exact structure)
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
    Pricing VARCHAR(50),
    `Built Up Area` VARCHAR(100),
    
    -- Data quality flags
    has_missing_values BOOLEAN DEFAULT FALSE,
    data_quality_notes TEXT,
    
    -- Primary key for data integrity
    PRIMARY KEY (PropertyID, ingestion_timestamp)
);




