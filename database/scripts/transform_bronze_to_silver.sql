-- Updated Silver Layer INSERT with NO NULL rules
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
    
    -- Bedrooms imputation (existing)
    CASE 
        WHEN Bedrooms REGEXP '^[0-9]+$' THEN CAST(Bedrooms AS UNSIGNED)
        WHEN `Property Type` = 'Residential' THEN 6
        WHEN `Property Type` = 'Semi-commercial' THEN 9
        WHEN `Property Type` = 'Commercial' THEN 10
        ELSE 6
    END as bedrooms_clean,

    -- Bathrooms imputation (existing)
    CASE 
        WHEN Bathrooms REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(Bathrooms AS DECIMAL(3,1))
        WHEN `Property Type` = 'Residential' THEN 4.0
        WHEN `Property Type` = 'Commercial' THEN 6.0
        WHEN `Property Type` = 'Semi-commercial' THEN 5.0
        ELSE 4.0
    END as bathrooms_clean,

    -- Kitchen imputation (existing)
    CASE 
        WHEN Kitchen REGEXP '^[0-9]+$' THEN CAST(Kitchen AS UNSIGNED)
        WHEN `Property Type` = 'Residential' THEN 2
        WHEN `Property Type` = 'Commercial' THEN 2
        WHEN `Property Type` = 'Semi-commercial' THEN 2
        ELSE 2
    END as kitchen_clean,

    -- Living Room imputation (existing)
    CASE 
        WHEN `Living Room` REGEXP '^[0-9]+$' THEN CAST(`Living Room` AS UNSIGNED)
        WHEN `Property Type` = 'Residential' THEN 2
        WHEN `Property Type` = 'Commercial' THEN 2
        WHEN `Property Type` = 'Semi-commercial' THEN 2
        ELSE 2
    END as living_room_clean,

    -- Total Floors imputation (existing)
    CASE 
        WHEN `Total Floors` REGEXP '^[0-9]*\\.?[0-9]+$' THEN CAST(`Total Floors` AS DECIMAL(3,1))
        WHEN `Property Type` = 'Residential' THEN 3.0
        WHEN `Property Type` = 'Commercial' THEN 4.0
        WHEN `Property Type` = 'Semi-commercial' THEN 4.0
        ELSE 3.0
    END as total_floors_clean,

    -- City extraction (existing)
    CASE 
        WHEN `City & Area` LIKE '%,%' THEN 
            TRIM(SUBSTRING(`City & Area`, 1, INSTR(`City & Area`, ',') - 1))
        WHEN `City & Area` IS NULL OR `City & Area` = '' OR `City & Area` = 'N/A' THEN 'Unknown'
        ELSE TRIM(`City & Area`)
    END as city_clean,

    -- Area extraction (existing)
    CASE 
        WHEN `City & Area` LIKE '%,%' THEN 
            TRIM(SUBSTRING(`City & Area`, INSTR(`City & Area`, ',') + 1))
        ELSE NULL
    END as area_clean,

    -- Property Face cleaning (existing)
    CASE 
        WHEN `Property Face` = '' OR `Property Face` IS NULL THEN 'Unknown'
        ELSE TRIM(`Property Face`)
    END as property_face_clean,

    -- ENHANCED Year Built imputation (NO NULL)
    CASE 
        WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 1900 AND 2025 THEN 
            CAST(`Year Built` AS UNSIGNED)
        WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 2070 AND 2090 THEN 
            CAST(`Year Built` AS UNSIGNED) - 57
        -- Smart imputation based on property type and price
        WHEN `Property Type` = 'Residential' AND Pricing > 50000000 THEN 2020  -- Expensive residential = recent
        WHEN `Property Type` = 'Residential' AND Pricing > 20000000 THEN 2015  -- Mid-range residential
        WHEN `Property Type` = 'Residential' THEN 2010  -- Standard residential
        WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 2018  -- Expensive commercial = recent
        WHEN `Property Type` = 'Commercial' THEN 2012  -- Standard commercial
        WHEN `Property Type` = 'Semi-commercial' THEN 2014  -- Semi-commercial average
        ELSE 2012  -- Overall fallback
    END as year_built_clean,

    -- ENHANCED Property age calculation (NO NULL)
    CASE 
        WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 1900 AND 2025 THEN 
            2025 - CAST(`Year Built` AS UNSIGNED)
        WHEN `Year Built` REGEXP '^[0-9]{4}$' AND CAST(`Year Built` AS UNSIGNED) BETWEEN 2070 AND 2090 THEN 
            2025 - (CAST(`Year Built` AS UNSIGNED) - 57)
        -- Calculate age from imputed year
        WHEN `Property Type` = 'Residential' AND Pricing > 50000000 THEN 5   -- 2025 - 2020
        WHEN `Property Type` = 'Residential' AND Pricing > 20000000 THEN 10  -- 2025 - 2015
        WHEN `Property Type` = 'Residential' THEN 15  -- 2025 - 2010
        WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 7   -- 2025 - 2018
        WHEN `Property Type` = 'Commercial' THEN 13  -- 2025 - 2012
        WHEN `Property Type` = 'Semi-commercial' THEN 11  -- 2025 - 2014
        ELSE 13  -- 2025 - 2012
    END as property_age,

    -- ENHANCED Built Up Area imputation (NO NULL)
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
        -- Smart area imputation based on property type, bedrooms, and price
        WHEN `Property Type` = 'Residential' AND Bedrooms >= 8 THEN 3500.0  -- Large residential
        WHEN `Property Type` = 'Residential' AND Bedrooms >= 6 THEN 2500.0  -- Medium residential  
        WHEN `Property Type` = 'Residential' AND Bedrooms >= 4 THEN 1800.0  -- Standard residential
        WHEN `Property Type` = 'Residential' THEN 1200.0  -- Small residential
        WHEN `Property Type` = 'Commercial' AND Pricing > 100000000 THEN 5000.0  -- Large commercial
        WHEN `Property Type` = 'Commercial' AND Pricing > 50000000 THEN 3000.0   -- Medium commercial
        WHEN `Property Type` = 'Commercial' THEN 2000.0  -- Standard commercial
        WHEN `Property Type` = 'Semi-commercial' AND Pricing > 50000000 THEN 2800.0  -- Large semi-commercial
        WHEN `Property Type` = 'Semi-commercial' THEN 1800.0  -- Standard semi-commercial
        ELSE 1500.0  -- Overall fallback
    END as built_up_area_sqft,
    
    CASE 
        WHEN Pricing REGEXP '^[0-9]+\\.?[0-9]*$' THEN 
            CAST(Pricing AS DECIMAL(20,0))
        ELSE NULL
    END as price_rupees,

    -- Negotiable flag (existing)
    CASE WHEN Negotiable = 'Yes' THEN TRUE ELSE FALSE END as negotiable

FROM bronze_real_estate_raw
ON DUPLICATE KEY UPDATE
    property_name = VALUES(property_name),
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

