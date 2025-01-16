---Запрос для расчета средней оценки продуктов по месяцам:
SELECT 
    dt.year,
    dt.month,
    dp.name AS product_name,
    AVG(fr.rating) AS avg_rating
FROM 
    fact_reviews fr
JOIN 
    dim_time dt ON fr.time_id = dt.time_id
JOIN 
    dim_products dp ON fr.product_id = dp.product_id
GROUP BY 
    dt.year, dt.month, dp.name
ORDER BY 
    dt.year, dt.month, dp.name;

-- Запрос для расчета общего количества проданных товаров и общего дохода по месяцам:
SELECT 
    t.month,
    t.year,
    SUM(s.quantity_sold) AS total_quantity_sold,
    SUM(s.total_sales) AS total_revenue
FROM 
    fact_sales s
JOIN 
    dim_time t ON s.time_id = t.time_id
GROUP BY 
    t.month, t.year
ORDER BY 
    t.year, t.month;


--Запрос для средней оценки продуктов
SELECT
    dt.year AS review_year,
    dt.month AS review_month,
    dp.name AS product_name,
    AVG(fr.rating) AS avg_rating
FROM
    fact_reviews fr
JOIN
    dim_time dt ON fr.time_id = dt.time_id
JOIN
    dim_products dp ON fr.product_id = dp.product_id
GROUP BY
    dt.year, dt.month, dp.name
ORDER BY
    review_year, review_month, avg_rating DESC;

--Запрос для данных о продажах
SELECT
    dt.year AS sales_year,
    dt.month AS sales_month,
    dp.name AS product_name,
    SUM(fs.quantity_sold) AS total_sold
FROM
    fact_sales fs
JOIN
    dim_time dt ON fs.time_id = dt.time_id
JOIN
    dim_products dp ON fs.product_id = dp.product_id
GROUP BY
    dt.year, dt.month, dp.name
ORDER BY
    sales_year, sales_month, total_sold DESC;


