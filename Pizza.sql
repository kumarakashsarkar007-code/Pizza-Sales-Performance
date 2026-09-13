-- 1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

    
-- 2. Determine the average price of a pizza for each size across all categories.
SELECT 
    size, ROUND(AVG(price), 2) AS avg_price
FROM
    pizzas
GROUP BY size
ORDER BY avg_price ASC;


-- 3. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(d.quantity * p.price), 2) AS Total_Sales
FROM
    order_details AS d
        JOIN
    pizzas AS p ON d.pizza_id = p.pizza_id;
    
    
-- 4.Find the average order value (AOV) across all orders.
SELECT 
    ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id),
            2) AS avg_order_value
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;
    
    
-- 5. Identify the highest-priced pizza.
SELECT 
    p.pizza_id, t.name, p.price
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;


-- 6. Identify the most common pizza size ordered.
SELECT 
    p.size, SUM(d.quantity) AS Most_ordered
FROM
    pizzas AS p
        JOIN
    order_details AS d ON p.pizza_id = d.pizza_id
GROUP BY p.size , d.quantity
ORDER BY Most_ordered DESC
LIMIT 1;


-- 7.Calculate the total revenue generated on weekends (Saturday and Sunday).
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS weekend_revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
WHERE
    DAYNAME(o.order_date) IN ('Saturday' , 'Sunday');


-- 8. Find the top 3 days of the year with the highest total revenue.
SELECT 
    o.order_date,
    ROUND(SUM(od.quantity * p.price), 2) AS daily_revenue
FROM
    orders o
        JOIN
    order_details od ON o.order_id = od.order_id
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.order_date
ORDER BY daily_revenue DESC
LIMIT 3;


-- 9. Identify the least ordered pizza type by total quantity sold.
SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity ASC
LIMIT 1;


-- 10. Retrieve the total number of pizzas sold for each size within the 'Chicken' category.
SELECT 
    p.size, SUM(od.quantity) AS total_pizzas_sold
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE
    pt.category = 'Chicken'
GROUP BY p.size
ORDER BY total_pizzas_sold DESC;


-- 11. List all pizza types that have generated more than $30,000 in total revenue.
SELECT 
    pt.name,
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
HAVING total_revenue > 30000
ORDER BY total_revenue DESC;


-- 12. List the top 5 most ordered pizza types along with their quantities.
SELECT 
    t.name, COUNT(o.quantity) AS Total_Quantity
FROM
    pizza_types AS t
        JOIN
    pizzas AS d ON t.pizza_type_id = d.pizza_type_id
        JOIN
    Order_details AS o ON o.pizza_id = d.pizza_id
GROUP BY t.name
ORDER BY Total_Quantity DESC
LIMIT 5;


-- 13. the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    T.Category, SUM(d.quantity) AS Total_quantity
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS d ON d.pizza_id = p.pizza_id
GROUP BY t.category
ORDER BY Total_quantity DESC;


-- 14. Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Order_count
FROM
    orders
GROUP BY HOUR;


-- 15.Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name) AS Total_Pizzas
FROM
    pizza_types
GROUP BY category;


-- 16. Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Total_quantity), 0) AS Avg_quantity
FROM
    ((SELECT 
        o.order_date, SUM(d.quantity) AS Total_quantity
    FROM
        Orders AS o
    JOIN order_details AS d ON o.order_id = d.order_id
    GROUP BY Order_date)) AS Daily_orders;
    
    
-- 17. Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    t.name, ROUND(SUM(d.quantity * p.price), 0) AS Revenue
FROM
    Pizza_types AS T
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS d ON d.pizza_id = p.pizza_id
GROUP BY t.name
ORDER BY Revenue DESC
LIMIT 3;

-- 18. Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    t.category,
    ROUND(SUM(d.quantity * p.price) / (SELECT 
                    SUM(d2.quantity * p2.price)
                FROM
                    order_details AS d2
                        JOIN
                    pizzas AS p2 ON d2.pizza_id = p2.pizza_id) * 100,
            2) AS Revenue_Percentage
FROM
    pizza_types AS t
        JOIN
    pizzas AS p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS d ON d.pizza_id = p.pizza_id
GROUP BY t.category
ORDER BY Revenue_Percentage DESC;


-- 19. Analyze the cumulative revenue generated over time.
Select Order_date, Round(Sum(revenue) over(order by order_date),0) as cum_revenue 
from(
 Select o.order_date, sum(d.quantity * p.price) as revenue
 from order_details as d
 join pizzas as p
 on d.pizza_id = p.pizza_id
 join orders as o 
 on o.order_id = d.order_id
 group by o.order_date) as Sales;
 
-- 20. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
Select name, revenue from
(SELECT 
    category,
    name,
    revenue,
    RANK() OVER (
        PARTITION BY category 
        ORDER BY revenue DESC
    ) AS RN
FROM (
    SELECT 
        t.category,
        t.name,
        Round(SUM(d.quantity * p.price),0) AS revenue
    FROM pizza_types AS t
    JOIN pizzas AS p
        ON t.pizza_type_id = p.pizza_type_id
    JOIN order_details AS d
        ON d.pizza_id = p.pizza_id
    GROUP BY t.category, t.name
) AS Pizza_Sales ) as b
where rn <=3;

-- 21. Identify the most common pair of pizza categories bought together in a single order.
SELECT 
    pt1.category AS category_1,
    pt2.category AS category_2,
    COUNT(DISTINCT od1.order_id) AS times_bought_together
FROM order_details od1
JOIN order_details od2 ON od1.order_id = od2.order_id AND od1.pizza_id < od2.pizza_id
JOIN pizzas p1 ON od1.pizza_id = p1.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
WHERE pt1.category != pt2.category
GROUP BY pt1.category, pt2.category
ORDER BY times_bought_together DESC
LIMIT 1;