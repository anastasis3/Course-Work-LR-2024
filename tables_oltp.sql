CREATE TABLE dim_customers (
    customer_id INT,
    name VARCHAR(100),
    email VARCHAR(100),
    address TEXT,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT '9999-12-31',
    is_current BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (customer_id, start_date)
);

CREATE TABLE dim_products (
    product_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

CREATE TABLE dim_time (
    time_id SERIAL PRIMARY KEY,
    date DATE,
    month INT,
    year INT,
    quarter INT
);

CREATE TABLE fact_reviews (
    review_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES dim_products(product_id),
    customer_id INT,
    customer_start_date DATE,
    time_id INT REFERENCES dim_time(time_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (customer_id, customer_start_date) REFERENCES dim_customers(customer_id, start_date)
);


INSERT INTO dim_customers (customer_id, name, email, address, start_date, end_date, is_current)
VALUES 
(1, 'John Doe', 'john.doe@example.com', '123 Main St', '2023-01-01', '2023-12-31', FALSE),
(1, 'John Doe', 'john.doe@example.com', '456 Elm St', '2024-01-01', NULL, TRUE),
(2, 'Jane Smith', 'jane.smith@example.com', '789 Oak St', '2023-01-01', NULL, TRUE),
(3, 'Alice Johnson', 'alice.johnson@example.com', '101 Pine St', '2023-01-01', NULL, TRUE);


INSERT INTO dim_products (product_id, name, category, price)
VALUES 
(1, 'Ibuprofen', 'Pain Relievers', 5.99),
(2, 'Amoxicillin', 'Antibiotics', 12.49),
(3, 'ColdEase', 'Cold and Flu', 6.99),
(4, 'Acetaminophen', 'Pain Relievers', 4.99);


INSERT INTO dim_time (time_id, date, month, quarter, year)
VALUES 
(1, '2024-01-15', 1, 1, 2024),  
(2, '2024-02-15', 2, 1, 2024),  
(3, '2024-03-15', 3, 1, 2024),  
(4, '2024-04-15', 4, 2, 2024);  


INSERT INTO fact_reviews (product_id, customer_id, time_id, rating)
VALUES 
(1, 1, 1, 5),  -- John Doe reviewed Ibuprofen in January
(2, 2, 2, 4),  -- Jane Smith reviewed Amoxicillin in February
(3, 3, 3, 3),  -- Alice Johnson reviewed ColdEase in March
(4, 1, 4, 5);  -- John Doe reviewed Acetaminophen in April

CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES dim_products(product_id) ON DELETE CASCADE,
    customer_id INT,
    start_date DATE,
    time_id INT REFERENCES dim_time(time_id) ON DELETE CASCADE,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    total_sales DECIMAL(10, 2) NOT NULL CHECK (total_sales >= 0),
    FOREIGN KEY (customer_id, start_date) REFERENCES dim_customers(customer_id, start_date) ON DELETE CASCADE
);
INSERT INTO fact_sales (sale_id, product_id, customer_id, time_id, quantity_sold, total_sales)
VALUES
(1, 1, 1, 1, 10, 59.90),  -- 10 единиц Ibuprofen продано клиенту 1 в январе 2024
(2, 2, 2, 1, 5, 62.45),   -- 5 единиц Amoxicillin продано клиенту 2 в январе 2024
(3, 1, 2, 2, 8, 47.92),   -- 8 единиц Ibuprofen продано клиенту 2 в феврале 2024
(4, 2, 1, 2, 3, 37.47);   -- 3 единицы Amoxicillin продано клиенту 1 в феврале 2024


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

