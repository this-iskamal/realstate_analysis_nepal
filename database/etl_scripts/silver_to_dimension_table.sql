DELIMITER $$

CREATE PROCEDURE sp_incremental_load_dimensions()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Create dimension tables if not exist
    CREATE TABLE IF NOT EXISTS dim_property (
        property_key INT AUTO_INCREMENT PRIMARY KEY,
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

    CREATE TABLE IF NOT EXISTS dim_location (
        location_key INT AUTO_INCREMENT PRIMARY KEY,
        city VARCHAR(100),
        area VARCHAR(100),
        UNIQUE KEY unique_location (city, area)
    );

    CREATE TABLE IF NOT EXISTS dim_time (
        time_key INT AUTO_INCREMENT PRIMARY KEY,
        year_built INT,
        property_age INT,
        age_category VARCHAR(50)
    );

    START TRANSACTION;
    
    -- Load Location Dimension (SCD Type 1)
    INSERT INTO dim_location (city, area)
    SELECT DISTINCT s.city_clean, s.area_clean 
    FROM silver_real_estate_clean s
    LEFT JOIN dim_location dl ON s.city_clean = dl.city AND s.area_clean = dl.area
    WHERE dl.location_key IS NULL
    AND s.created_timestamp > COALESCE(
        (SELECT MAX(created_timestamp) FROM silver_real_estate_clean 
         WHERE property_id IN (SELECT property_id FROM dim_property)), 
        '1900-01-01'
    );
    
    -- Load Time Dimension (SCD Type 1)
    INSERT INTO dim_time (year_built, property_age, age_category)
    SELECT DISTINCT 
        s.year_built_clean,
        s.property_age,
        CASE
            WHEN s.property_age <= 5 THEN 'New'
            WHEN s.property_age <= 15 THEN 'Recent'
            ELSE 'Old'
        END
    FROM silver_real_estate_clean s
    LEFT JOIN dim_time dt ON s.year_built_clean = dt.year_built AND s.property_age = dt.property_age
    WHERE dt.time_key IS NULL
    AND s.created_timestamp > COALESCE(
        (SELECT MAX(created_timestamp) FROM silver_real_estate_clean 
         WHERE property_id IN (SELECT property_id FROM dim_property)), 
        '1900-01-01'
    );
    
    -- Load Property Dimension (SCD Type 1)
    INSERT INTO dim_property (
        property_id, property_name, property_type, bedrooms, bathrooms, 
        kitchen, living_room, total_floors, property_face, negotiable
    )
    SELECT 
        s.property_id, s.property_name, s.property_type, s.bedrooms_clean, 
        s.bathrooms_clean, s.kitchen_clean, s.living_room_clean, 
        s.total_floors_clean, s.property_face_clean, s.negotiable
    FROM silver_real_estate_clean s
    LEFT JOIN dim_property dp ON s.property_id = dp.property_id
    WHERE dp.property_key IS NULL
    AND s.created_timestamp > COALESCE(
        (SELECT MAX(created_timestamp) FROM silver_real_estate_clean 
         WHERE property_id IN (SELECT property_id FROM dim_property)), 
        '1900-01-01'
    )
    
    ON DUPLICATE KEY UPDATE
        property_name = VALUES(property_name),
        property_type = VALUES(property_type),
        bedrooms = VALUES(bedrooms),
        bathrooms = VALUES(bathrooms),
        kitchen = VALUES(kitchen),
        living_room = VALUES(living_room),
        total_floors = VALUES(total_floors),
        property_face = VALUES(property_face),
        negotiable = VALUES(negotiable);
    
    COMMIT;
END$$

DELIMITER ;
