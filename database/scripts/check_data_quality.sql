-- Overall data summary
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT PropertyID) as unique_properties,
    MIN(ingestion_timestamp) as earliest_load,
    MAX(ingestion_timestamp) as latest_load
FROM bronze_real_estate_raw;




-- PropertyID format analysis
SELECT 
    LENGTH(PropertyID) as id_length,
    COUNT(*) as count,
    MIN(PropertyID) as sample_min,
    MAX(PropertyID) as sample_max
FROM bronze_real_estate_raw
GROUP BY LENGTH(PropertyID)
ORDER BY id_length;


-- Bedrooms analysis
SELECT 
    Bedrooms as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN Bedrooms REGEXP '^[0-9]+$' THEN 'Valid Integer'
        WHEN Bedrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN 'Valid Decimal'
        WHEN Bedrooms = '' OR Bedrooms = 'N/A' THEN 'Missing/Null'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY Bedrooms
ORDER BY count DESC;


-- Check if there's a pattern by property type
SELECT 
    `Property Type`,
    AVG(CAST(Bedrooms AS UNSIGNED)) as avg_bedrooms,
    COUNT(*) as total_properties,
    SUM(CASE WHEN Bedrooms IS NULL OR Bedrooms = '' THEN 1 ELSE 0 END) as null_count
FROM bronze_real_estate_raw
WHERE Bedrooms REGEXP '^[0-9]+$'
GROUP BY `Property Type`;

-- Find which property types have null bedrooms
SELECT 
    `Property Type`,
    COUNT(*) as total_count,
    SUM(CASE WHEN Bedrooms IS NULL OR Bedrooms = '' OR Bedrooms = 'N/A' THEN 1 ELSE 0 END) as null_bedrooms,
    SUM(CASE WHEN Bedrooms REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) as valid_bedrooms
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY null_bedrooms DESC;


-- Bathrooms analysis
SELECT 
    Bathrooms as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN Bathrooms REGEXP '^[0-9]+$' THEN 'Valid Integer'
        WHEN Bathrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN 'Valid Decimal'
        WHEN Bathrooms = '' OR Bathrooms = 'N/A' THEN 'Missing/Null'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY Bathrooms
ORDER BY count DESC;

-- Find which property types have null bathrooms
SELECT 
    `Property Type`,
    COUNT(*) as total_count,
    SUM(CASE WHEN Bathrooms IS NULL OR Bathrooms = '' OR Bathrooms = 'N/A' THEN 1 ELSE 0 END) as null_bathrooms,
    SUM(CASE WHEN Bathrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN 1 ELSE 0 END) as valid_bathrooms,
    AVG(CASE WHEN Bathrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(Bathrooms AS DECIMAL(3,1)) END) as avg_bathrooms
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY null_bathrooms DESC;


-- Kitchen analysis
SELECT 
    Kitchen as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN Kitchen REGEXP '^[0-9]+$' THEN 'Valid Integer'
        WHEN Kitchen = '' OR Kitchen = 'N/A' THEN 'Missing/Null'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY Kitchen
ORDER BY count DESC;


-- Kitchen analysis by property type
SELECT 
    `Property Type`,
    COUNT(*) as total_count,
    SUM(CASE WHEN Kitchen IS NULL OR Kitchen = '' OR Kitchen = 'N/A' THEN 1 ELSE 0 END) as null_kitchen,
    SUM(CASE WHEN Kitchen REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) as valid_kitchen,
    AVG(CASE WHEN Kitchen REGEXP '^[0-9]+$' THEN CAST(Kitchen AS UNSIGNED) END) as avg_kitchen
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY null_kitchen DESC;


-- Living Room analysis
SELECT 
    `Living Room` as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN `Living Room` REGEXP '^[0-9]+$' THEN 'Valid Integer'
        WHEN `Living Room` = '' OR `Living Room` = 'N/A' THEN 'Missing/Null'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY `Living Room`
ORDER BY count DESC;


-- Living Room analysis by property type
SELECT 
    `Property Type`,
    COUNT(*) as total_count,
    SUM(CASE WHEN `Living Room` IS NULL OR `Living Room` = '' OR `Living Room` = 'N/A' THEN 1 ELSE 0 END) as null_living_room,
    SUM(CASE WHEN `Living Room` REGEXP '^[0-9]+$' THEN 1 ELSE 0 END) as valid_living_room,
    AVG(CASE WHEN `Living Room` REGEXP '^[0-9]+$' THEN CAST(`Living Room` AS UNSIGNED) END) as avg_living_room
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY null_living_room DESC;

-- Total Floors analysis
SELECT 
    `Total Floors` as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN `Total Floors` REGEXP '^[0-9]*\\.?[0-9]+$' THEN 'Valid Decimal'
        WHEN `Total Floors` = '' OR `Total Floors` = 'N/A' THEN 'Missing/Null'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY `Total Floors`
ORDER BY count DESC;


-- Total Floors analysis by property type
SELECT 
    `Property Type`,
    COUNT(*) as total_count,
    SUM(CASE WHEN `Total Floors` IS NULL OR `Total Floors` = '' OR `Total Floors` = 'N/A' THEN 1 ELSE 0 END) as null_total_floors,
    SUM(CASE WHEN `Total Floors` REGEXP '^[0-9]*\\.?[0-9]+$' THEN 1 ELSE 0 END) as valid_total_floors,
    AVG(CASE WHEN `Total Floors` REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(`Total Floors` AS DECIMAL(3,1)) END) as avg_total_floors
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY null_total_floors DESC;


