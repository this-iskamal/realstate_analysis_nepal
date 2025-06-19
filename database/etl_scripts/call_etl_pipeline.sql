-- Run the complete incremental ETL
CALL sp_run_incremental_etl();

-- Or run individual steps
-- CALL sp_incremental_bronze_to_silver();
-- CALL sp_incremental_load_dimensions();
-- CALL sp_incremental_load_fact_table();

SELECT 
    -- Fact table measures
    f.fact_id,
    f.price_rupees,
    f.built_up_area_sqft,
    f.price_per_sqft,
    
    -- Property dimension details
    dp.property_id,
    dp.property_name,
    dp.property_type,
    dp.bedrooms,
    dp.bathrooms,
    dp.kitchen,
    dp.living_room,
    dp.total_floors,
    dp.property_face,
    dp.negotiable,
    
    -- Location dimension details
    dl.city,
    dl.area,
    
    -- Time dimension details
    dt.year_built,
    dt.property_age,
    dt.age_category

FROM fact_real_estate f

LEFT JOIN dim_property dp 
    ON f.property_key = dp.property_key

LEFT JOIN dim_location dl 
    ON f.location_key = dl.location_key

LEFT JOIN dim_time dt 
    ON f.time_key = dt.time_key

ORDER BY f.fact_id;

