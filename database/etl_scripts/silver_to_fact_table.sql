DELIMITER $$

CREATE PROCEDURE sp_incremental_load_fact_table()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    -- Create fact table if not exists
    CREATE TABLE IF NOT EXISTS fact_real_estate (
        fact_id BIGINT AUTO_INCREMENT PRIMARY KEY,
        property_key INT NOT NULL,
        location_key INT NOT NULL,
        time_key INT NOT NULL,
        price_rupees DECIMAL(20,0),
        built_up_area_sqft DECIMAL(15,2),
        price_per_sqft DECIMAL(10,2),
        FOREIGN KEY (property_key) REFERENCES dim_property(property_key),
        FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
        FOREIGN KEY (time_key) REFERENCES dim_time(time_key)
    );

    START TRANSACTION;
    
    -- Load fact table with incremental logic
    INSERT INTO fact_real_estate (
        property_key, location_key, time_key, 
        price_rupees, built_up_area_sqft, price_per_sqft
    )
    SELECT
        dp.property_key,
        dl.location_key,
        dt.time_key,
        s.price_rupees,
        s.built_up_area_sqft,
        CASE 
            WHEN s.built_up_area_sqft > 0 THEN s.price_rupees / s.built_up_area_sqft
            ELSE NULL
        END as price_per_sqft
    FROM silver_real_estate_clean s
    JOIN dim_property dp ON s.property_id = dp.property_id
    JOIN dim_location dl ON s.city_clean = dl.city AND s.area_clean = dl.area
    JOIN dim_time dt ON s.year_built_clean = dt.year_built AND s.property_age = dt.property_age
    LEFT JOIN fact_real_estate fr ON dp.property_key = fr.property_key
    WHERE fr.fact_id IS NULL
    AND s.created_timestamp > COALESCE(
        (SELECT MAX(s2.created_timestamp) 
         FROM silver_real_estate_clean s2 
         JOIN dim_property dp2 ON s2.property_id = dp2.property_id
         JOIN fact_real_estate fr2 ON dp2.property_key = fr2.property_key), 
        '1900-01-01'
    );
    
    COMMIT;
END$$

DELIMITER ;
