SELECT *
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '12 months'; -- Только заказы за последний год

SELECT DISTINCT o.order_id, o.payment_status, r.rating
FROM orders o
LEFT JOIN reviews r ON o.user_id = r.user_id
WHERE o.order_date >= '2024-01-01'
  AND o.payment_status != 'completed'
  AND r.rating >= 4;

SELECT DISTINCT payment_status
FROM orders
WHERE payment_status != 'completed';


SELECT 
    o.order_id, 
    o.user_id, 
    o.order_date, 
    o.total_cost, 
    od.medicine_id, 
    od.quantity, 
    od.unit_price
FROM 
    orders o
JOIN 
    order_details od 
ON 
    o.order_id = od.order_id
WHERE 
    o.order_date >= CURRENT_DATE - INTERVAL '12 months';


COPY (
    SELECT 
        o.order_id, 
        o.user_id, 
        o.order_date, 
        o.total_cost, 
        od.medicine_id, 
        od.quantity, 
        od.unit_price
    FROM 
        orders o
    JOIN 
        order_details od 
    ON 
        o.order_id = od.order_id
    WHERE 
        o.order_date >= CURRENT_DATE - INTERVAL '12 months'
) TO 'C:\Users\anast\OneDrive\Документы\Book2.csv' WITH CSV HEADER;


SELECT *
FROM staging_orders
WHERE total_cost < 0 
   OR quantity <= 0
   OR medicine_id IS NULL 
   OR order_id IS NULL;


CREATE TABLE staging_orders (
    order_id INT,
    user_id INT,
    order_date DATE,
    total_cost DECIMAL(10, 2),
    medicine_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2)
);


SELECT *
FROM staging_orders
WHERE total_cost < 0 
   OR quantity <= 0
   OR medicine_id IS NULL 
   OR order_id IS NULL;


DELETE FROM staging_orders
WHERE total_cost < 0 
   OR quantity <= 0
   OR medicine_id IS NULL 
   OR order_id IS NULL;

DELETE FROM staging_orders
WHERE order_id IN (
    SELECT order_id
    FROM (
        SELECT order_id, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_date DESC) AS rnk
        FROM staging_orders
    ) t
    WHERE rnk > 1
);

SELECT 
    DATE_TRUNC('month', order_date) AS month,
    SUM(total_cost) AS monthly_revenue
FROM staging_orders
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;



CREATE TABLE target_orders (
    order_id INT PRIMARY KEY,
    user_id INT,
    order_date DATE,
    total_cost DECIMAL(10, 2),
    medicine_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2)
);

INSERT INTO target_orders (order_id, user_id, order_date, total_cost, medicine_id, quantity, unit_price)
SELECT order_id, user_id, order_date, total_cost, medicine_id, quantity, unit_price
FROM staging_orders
ON CONFLICT (order_id) DO NOTHING;


UPDATE target_orders
SET 
    total_cost = s.total_cost,
    quantity = s.quantity,
    unit_price = s.unit_price
FROM staging_orders s
WHERE target_orders.order_id = s.order_id
  AND (target_orders.total_cost != s.total_cost OR target_orders.quantity != s.quantity);


TRUNCATE TABLE staging_orders;


CREATE TABLE IF NOT EXISTS load_logs (
    load_id SERIAL PRIMARY KEY,
    load_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    inserted_records INT,
    updated_records INT
);


INSERT INTO load_logs (inserted_records, updated_records)
VALUES (
    (SELECT COUNT(*) FROM staging_orders s 
	LEFT JOIN target_orders t ON s.order_id = t.order_id WHERE t.order_id IS NULL),
    (SELECT COUNT(*) FROM staging_orders s 
	JOIN target_orders t ON s.order_id = t.order_id 
	WHERE s.total_cost != t.total_cost OR s.quantity != t.quantity)
);

