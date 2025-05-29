-- DROP TABLE IF EXISTS employees;

-- CREATE TABLE employees (
--     id SERIAL PRIMARY KEY,
--     name VARCHAR(100),
--     department_id INT,
--     salary NUMERIC(10,2),
--     is_active BOOLEAN DEFAULT true
-- );

-- INSERT INTO employees (name, department_id, salary)
-- VALUES 
-- ('Alex', 1, 50000),
-- ('Muliro', 1, 60000),
-- ('Dan', 2, 55000),
-- ('Earl', 2, 62000),
-- ('Eve', 3, 70000);

-- SELECT * FROM employees;

-- -- -- Procedure 1
-- CREATE OR REPLACE PROCEDURE update_salary(emp_id INTEGER, new_salary NUMERIC(10, 2))
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE employees
--     SET salary = new_salary
--     WHERE id = emp_id;
-- END;
-- $$;

-- CALL update_salary(2, 80000);
-- SELECT * FROM employees WHERE id = 2;

-- -- Procedure 2
-- -- Drop the procedure if it exists
-- DROP PROCEDURE IF EXISTS get_department_count;

-- -- Create the procedure
-- CREATE OR REPLACE PROCEDURE get_department_count(IN dept_id INT, OUT total INT)
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     SELECT COUNT(*) INTO total
--     FROM employees
--     WHERE department_id = dept_id;
-- END;
-- $$;

-- -- Use DO block to capture and display the OUT parameter
-- DO $$
-- DECLARE
--     dept_total INT;
-- BEGIN
--     CALL get_department_count(1, dept_total);
--     RAISE NOTICE 'Total employees in department 1: %', dept_total;
-- END;
-- $$;




-- -- Procedure 3
-- -- Drop if it exists
-- DROP PROCEDURE IF EXISTS update_salary;

-- -- Create procedure
-- CREATE OR REPLACE PROCEDURE update_salary(emp_id INTEGER, new_salary NUMERIC(10, 2))
-- LANGUAGE plpgsql
-- AS $$
-- BEGIN
--     UPDATE employees
--     SET salary = new_salary
--     WHERE id = emp_id;
-- END;
-- $$;

-- -- -- Test it
-- CALL update_salary(2, 80000);
-- SELECT * FROM employees;

FUNCTIONS
-- UPDATE employees
-- SET date_of_birth = CASE id
--     WHEN 1 THEN TO_DATE('1990-01-15', 'YYYY-MM-DD')
--     WHEN 2 THEN TO_DATE('1985-05-20', 'YYYY-MM-DD')
--     WHEN 3 THEN TO_DATE('1992-07-12', 'YYYY-MM-DD')
--     WHEN 4 THEN TO_DATE('1993-03-25', 'YYYY-MM-DD')
--     WHEN 5 THEN TO_DATE('1995-11-05', 'YYYY-MM-DD')
-- END;


--SELECT * FROM employees;
-- CREATE OR REPLACE FUNCTION get_age(dob DATE)
-- RETURNS INT AS $$
-- BEGIN
--     RETURN DATE_PART('year', AGE(dob))::INT;
-- END;
-- $$ LANGUAGE plpgsql;

-- $$ 
-- SELECT * FROM employees;

-- SELECT get_age('1990-01-15'); --This will return the age in years for the date of birth '1990-01-15'.
-- CREATE OR REPLACE FUNCTION get_age_in_months(dob DATE) --This function computes the total number of months between the provided date of birth and the current date.
-- RETURNS INT AS $$
-- BEGIN
--     RETURN (DATE_PART('year', AGE(dob)) * 12 + DATE_PART('month', AGE(dob)))::INT;
-- END;
-- $$ LANGUAGE plpgsql;
-- SELECT get_age_in_months('1990-01-15'); --This will return the total number of months since January 15, 1990, up to the current date.
-- SELECT * FROM employees;



