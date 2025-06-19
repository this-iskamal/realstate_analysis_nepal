DELIMITER $$

CREATE PROCEDURE sp_incremental_bronze_to_silver()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Create silver layer table if not exists
    CREATE TABLE IF NOT EXISTS silver_real_estate_clean (
        property_id VARCHAR(50) PRIMARY KEY,
        property_name TEXT,
        property_type VARCHAR(100),
        bedrooms_clean INT,
        bathrooms_clean DECIMAL(3,1),
        kitchen_clean INT,
        living_room_clean INT,
        total_floors_clean DECIMAL(3,1),
        city_clean VARCHAR(100),
        area_clean VARCHAR(100),
        property_face_clean VARCHAR(50),
        year_built_clean INT,
        property_age INT,
        built_up_area_sqft DECIMAL(10,2),
        price_rupees DECIMAL(20,0),
        negotiable BOOLEAN,
        created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        source_system VARCHAR(50) DEFAULT 'bronze_layer',
        INDEX idx_property_type (property_type),
        INDEX idx_city (city_clean),
        INDEX idx_year_built (year_built_clean),
        INDEX idx_price (price_rupees),
        INDEX idx_area (built_up_area_sqft)
    );

    START TRANSACTION;

    -- Insert/Update silver layer with incremental logic
    INSERT INTO silver_real_estate_clean (
        property_id,
        property_name,
        property_type,
        bedrooms_clean,
        bathrooms_clean,
        kitchen_clean,
        living_room_clean,
        total_floors_clean,
        city_clean,
        area_clean,
        property_face_clean,
        year_built_clean,
        property_age,
        built_up_area_sqft,
        price_rupees,
        negotiable
    )
    SELECT
        PropertyID as property_id,
        PropertyName as property_name,
        UPPER(TRIM(`Property Type`)) as property_type,
        
        -- Bedrooms imputation
        CASE
            WHEN Bedrooms REGEXP '^[0-9]+$' THEN CAST(Bedrooms AS UNSIGNED)
            WHEN `Property Type` = 'Residential' THEN 6
            WHEN `Property Type` = 'Semi-commercial' THEN 9
            WHEN `Property Type` = 'Commercial' THEN 10
            ELSE 6
        END as bedrooms_clean,
        
        -- Bathrooms imputation
        CASE
            WHEN Bathrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(Bathrooms AS DECIMAL(3,1))
            WHEN `Property Type` = 'Residential' THEN 4.0
            WHEN `Property Type` = 'Commercial' THEN 6.0
            WHEN `Property Type` = 'Semi-commercial' THEN 5.0
            ELSE 4.0
        END as bathrooms_clean,
        
        -- Kitchen imputation
        CASE
            WHEN Kitchen REGEXP '^[0-9]+$' THEN CAST(Kitchen AS UNSIGNED)
            ELSE 2
        END as kitchen_clean,
        
        -- Living Room imputation
        CASE
            WHEN `Living Room` REGEXP '^[0-9]+$' THEN CAST(`Living Room` AS UNSIGNED)
            ELSE 2
        END as living_room_clean,
        
        -- Total Floors imputation
        CASE
            WHEN `Total Floors` REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(`Total Floors` AS DECIMAL(3,1))
            WHEN `Property Type` = 'Residential' THEN 3.0
            WHEN `Property Type` = 'Commercial' THEN 4.0
            WHEN `Property Type` = 'Semi-commercial' THEN 4.0
            ELSE 3.0
        END as total_floors_clean,
        
        -- City extraction
        CASE
            WHEN `City & Area` LIKE '%,%' THEN
                TRIM(SUBSTRING(`City & Area`, 1, INSTR(`City & Area`, ',') - 1))
            WHEN `City & Area` IS NULL OR `City & Area` = '' OR `City & Area` = 'N/A' THEN 'Unknown'
            ELSE TRIM(`City & Area`)
        END as city_clean,
        
        -- Area extraction
        CASE
            WHEN `City & Area` LIKE '%,%' THEN
                TRIM(SUBSTRING(`City & Area`, INSTR(`City & Area`, ',') + 1))
            ELSE NULL
        END as area_clean,
        
        -- Property Face cleaning
        CASE
            WHEN `Property Face` = '' OR `Property Face` IS NULL THEN 'Unknown'
            ELSE TRIM(`Property Face`)
        END as property_face_clean,
        
        -- Year Built imputation
        CASE
            WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 1900 AND 2025 THEN
                CAST(`Year Built` AS UNSIGNED)
            WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 2070 AND 2090 THEN
                CAST(`Year Built` AS UNSIGNED) - 57
            WHEN `Property Type` = 'Residential' AND Pricing > 50000000 THEN 2020
            WHEN `Property Type` = 'Residential' AND Pricing > 20000000 THEN 2015
            WHEN `Property Type` = 'Residential' THEN 2010
            WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 2018
            WHEN `Property Type` = 'Commercial' THEN 2012
            WHEN `Property Type` = 'Semi-commercial' THEN 2014
            ELSE 2012
        END as year_built_clean,
        
        -- Property age calculation
        CASE
            WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 1900 AND 2025 THEN
                2025 - CAST(`Year Built` AS UNSIGNED)
            WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 2070 AND 2090 THEN
                2025 - (CAST(`Year Built` AS UNSIGNED) - 57)
            WHEN `Property Type` = 'Residential' AND Pricing > 50000000 THEN 5
            WHEN `Property Type` = 'Residential' AND Pricing > 20000000 THEN 10
            WHEN `Property Type` = 'Residential' THEN 15
            WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 7
            WHEN `Property Type` = 'Commercial' THEN 13
            WHEN `Property Type` = 'Semi-commercial' THEN 11
            ELSE 13
        END as property_age,
        
        -- Built Up Area imputation
        CASE
            WHEN `Built Up Area` LIKE '%square-feet%' THEN
                CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(15,2))
            WHEN `Built Up Area` LIKE '%aana%' THEN
                CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(15,2)) * 342.25
            WHEN `Built Up Area` LIKE '%dhur%' THEN
                CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(15,2)) * 182.25
            WHEN `Built Up Area` LIKE '%square-meter%' THEN
                CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(15,2)) * 10.764
            WHEN `Built Up Area` LIKE '%paisa%' THEN
                CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(15,2)) * 85.56
            WHEN `Built Up Area` REGEXP '^[0-9.]+$' THEN
                CAST(`Built Up Area` AS DECIMAL(15,2))
            WHEN `Property Type` = 'Residential' AND Bedrooms >= 8 THEN 3500.0
            WHEN `Property Type` = 'Residential' AND Bedrooms >= 6 THEN 2500.0
            WHEN `Property Type` = 'Residential' AND Bedrooms >= 4 THEN 1800.0
            WHEN `Property Type` = 'Residential' THEN 1200.0
            WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 5000.0
            WHEN `Property Type` = 'Commercial' AND Pricing > 50000000 THEN 3000.0
            WHEN `Property Type` = 'Commercial' THEN 2000.0
            WHEN `Property Type` = 'Semi-commercial' AND Pricing > 50000000 THEN 2800.0
            WHEN `Property Type` = 'Semi-commercial' THEN 1800.0
            ELSE 1500.0
        END as built_up_area_sqft,
        
        CASE
            WHEN Pricing REGEXP '^[0-9]+\\.?[0-9]*$' THEN
                CAST(Pricing AS DECIMAL(20,0))
            ELSE NULL
        END as price_rupees,
        
        CASE WHEN Negotiable = 'Yes' THEN TRUE ELSE FALSE END as negotiable
        
    FROM bronze_real_estate_raw b
    WHERE b.ingestion_timestamp > COALESCE(
        (SELECT MAX(created_timestamp) FROM silver_real_estate_clean), 
        '1900-01-01'
    )
    
    ON DUPLICATE KEY UPDATE
        property_name = VALUES(property_name),
        property_type = VALUES(property_type),
        bedrooms_clean = VALUES(bedrooms_clean),
        bathrooms_clean = VALUES(bathrooms_clean),
        kitchen_clean = VALUES(kitchen_clean),
        living_room_clean = VALUES(living_room_clean),
        total_floors_clean = VALUES(total_floors_clean),
        city_clean = VALUES(city_clean),
        area_clean = VALUES(area_clean),
        property_face_clean = VALUES(property_face_clean),
        year_built_clean = VALUES(year_built_clean),
        property_age = VALUES(property_age),
        built_up_area_sqft = VALUES(built_up_area_sqft),
        price_rupees = VALUES(price_rupees),
        negotiable = VALUES(negotiable);
    
    COMMIT;
END$$

DELIMITER ;
