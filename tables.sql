-- Create users table
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    role VARCHAR(20) DEFAULT 'user'
);

-- Create doctors table
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    license_number VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15)
);

-- Create categories table
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_category_id INT REFERENCES categories(category_id) ON DELETE SET NULL
);
INSERT INTO categories (name) VALUES
('Pain Relievers'),
('Antibiotics'),
('Cold and Flu');

-- Create medicines table
CREATE TABLE medicines (
    medicine_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT REFERENCES categories(category_id) ON DELETE CASCADE,
    price DECIMAL(10, 2) NOT NULL,
    manufacturer VARCHAR(100),
    description TEXT,
    availability_status BOOLEAN DEFAULT TRUE
);

-- Create prescriptions table
CREATE TABLE prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctors(doctor_id) ON DELETE SET NULL,
    date_issued DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT
);

INSERT INTO prescriptions (user_id, doctor_id, date_issued, notes) VALUES
(1, 1, '2025-01-10', 'Take one pill daily after meals.'),
(2, 2, '2025-01-11', 'Apply ointment twice daily.'),
(3, 3, '2025-01-12', 'For fever and pain relief.'),
(4, NULL, '2025-01-13', 'Consult for further treatment.');


-- Create reviews table
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comments TEXT
);

INSERT INTO reviews (user_id, medicine_id, rating, comments) VALUES
(1, 7, 5, 'Very effective pain reliever.'),
(2, 8, 4, 'Worked well, but had mild side effects.'),
(3, 9, 3, 'Average relief for cold symptoms.'),
(4, 9, 5, 'Best fever reducer I have used.');

SELECT * FROM medicines;

-- Create orders table
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    order_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_address TEXT,
    payment_status VARCHAR(20) DEFAULT 'pending',
    total_cost DECIMAL(10, 2) NOT NULL
);


INSERT INTO orders (user_id, order_date, delivery_address, payment_status, total_cost) VALUES
(1, '2025-01-10 14:30:00', '123 Main St', 'paid', 20.97),
(2, '2025-01-11 15:45:00', '456 Elm St', 'pending', 12.49),
(3, '2025-01-12 10:15:00', '789 Oak St', 'paid', 18.98),
(4, '2025-01-13 16:20:00', '101 Pine St', 'paid', 9.98);


-- Create order_details table
CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    medicine_id INT REFERENCES medicines(medicine_id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

INSERT INTO order_details (order_id, medicine_id, quantity, unit_price) VALUES
(1, 7, 2, 5.99),
(1, 8, 1, 6.99),
(2, 9, 1, 12.49),
(3, 7, 2, 4.99),
(4, 1, 1, 5.99);


-- Create payments table
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(20) DEFAULT 'pending'
);

INSERT INTO payments (order_id, payment_method, payment_date, payment_status) VALUES
(1, 'credit_card', '2025-01-10 14:40:00', 'completed'),
(3, 'paypal', '2025-01-12 10:25:00', 'completed'),
(4, 'cash', '2025-01-13 16:30:00', 'completed');
