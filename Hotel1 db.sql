-- Create database
CREATE DATABASE hotel_db;
\c hotel_db;

-- Drop tables if they exist to allow rerun
DROP TABLE IF EXISTS guest_services;
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS guests;

-- Create tables
CREATE TABLE guests (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    check_in_date DATE,
    check_out_date DATE
);

CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    number VARCHAR(10) NOT NULL,
    type VARCHAR(50),
    price_per_night NUMERIC(8,2) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    guest_id INT REFERENCES guests(id) ON DELETE CASCADE,
    room_id INT REFERENCES rooms(id) ON DELETE CASCADE,
    booking_date DATE NOT NULL,
    nights INT NOT NULL,
    total_price NUMERIC(10,2) NOT NULL
);

CREATE TABLE services (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(8,2) NOT NULL
);

CREATE TABLE guest_services (
    id SERIAL PRIMARY KEY,
    guest_id INT REFERENCES guests(id) ON DELETE CASCADE,
    service_id INT REFERENCES services(id) ON DELETE CASCADE,
    date_used DATE NOT NULL
);

--  SQL Data Types & Basic SELECT

-- Insert at least 5 guests
INSERT INTO guests (name, email, phone, check_in_date, check_out_date) VALUES
('Alice mods', 'alice@mods.gmail.com', '123-456-7890', '2025-05-01', '2025-05-05'),
('Bob Smith', 'bob@smithgmail.com', '234-567-8901', '2025-05-02', '2025-05-06'),
('Carol White', 'carol@white.gmail.com', '345-678-9012', '2025-05-03', '2025-05-07'),
('David Alex', 'david@alex@gmail.com', '456-789-0123', '2025-05-04', '2025-05-08'),
('Eva mods', 'eva@mods.com', '567-890-1234', '2025-05-05', '2025-05-09');

-- Insert 3 rooms
INSERT INTO rooms (number, type, price_per_night, is_available) VALUES
('101', 'Single', 80.00, TRUE),
('102', 'Double', 120.00, TRUE),
('201', 'Suite', 200.00, TRUE);

-- Insert 3 services
INSERT INTO services (name, price) VALUES
('Spa', 50.00),
('Breakfast', 15.00),
('Airport Pickup', 30.00);

-- Select guest names and phone numbers
SELECT name, phone FROM guests;

--  Modifying Data

-- Insert a new guest
INSERT INTO guests (name, email, phone, check_in_date, check_out_date) VALUES
('Frank Ocean', 'frank@example.com', '678-901-2345', '2024-05-10', '2024-05-15');

-- Insert a new booking
INSERT INTO bookings (guest_id, room_id, booking_date, nights, total_price) VALUES
((SELECT id FROM guests WHERE email = 'frank@muhoro.gmail.com'),
 (SELECT id FROM rooms WHERE number = '101'),
 '2025-05-10', 5, 80.00 * 5);

-- Update a guest’s check-out date
UPDATE guests
SET check_out_date = '2025-05-20'
WHERE email = 'alice@mods.gmail.com';

-- Delete a guest who checked out more than 1 month ago
DELETE FROM guests
WHERE check_out_date < CURRENT_DATE - INTERVAL '1 month';

-- 3️ Filtering & Grouping

-- Find guests who booked after a specific date
SELECT g.*
FROM guests g
JOIN bookings b ON g.id = b.guest_id
WHERE b.booking_date > '2025-05-01';

-- Group bookings by room_id and show average nights stayed
SELECT room_id, AVG(nights) AS avg_nights
FROM bookings
GROUP BY room_id;

-- 4️⃣ Joins & Subqueries

-- List guests and the rooms they’re staying in (JOIN)
SELECT g.name AS guest_name, r.number AS room_number
FROM guests g
JOIN bookings b ON g.id = b.guest_id
JOIN rooms r ON b.room_id = r.id;

-- Subquery to find guests who have used more than 2 services
SELECT g.*
FROM guests g
WHERE (SELECT COUNT(*) FROM guest_services gs WHERE gs.guest_id = g.id) > 2;

-- 5️⃣ Views & Pagination

-- Create a view showing guest name, room number, total price
CREATE OR REPLACE VIEW guest_booking_summary AS
SELECT g.name AS guest_name, r.number AS room_number, b.total_price
FROM bookings b
JOIN guests g ON b.guest_id = g.id
JOIN rooms r ON b.room_id = r.id;

