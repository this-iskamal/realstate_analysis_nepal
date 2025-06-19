-- Property Dimension
CREATE TABLE dim_property (
    property_key INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate key
    property_id VARCHAR(50) UNIQUE NOT NULL,
    property_name TEXT,
    property_type VARCHAR(100),
    bedrooms INT,
    bathrooms DECIMAL(3,1),
    kitchen INT,
    living_room INT,
    total_floors DECIMAL(3,1),
    property_face VARCHAR(50),
    negotiable BOOLEAN
);

-- Location Dimension
CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate key
    city VARCHAR(100),
    area VARCHAR(100),
    UNIQUE KEY unique_location (city, area)
);

-- Time Dimension
CREATE TABLE dim_time (
    time_key INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate key
    year_built INT,
    property_age INT,
    age_category VARCHAR(50)
);



-- Fact Table
CREATE TABLE fact_real_estate (
    fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Foreign keys (surrogate keys from dimensions)
    property_key INT NOT NULL,
    location_key INT NOT NULL,
    time_key INT NOT NULL,
    
    -- Measures
    price_rupees DECIMAL(20,0),
    built_up_area_sqft DECIMAL(15,2),
    price_per_sqft DECIMAL(10,2),
    
    -- Foreign key constraints
    FOREIGN KEY (property_key) REFERENCES dim_property(property_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    FOREIGN KEY (time_key) REFERENCES dim_time(time_key)
);
