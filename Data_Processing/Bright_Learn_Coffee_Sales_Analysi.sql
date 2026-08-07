
---------------------------------------------

--- 1. Return All Records

SELECT *
From workspace.bronze.sales_table;

---------------------------------------------

--- 2. Count the number of records

SELECT COUNT(*)
From workspace.bronze.sales_table;

--- Count is 149116

---------------------------------------------

--- 3. Check for Duplicates

SELECT *,
        COUNT(*)
FROM workspace.bronze.sales_table
GROUP BY ALL
HAVING COUNT(*)>1;

--- No Duplicate Found

---------------------------------------------

--- 4. Checking for NULL/Missing Values

SELECT *,
        CASE
        WHEN transaction_id IS NULL THEN 'Missing transaction_id'
        WHEN transaction_date IS NULL THEN 'Missing transaction_dare'
        WHEN transaction_time IS NULL THEN "Missing transaction_time"
        WHEN transaction_qty IS NULL THEN "Missing transaction_qty"
        WHEN store_id IS NULL THEN "Missing_store_id"
        WHEN store_location IS NULL THEN "Missing_store_locaation"
        WHEN product_id IS NULL THEN "Missing_product_id"
        WHEN unit_price IS NULL THEN "Missing_unit_price"
        WHEN product_category IS NULL THEN "Missing_product_category"
        WHEN product_type IS NULL THEN "Missing_product_type"
        WHEN product_detail IS NULL THEN "Missing_product_detail"
        END AS rejection_reason 
FROM workspace.bronze.sales_table
WHERE 
        transaction_id IS NULL
        OR transaction_date IS NULL 
        OR transaction_time IS NULL 
        OR transaction_qty IS NULL 
        OR store_id IS NULL 
        OR store_location IS NULL 
        OR product_id IS NULL 
        OR unit_price IS NULL 
        OR product_category IS NULL 
        OR product_type IS NULL 
        OR product_detail IS NULL ;

--- No NULL Values

-------------------------------------------------------

-- Change String to Decimal and change ","with "."

SELECT 
        CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) AS Unit_Price
FROM workspace.bronze.sales_table;

--------------------------------------------------------

-----5. Checking Opening and closing times

SELECT 
        MIN(DATE_FORMAT(transaction_time,"HH:mm:ss")) AS Min_Time,
        MAX(DATE_FORMAT(transaction_time,"HH:mm:ss")) AS Max_Time
FROM workspace.bronze.sales_table;

---- 6am - 8:59pm time Interval

---------------------------------------------------------

------ 6. Creating Time Buckets by 3 hours

SELECT  DATE_FORMAT(transaction_time,"HH:mm:ss") AS Trans_Time,
        CASE
                WHEN Trans_Time BETWEEN '06:00:00' AND '08:59:99' THEN "6am-9am"
                WHEN Trans_Time BETWEEN '09:00:00' AND '11:59:99' THEN "9am-12pm"
                WHEN Trans_Time BETWEEN '12:00:00' AND '14:59:99' THEN "12pm-3pm"
                WHEN Trans_Time BETWEEN '15:00:00' AND '17:59:99' THEN "3pm-6pm"
                WHEN Trans_Time BETWEEN '18:00:00' AND '20:59:99' THEN "6pm-9pm"
                ELSE ""
                END AS Time_Bucket
FROM workspace.bronze.sales_table; 


--------------------------------------------------------

--- 7. Creating Year/Month, Month name and Number, Day name and number

SELECT
        transaction_date,
        DATE_FORMAT(transaction_date,"yyyy-MMM") AS YEAR_MONTH,
        MONTHNAME(transaction_date) AS MONTHNAME,
        MONTH(transaction_date) AS MONTH_Nr,
        DAYNAME(transaction_date) AS DAY_NAME,
        DAYOFWEEK(transaction_date) AS Day_of_Week_Nr
FROM workspace.bronze.sales_table;


---------------------------------------------------------------------

--- 8. Calculation of Total Revenue

SELECT
        transaction_id,
        Transaction_qty,
        (transaction_qty * CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2))) AS Total_Revenue,
        CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) AS Unit_Price,
        ROUND(((CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) * transaction_qty) / transaction_qty),2) AS AVG_Price
FROM workspace.bronze.sales_table
GROUP BY ALL
Order by 2 DESC;



--------------------------------------------------------------------

---- 9. Create Table

SELECT 
        transaction_id,
        transaction_date,
        DATE_FORMAT(transaction_date,"yyyy-MMM") AS YEAR_MONTH,
        MONTHNAME(transaction_date) AS MONTHNAME,
        MONTH(transaction_date) AS MONTH_Nr,
        DAYNAME(transaction_date) AS DAY_NAME,
        DAYOFWEEK(transaction_date) AS Day_of_Week_Nr,
        DATE_FORMAT(transaction_time,"HH:mm:ss") AS Trans_Time,
        DATE_FORMAT(transaction_time,"HH:00") AS Hour_of_Day,
        CASE
                WHEN Trans_Time BETWEEN '06:00:00' AND '08:59:99' THEN "1"
                WHEN Trans_Time BETWEEN '09:00:00' AND '11:59:99' THEN "2"
                WHEN Trans_Time BETWEEN '12:00:00' AND '14:59:99' THEN "3"
                WHEN Trans_Time BETWEEN '15:00:00' AND '17:59:99' THEN "4"
                WHEN Trans_Time BETWEEN '18:00:00' AND '20:59:99' THEN "5"
                ELSE ""
                END AS Time_Bucket_Sort_Order,
        CASE
                WHEN Trans_Time BETWEEN '06:00:00' AND '08:59:99' THEN "Early Morning"
                WHEN Trans_Time BETWEEN '09:00:00' AND '11:59:99' THEN "Late Morning"
                WHEN Trans_Time BETWEEN '12:00:00' AND '14:59:99' THEN "Early Afternoon"
                WHEN Trans_Time BETWEEN '15:00:00' AND '17:59:99' THEN "Late Afternoon"
                WHEN Trans_Time BETWEEN '18:00:00' AND '20:59:99' THEN "Evening"
                ELSE ""
                END AS Time_Bucket,
        store_location, 
        product_category, 
        product_type,  
        product_detail, 
        transaction_qty,
        CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) AS Unit_Price,
        transaction_qty * CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) AS Total_Revenue,
        ROUND(((CAST(REPLACE(unit_price,",",".") AS DECIMAL(10,2)) * transaction_qty) / transaction_qty),2) AS AVG_Price
FROM workspace.bronze.sales_table;