-- Paginate the view to show 3 bookings at a time (using LIMIT and OFFSET)
-- Example: To get first 3 rows
SELECT * FROM guest_booking_summary
LIMIT 3 OFFSET 0;

-- 6 Sorting & Limiting

-- Sort guests by check-in date (descending)
SELECT * FROM guests
ORDER BY check_in_date DESC;

-- Limit results to the 5 most recent guests
SELECT * FROM guests
ORDER BY check_in_date DESC
LIMIT 5;

--  Constraints & Expressions, SET Operators, CTEs

-- UNIQUE constraint on email already added in table definition

-- Use CASE to categorize rooms (Economy, Business, Luxury) based on price_per_night
SELECT number, price_per_night,
CASE
    WHEN price_per_night < 100 THEN 'Economy'
    WHEN price_per_night BETWEEN 100 AND 150 THEN 'Business'
    ELSE 'Luxury'
END AS category
FROM rooms;

-- Use a CTE to find rooms booked more than 3 times
WITH room_booking_counts AS (
    SELECT room_id, COUNT(*) AS booking_count
    FROM bookings
    GROUP BY room_id
)
SELECT r.number, rbc.booking_count
FROM rooms r
JOIN room_booking_counts rbc ON r.id = rbc.room_id
WHERE rbc.booking_count > 3;

-- Use UNION to combine guests who booked a room or used a spa service
SELECT DISTINCT g.id, g.name, g.email
FROM guests g
JOIN bookings b ON g.id = b.guest_id

UNION

SELECT DISTINCT g.id, g.name, g.email
FROM guests g
JOIN guest_services gs ON g.id = gs.guest_id
JOIN services s ON gs.service_id = s.id
WHERE s.name = 'Spa';

--  Triggers & Indexes

-- Create a table to log room availability updates
CREATE TABLE room_availability_log (
    id SERIAL PRIMARY KEY,
    room_id INT,
    old_availability BOOLEAN,
    new_availability BOOLEAN,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create trigger function to log updates to rooms availability
CREATE OR REPLACE FUNCTION log_room_availability_update()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.is_available IS DISTINCT FROM NEW.is_available THEN
        INSERT INTO room_availability_log(room_id, old_availability, new_availability)
        VALUES (OLD.id, OLD.is_available, NEW.is_available);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on rooms table
CREATE TRIGGER trg_log_room_availability
AFTER UPDATE OF is_available ON rooms
FOR EACH ROW
EXECUTE FUNCTION log_room_availability_update();

-- Create an index on bookings.booking_date for faster lookups
CREATE INDEX idx_booking_date ON bookings(booking_date);

--  User Defined Functions & Stored Procedures

-- Function to calculate total spend for a guest
CREATE OR REPLACE FUNCTION total_spend(guest_id INT)
RETURNS NUMERIC AS $$
DECLARE
    spend NUMERIC;
BEGIN
    SELECT COALESCE(SUM(total_price), 0) INTO spend
    FROM bookings
    WHERE guest_id = total_spend.guest_id;
    RETURN spend;
END;
$$ LANGUAGE plpgsql;

-- Stored procedure to add a booking
CREATE OR REPLACE PROCEDURE add_booking(
    p_guest_id INT,
    p_room_id INT,
    p_booking_date DATE,
    p_nights INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    p_total_price NUMERIC;
BEGIN
    SELECT price_per_night * p_nights INTO p_total_price FROM rooms WHERE id = p_room_id;
    INSERT INTO bookings (guest_id, room_id, booking_date, nights, total_price)
    VALUES (p_guest_id, p_room_id, p_booking_date, p_nights, p_total_price);
END;
$$;

-- Procedure to check in a new guest and book them into a room
CREATE OR REPLACE PROCEDURE check_in_guest(
    p_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_check_in DATE,
    p_check_out DATE,
    p_room_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    new_guest_id INT;
BEGIN
    INSERT INTO guests (name, email, phone, check_in_date, check_out_date)
    VALUES (p_name, p_email, p_phone, p_check_in, p_check_out)
    RETURNING id INTO new_guest_id;

    PERFORM add_booking(new_guest_id, p_room_id, p_check_in, (p_check_out - p_check_in));

    UPDATE rooms SET is_available = FALSE WHERE id = p_room_id;
END;
$$;


