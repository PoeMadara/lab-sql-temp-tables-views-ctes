-- First, create a view that summarizes rental information for each customer.
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

DROP VIEW IF EXISTS customer_rental_summary;

CREATE VIEW customer_rental_summary AS
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    c.email, 
    COALESCE(COUNT(r.rental_id), 0) AS rental_count  -- Total number of rentals
FROM 
    customer AS c
LEFT JOIN 
    rental AS r ON c.customer_id = r.customer_id  -- Include customers with zero rentals
GROUP BY 
    c.customer_id;  -- Grouping by customer ID to count rentals

SELECT * FROM customer_rental_summary;
    
-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table 
-- and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT 
    crs.customer_id, 
    SUM(p.amount) AS total_paid  -- Total amount paid by each customer
FROM 
    customer_rental_summary AS crs
JOIN 
    payment AS p ON crs.customer_id = p.customer_id
GROUP BY 
    crs.customer_id;

SELECT * FROM customer_payment_summary;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
-- 
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid, and average_payment_per_rental. 
-- This last column is a derived column from total_paid and rental_count.
WITH customer_summary_cte AS (
    SELECT 
        crs.customer_name, 
        crs.email, 
        crs.rental_count,  -- Rental count from the view
        cps.total_paid  -- Total amount paid from the temporary table
    FROM 
        customer_rental_summary AS crs
    JOIN 
        customer_payment_summary AS cps ON crs.customer_id = cps.customer_id
)
-- Final query to generate the customer summary report
SELECT 
    csc.customer_name, 
    csc.email, 
    csc.rental_count, 
    csc.total_paid,  -- Total amount paid by the customer
    ROUND(csc.total_paid / csc.rental_count, 2) AS average_payment_per_rental  -- Derived column: average payment per rental
FROM 
    customer_summary_cte AS csc;
