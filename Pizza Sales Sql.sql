Create database Pizzahut;
use Pizzahut;
select * from pizzas;

create table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

select * from orders_details;

-- Begineer level 

-- Retrieve the total number of orders placed.
select count(order_id) as total_order 
from orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_Revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;
    
    -- Identify the highest-priced pizza.
   select pizza_types.name ,pizzas.price
   from pizza_types join pizzas
   on pizza_types.pizza_type_id=pizzas.pizza_type_id
   order by pizzas.price desc limit 1;
   
 
 -- Identify the most common pizza size ordered.
select pizzas.size,count(orders_details.order_details_id) as order_count
from pizzas join orders_details
on pizzas.pizza_id=orders_details.pizza_id
group by pizzas.size
order by order_count desc limit 1;


-- List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name,sum(orders_details.quantity) as total_quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by total_quantity desc limit 5;

-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category ,sum(orders_details.quantity)as Total_quantity
from pizza_types  join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details 
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category
order by Total_quantity desc ;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour;



-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(Total_quantity), 0) AS avg_pizzas_orderd_per_day
FROM
    (SELECT 
        orders.order_date,
            SUM(orders_details.quantity) AS Total_quantity
    FROM
        orders
    JOIN orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name , round(sum(orders_details.quantity * pizzas.price),2) as total_revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join orders_details 
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.name
order by total_revenue desc limit 3;


-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,
concat (round(sum(orders_details.quantity * pizzas.price) / (SELECT 
ROUND(SUM(orders_details.quantity * pizzas.price),2) AS Total_Revenue
FROM orders_details JOIN pizzas
 ON orders_details.pizza_id = pizzas.pizza_id)*100,2),"%") as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category 
order by revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date, 
round(sum(Total_revenue) over (order by order_date),2) as cum_revenue
from(
select orders.order_date,
sum(orders_details.quantity * pizzas .price) as Total_revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name , Total_revenue
from
(select category,name,Total_revenue,
rank() over(partition by category order by Total_revenue desc) as rnk
from
(select pizza_types.category,pizza_types.name,
sum(orders_details.quantity * pizzas .price) as Total_revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id=pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rnk<=3;





