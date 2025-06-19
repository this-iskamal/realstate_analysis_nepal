-- Create Silver Layer Database and Table
CREATE DATABASE IF NOT EXISTS real_estate_dwh;
USE real_estate_dwh;



-- Create Silver Layer Table
CREATE TABLE IF NOT EXISTS silver_real_estate_clean (
    -- Primary Key
    property_id VARCHAR(50) PRIMARY KEY,
    
    -- Basic Information
    property_name TEXT,
    property_type VARCHAR(100),
    
    -- Cleaned Numeric Fields
    bedrooms_clean INT,
    bathrooms_clean DECIMAL(3,1),
    kitchen_clean INT,
    living_room_clean INT,
    total_floors_clean DECIMAL(3,1),
    
    -- Location Fields
    city_clean VARCHAR(100),
    area_clean VARCHAR(100),
    property_face_clean VARCHAR(50),
    
    -- Time Fields
    year_built_clean INT,
    property_age INT,
    
    -- Area Fields
    built_up_area_sqft DECIMAL(10,2),
    
    -- Pricing Fields 
    price_rupees DECIMAL(20,0),
    
    -- Flags
    negotiable BOOLEAN,
    
    -- Audit Fields
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_system VARCHAR(50) DEFAULT 'bronze_layer',
    
    -- Indexes for performance
    INDEX idx_property_type (property_type),
    INDEX idx_city (city_clean),
    INDEX idx_year_built (year_built_clean),
    INDEX idx_price (price_rupees),
    INDEX idx_area (built_up_area_sqft)
);
