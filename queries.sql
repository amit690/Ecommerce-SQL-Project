-- QUERIES.SQL

-- 1. List sellers and their products
SELECT s.seller_name, p.product_name, p.category
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id;

-- 2. Products with discount and final price
SELECT p.product_name, p.price, o.discount_percent,
       (p.price - (p.price * o.discount_percent/100)) AS final_price
FROM Products p
JOIN Offers o ON p.product_id = o.product_id;

-- 3. Top-selling category
SELECT p.category, SUM(o.quantity) AS total_quantity
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY total_quantity DESC
LIMIT 1;

-- 4. Top revenue-generating categories
SELECT 
    p.category,
    SUM(p.price * o.quantity) AS revenue_generated,
    RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS category_rank
FROM Orders o
JOIN Products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY revenue_generated DESC;


-- 5. Seller revenue & rating ranking
WITH seller_revenue AS (
    SELECT 
        s.seller_id,
        s.seller_name,
        s.rating,
        SUM(p.price * o.quantity) AS revenue
    FROM Sellers s
    JOIN Products p ON s.seller_id = p.seller_id
    JOIN Orders o ON o.product_id = p.product_id
    GROUP BY s.seller_id, s.seller_name, s.rating
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




-- 6. Customer ranking based on total spending
SELECT 
    c.name, 
    SUM(p.price * o.quantity) AS total_spent,
    RANK() OVER (ORDER BY SUM(p.price * o.quantity) DESC) AS customer_rank,
    COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.name
ORDER BY total_spent DESC;
