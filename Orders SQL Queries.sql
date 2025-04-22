
-- find top 10 revenue generating products
SELECT product_id, SUM(quantity * sale_price) AS revenue_generated
FROM df_orders
GROUP BY product_id
ORDER BY revenue_generated DESC
LIMIT 10;


-- find top 5 highest selling product
WITH ProductSales AS (
SELECT region,product_id, SUM(quantity * sale_price) AS TotalSales
FROM df_orders
GROUP BY region, product_id)
SELECT * FROM(
SELECT * 
, ROW_NUMBER() OVER(PARTITION BY region ORDER BY TotalSales DESC ) AS rn
from ProductSales ) A
WHERE rn <=5

--          OR

-- WITH ProductSales AS (
--     SELECT 
--         region,
--         product_id,
--         SUM(quantity * sale_price) AS TotalSales
--     FROM df_orders
--     GROUP BY region, product_id
-- ),
-- RankedProducts AS (
--     SELECT
--         region,
--         product_id,
--         TotalSales,
--         ROW_NUMBER() OVER (PARTITION BY Region ORDER BY TotalSales DESC) AS SalesRank
--     FROM ProductSales
-- )
-- SELECT 
--     region,
--     product_id,
--     TotalSales
-- FROM RankedProducts
-- WHERE SalesRank <= 5
-- ORDER BY Region, SalesRank;

--find month over month comparison for 2022 and 2023 sales eg: jan 2022 vs jan 2023
WITH cte as(
SELECT EXTRACT(YEAR FROM order_date) as sale_year,EXTRACT(MONTH FROM order_date) as sale_month,
SUM(sale_price) as sales
FROM df_orders
GROUP BY sale_year, sale_month
)
SELECT 
sale_month,
SUM(case when sale_year = 2022 then sales else 0 end) as sales_2022,
SUM(case when sale_year = 2023 then sales else 0 end) as sales_2023
FROM cte
GROUP BY sale_month
ORDER BY sale_month




-- for each category which month had highest sale
WITH monthly_sales AS (
SELECT TO_CHAR(order_date, 'YYYY-MM'
) AS month,category,SUM(sale_price) AS total_sales
FROM df_orders
GROUP BY 
TO_CHAR(order_date, 'YYYY-MM'), category
)
SELECT category, month, total_sales
FROM (
SELECT category, month, total_sales,
RANK() OVER (PARTITION BY category ORDER BY total_sales DESC) AS sales_rank
FROM monthly_sales
) AS ranked_sales
WHERE sales_rank = 1
ORDER BY category, month;



--which sub category had highest growth by profit in 2023 compared 2022
WITH sales_by_year AS 
(SELECT sub_category, EXTRACT(YEAR FROM order_date) AS year, SUM(sale_price) AS total_sales
 FROM df_orders
 WHERE EXTRACT(YEAR FROM order_date) IN (2022, 2023)
 GROUP BY sub_category, EXTRACT(YEAR FROM order_date)
),
sales_growth AS 
(SELECT a.sub_category, a.total_sales AS sales_2022,
b.total_sales AS sales_2023,
((b.total_sales - a.total_sales) / NULLIF(a.total_sales, 0)) * 100 AS growth_percentage
FROM sales_by_year a
JOIN sales_by_year b
ON a.sub_category = b.sub_category
WHERE a.year = 2022 AND b.year = 2023
)
SELECT sub_category, sales_2022, sales_2023, growth_percentage
FROM sales_growth
ORDER BY growth_percentage DESC
LIMIT 1;



