-- Property Type analysis
SELECT 
    `Property Type` as raw_value,
    COUNT(*) as count,
    UPPER(TRIM(`Property Type`)) as standardized_value
FROM bronze_real_estate_raw
GROUP BY `Property Type`
ORDER BY count DESC;


-- Property Face analysis
SELECT 
    `Property Face` as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN `Property Face` IN ('North', 'South', 'East', 'West') THEN 'Single Direction'
        WHEN `Property Face` LIKE '%-%' THEN 'Multiple Direction'
        WHEN `Property Face` = '' OR `Property Face` = 'N/A' THEN 'Missing'
        ELSE 'Other'
    END as direction_type
FROM bronze_real_estate_raw
GROUP BY `Property Face`
ORDER BY count DESC;


-- Year Built analysis
SELECT 
    `Year Built` as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 1900 AND 2025 THEN 'Valid Year'
        WHEN `Year Built` = '' OR `Year Built` = 'N/A' THEN 'Missing'
        ELSE 'Invalid Format'
    END as data_quality
FROM bronze_real_estate_raw
GROUP BY `Year Built`
ORDER BY count DESC
LIMIT 10;


-- Total count verification
SELECT `Year Built`,count(*) as total_records FROM bronze_real_estate_raw group by `Year Built`;

-- City & Area parsing analysis
SELECT 
    `City & Area` as raw_value,
    COUNT(*) as count,
    TRIM(SUBSTRING(`City & Area`, 1, INSTR(`City & Area`, ',') - 1)) as extracted_city,
    TRIM(SUBSTRING(`City & Area`, INSTR(`City & Area`, ',') + 1)) as extracted_area
FROM bronze_real_estate_raw
WHERE `City & Area` LIKE '%,%'
GROUP BY `City & Area`
ORDER BY count DESC;

-- Built Up Area analysis
SELECT 
    `Built Up Area` as raw_value,
    COUNT(*) as count,
    CASE 
        WHEN `Built Up Area` LIKE '%square-feet%' OR `Built Up Area` LIKE '%sq%' THEN 'Square Feet'
        WHEN `Built Up Area` = '' OR `Built Up Area` = 'N/A' THEN 'Missing'
        ELSE 'Other Format'
    END as area_format
FROM bronze_real_estate_raw
GROUP BY `Built Up Area`
ORDER BY count DESC;


-- Test Built Up Area standardization on ALL data
SELECT 
    `Built Up Area` as raw_area,
    CASE 
        -- Handle square feet formats (already in correct unit)
        WHEN `Built Up Area` REGEXP '^[0-9.]+\\s*square-feet$' THEN 
            CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(10,2))
        
        -- Handle Aana to square feet conversion (1 Aana = 342.25 sq ft)
        WHEN `Built Up Area` REGEXP '^[0-9.]+\\s*aana$' THEN 
            CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(10,2)) * 342.25
        
        -- Handle Dhur to square feet conversion (1 Dhur = 182.25 sq ft)  
        WHEN `Built Up Area` REGEXP '^[0-9.]+\\s*dhur$' THEN 
            CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(10,2)) * 182.25
        
        -- Handle square meter to square feet conversion (1 sq m = 10.764 sq ft)
        WHEN `Built Up Area` REGEXP '^[0-9.]+\\s*square-meter$' THEN 
            CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(10,2)) * 10.764
        
        -- Handle Paisa to square feet conversion (1 Paisa = 85.56 sq ft)
        WHEN `Built Up Area` REGEXP '^[0-9.]+\\s*paisa$' THEN 
            CAST(REGEXP_REPLACE(`Built Up Area`, '[^0-9.]', '') AS DECIMAL(10,2)) * 85.56
        
        -- Handle numeric only values (assume square feet)
        WHEN `Built Up Area` REGEXP '^[0-9.]+$' THEN 
            CAST(`Built Up Area` AS DECIMAL(10,2))
        
        -- Handle missing values
        WHEN `Built Up Area` IS NULL OR `Built Up Area` = '' OR `Built Up Area` = 'N/A' THEN NULL
        
        ELSE NULL
    END as area_sqft,
    
    -- Unit type identification
    CASE 
        WHEN `Built Up Area` LIKE '%square-feet%' THEN 'Square Feet'
        WHEN `Built Up Area` LIKE '%aana%' THEN 'Aana'
        WHEN `Built Up Area` LIKE '%dhur%' THEN 'Dhur'
        WHEN `Built Up Area` LIKE '%square-meter%' THEN 'Square Meter'
        WHEN `Built Up Area` LIKE '%paisa%' THEN 'Paisa'
        WHEN `Built Up Area` REGEXP '^[0-9.]+$' THEN 'Numeric Only'
        WHEN `Built Up Area` IS NULL OR `Built Up Area` = '' OR `Built Up Area` = 'N/A' THEN 'Missing'
        ELSE 'Other'
    END as unit_type,
    
    COUNT(*) as count,
    SUM(COUNT(*)) OVER() as total_count
    
FROM bronze_real_estate_raw 
GROUP BY `Built Up Area`
ORDER BY count DESC;


-- Check for problematic pricing values
SELECT 
CASE 
    WHEN Pricing REGEXP '^[0-9]+\\.?[0-9]*$' THEN 
        CAST(Pricing AS DECIMAL(20,0))
    ELSE NULL
END as price_rupees
from bronze_real_estate_raw;






