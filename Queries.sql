-- ============================================
-- TASK 3: SQL FOR DATA ANALYSIS
-- ============================================

-- 1. BASIC SELECT WITH WHERE AND ORDER BY
SELECT first_name, last_name, email, city, state, region 
FROM customers 
WHERE region = 'West' 
ORDER BY signup_date DESC;

-- 2. GROUP BY WITH AGGREGATE FUNCTIONS
SELECT 
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(oi.quantity * oi.unit_price) AS avg_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.category;

-- 3. INNER JOIN
SELECT 
    o.order_id,
    o.order_date,
    c.first_name,
    c.last_name,
    c.email,
    o.total_amount
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
ORDER BY o.order_date DESC;

-- 4. LEFT JOIN
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id
HAVING COUNT(o.order_id) = 0;

-- 5. SUBQUERY (Top 5 Customers by Spending)
SELECT 
    customer_id,
    first_name,
    last_name,
    total_spent
FROM (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(oi.quantity * oi.unit_price) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) AS customer_spending
ORDER BY total_spent DESC
LIMIT 5;

-- 6. CREATE VIEW
CREATE VIEW monthly_sales AS
SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    AVG(oi.quantity * oi.unit_price) AS avg_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month;

-- 7. USE THE VIEW
SELECT * FROM monthly_sales ORDER BY month;

-- 8. WHERE vs HAVING
SELECT 
    region,
    COUNT(customer_id) AS customer_count,
    AVG(total_spent) AS avg_spending
FROM (
    SELECT 
        c.region,
        c.customer_id,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
    FROM customers c
    LEFT JOIN orders o ON c.customer_id = o.customer_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id
) AS customer_metrics
GROUP BY region
HAVING AVG(total_spent) > 500;
