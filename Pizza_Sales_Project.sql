select DATABASE();
CREATE TABLE pizza_types (
    pizza_type_id INT PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50)
);
DESC pizza_types;
INSERT INTO pizza_types
(pizza_type_id, name, category)
VALUES
(1, 'Margherita', 'Classic'),
(2, 'Pepperoni', 'Classic'),
(3, 'Veggie Supreme', 'Veggie'),
(4, 'Chicken BBQ', 'Chicken');

SELECT * FROM pizza_types;

CREATE TABLE pizzas (
    pizza_id VARCHAR(50) PRIMARY KEY,
    pizza_type_id INT,
    size VARCHAR(10),
    price DECIMAL(10,2),
    FOREIGN KEY (pizza_type_id)
        REFERENCES pizza_types(pizza_type_id)
);

INSERT INTO pizzas
(pizza_id, pizza_type_id, size, price)
VALUES
('P001-S', 1, 'S', 199.00),
('P001-M', 1, 'M', 299.00),
('P001-L', 1, 'L', 399.00),
('P002-S', 2, 'S', 249.00),
('P002-M', 2, 'M', 349.00),
('P003-M', 3, 'M', 329.00),
('P004-L', 4, 'L', 449.00);

SELECT * FROM pizzas;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIMESTAMP
);

INSERT INTO orders
(order_id, date, time)
VALUES
(1, '2026-09-28', '2026-09-28 12:30:00'),
(2, '2026-09-28', '2026-09-28 18:45:00'),
(3, '2026-09-29', '2026-09-29 20:15:00');

SELECT * FROM orders;


CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(50),
    quantity INT,
    
    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
        
    FOREIGN KEY (pizza_id)
        REFERENCES pizzas(pizza_id)
);

INSERT INTO order_details
(order_details_id, order_id, pizza_id, quantity)
VALUES
(1, 1, 'P001-M', 2),
(2, 1, 'P002-S', 1),
(3, 2, 'P003-M', 2),
(4, 3, 'P004-L', 1);

SELECT * FROM order_details;

SHOW TABLES;

select count(order_id) as total_orders from orders;



select sum(p.price * od.quantity) as total_revenue from order_details od JOIN pizzas p on p.pizza_id=od.pizza_id;

select * from pizzas order by price  DESC limit 2;

select p.size , sum(od.quantity) as total_quantity from order_details od JOIN pizzas p ON p.pizza_id=od.pizza_id group by p.size order by total_quantity DESC limit 1;

select pt.name , sum(od.quantity) as total_quantity from order_details od join pizzas p on p.pizza_id=od.pizza_id join pizza_types pt on p.pizza_type_id=pt.pizza_type_id Group by pt.name order by total_quantity DESC limit 5;

select pt.name, pt.category , sum(od.quantity) as total_quantity from pizza_types pt join pizzas p on p.pizza_type_id=pt.pizza_type_id join order_details od on p.pizza_id=od.pizza_id group by pt.category , pt.name;

select HOUR(time) as order_hour, count(*) as total_orders from orders group by HOUR(time) order by order_hour;

select pt.name , sum(od.quantity* p.price) as total_revenue from order_details od join pizzas p on p.pizza_id=od.pizza_id join pizza_types pt on p.pizza_type_id=pt.pizza_type_id Group by pt.name order by total_revenue DESC limit 3;

select avg(od.quantity * p.price) as average_count from pizzas p  JOIN order_details od on od.pizza_id=p.pizza_id join orders o on o.order_id=od.order_id group by date;

SELECT o.date,
       SUM(od.quantity) AS pizzas_ordered
FROM orders o
JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY o.date;

SELECT 
    pt.name,
    SUM(od.quantity * p.price) AS revenue,
    SUM(od.quantity * p.price) /
    (SELECT SUM(od2.quantity * p2.price)
     FROM order_details od2
     JOIN pizzas p2
     ON od2.pizza_id = p2.pizza_id) * 100 AS percentage
FROM order_details od
JOIN pizzas p
ON od.pizza_id = p.pizza_id
JOIN pizza_types pt
ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name;


SELECT 
    o.date,
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) 
        OVER (ORDER BY o.date) AS cumulative_revenue
FROM orders o
JOIN order_details od
    ON o.order_id = od.order_id
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;


WITH pizza_revenue AS (
    SELECT
        pt.category,
        pt.name,
        SUM(od.quantity * p.price) AS revenue
    FROM order_details od
    JOIN pizzas p
        ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt
        ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
),
ranked_pizzas AS (
    SELECT
        category,
        name,
        revenue,
        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS rnk
    FROM pizza_revenue
)
SELECT category, name, revenue
FROM ranked_pizzas
WHERE rnk <= 3
ORDER BY category, revenue DESC;
