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

-- 4. Sellers rank on revenue
SELECT s.seller_name, SUM(p.price * o.quantity) AS revenue,
    RANK() OVER(ORDER BY SUM(p.price * o.quantity) DESC) AS seller_rank
FROM Sellers s
JOIN Products p ON s.seller_id = p.seller_id
JOIN Orders o ON o.product_id = p.product_id
GROUP BY s.seller_name
ORDER BY revenue DESC
LIMIT 1;

-- 5. Customers rankiing based on  who spents the most money
SELECT c.name, SUM(p.price * o.quantity) AS total_spent,
    RANK() OVER(ORDER BY SUM(p.price * o.quantity) DESC) AS customer_rank
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN Products p ON o.product_id = p.product_id
GROUP BY c.name
ORDER BY total_spent DESC
LIMIT 10;
