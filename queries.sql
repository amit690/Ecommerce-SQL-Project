-- ============================================
-- QUERIES.SQL — E-Commerce Analytics Project
-- ============================================


-- 1. List sellers and their products
SELECT 
    s.seller_name, 
    p.product_name, 
    p.category
FROM Sellers s
JOIN Products p 
    ON s.seller_id = p.seller_id;



-- 2. Products with discount and final price (with ranking)
SELECT 
    p.product_name, 
    p.price, 
    o.discount_percent,
    (p.price - (p.price * o.discount_percent / 100)) AS final_price,
    RANK() OVER (ORDER BY o.discount_percent DESC) AS discount_rank,
    p.category
FROM Products p
JOIN Offers o 
    ON p.product_id = o.product_id;



-- 3. Count of offers per category + ranking
SELECT
    p.category,
    COUNT(o.offer_id) AS total_offers,
    RANK() OVER (ORDER BY COUNT(o.offer_id) DESC) AS offer_rank
FROM Products p
JOIN Offers o 
    ON p.product_id = o.product_id
GROUP BY p.category;



-- 4. Product ranking by total orders + offer information
SELECT 
    p.product_name,
    SUM(o.quantity) AS total_orders,
    RANK() OVER (ORDER BY SUM(o.quantity) DESC) AS product_rank,
    offr.offer_id
FROM Products p 
JOIN Orders o 
    ON p.product_id = o.product_id
LEFT JOIN Offers offr 
    ON p.product_id = offr.product_id
GROUP BY 
    p.product_id,
    p.product_name,
    offr.offer_id;




-- 5. Top-selling category
SELECT 
    p.category, 
    SUM(o.quantity) AS total_quantity
FROM Orders o
JOIN Products p 
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity DESC
LIMIT 1;



-- 6. Category ranking by revenue generated
SELECT 
    p.category,
    SUM(p.price * o.quantity) AS revenue_generated,
    RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS category_rank
FROM Orders o
JOIN Products p 
    ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_generated DESC;



-- 7. Seller ranking by revenue and rating
WITH seller_revenue AS (
    SELECT 
        s.seller_id,
        s.seller_name,
        s.rating,
        SUM(p.price * o.quantity) AS revenue
    FROM Sellers s
    JOIN Products p 
        ON s.seller_id = p.seller_id
    JOIN Orders o 
        ON o.product_id = p.product_id
    GROUP BY 
        s.seller_id, 
        s.seller_name, 
        s.rating
)

SELECT
    seller_name,
    revenue,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    rating,
    RANK() OVER (ORDER BY rating DESC) AS rating_rank
FROM seller_revenue
ORDER BY revenue DESC
LIMIT 10;



-- 8. Customer ranking based on total spending + order count
SELECT 
    c.name, 
    SUM(p.price * o.quantity) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS customer_rank,
    COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o 
    ON c.customer_id = o.customer_id
JOIN Products p 
    ON o.product_id = p.product_id
GROUP BY 
    c.customer_id, 
    c.name
ORDER BY total_spent DESC;
