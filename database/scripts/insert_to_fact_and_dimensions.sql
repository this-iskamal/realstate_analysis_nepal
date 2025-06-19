-- Populate dimensions first
INSERT INTO dim_location (city, area)
SELECT DISTINCT city_clean, area_clean FROM silver_real_estate_clean;

INSERT INTO dim_time (year_built, property_age, age_category)
SELECT DISTINCT 
    year_built_clean,
    property_age,
    CASE 
        WHEN property_age <= 5 THEN 'New'
        WHEN property_age <= 15 THEN 'Recent'
        ELSE 'Old'
    END
FROM silver_real_estate_clean;



INSERT INTO dim_property (property_id, property_name, property_type, bedrooms, bathrooms, kitchen, living_room, total_floors, property_face, negotiable)
SELECT property_id, property_name, property_type, bedrooms_clean, bathrooms_clean, kitchen_clean, living_room_clean, total_floors_clean, property_face_clean, negotiable
FROM silver_real_estate_clean;

-- Populate fact table using surrogate key joins
INSERT INTO fact_real_estate (property_key, location_key, time_key, price_rupees, built_up_area_sqft, price_per_sqft)
SELECT 
    dp.property_key,
    dl.location_key,
    dt.time_key,
    s.price_rupees,
    s.built_up_area_sqft,
    s.price_rupees / s.built_up_area_sqft
FROM silver_real_estate_clean s
JOIN dim_property dp ON s.property_id = dp.property_id
JOIN dim_location dl ON s.city_clean = dl.city AND s.area_clean = dl.area
JOIN dim_time dt ON s.year_built_clean = dt.year_built AND s.property_age = dt.property_age;



