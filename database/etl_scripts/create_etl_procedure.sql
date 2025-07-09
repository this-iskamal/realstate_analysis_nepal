DELIMITER $$

CREATE PROCEDURE sp_run_incremental_etl()
BEGIN
    -- Error handler: rollback on any error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Step 1: Bronze to Silver (clean and load)
    CALL sp_incremental_bronze_to_silver();

    -- Step 2: Load Dimension Tables
    CALL sp_incremental_load_dimensions();

    -- Step 3: Load Fact Table
    CALL sp_incremental_load_fact_table();

    COMMIT;
END$$

DELIMITER ;
