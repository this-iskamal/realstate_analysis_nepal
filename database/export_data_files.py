import os
import pandas as pd
import mysql.connector
from dotenv import load_dotenv
load_dotenv()


# Database connection
conn = mysql.connector.connect(
    host=os.getenv('DB_HOST'),
    user=os.getenv('DB_USER'),
    password=os.getenv('DB_PASSWORD'),
    database=os.getenv('DB_NAME')

)

# Export to Excel
with pd.ExcelWriter('cleaned_dataset/real_estate_gold_tables_final.xlsx') as writer:
    # pd.read_sql("SELECT * FROM fact_real_estate", conn).to_excel(writer, sheet_name='Fact_Real_Estate', index=False)
    # pd.read_sql("SELECT * FROM dim_property", conn).to_excel(writer, sheet_name='Dim_Property', index=False)
    # pd.read_sql("SELECT * FROM dim_location", conn).to_excel(writer, sheet_name='Dim_Location', index=False)
    # pd.read_sql("SELECT * FROM dim_time", conn).to_excel(writer, sheet_name='Dim_Time', index=False)
    pd.read_sql("SELECT * FROM silver_real_estate_clean", conn).to_excel(writer, sheet_name='Final_Sheet', index=False)

conn.close()
