USE ecommerce_project;

-- =====================================================
-- Ecommerce Analytics SQL Project
-- =====================================================

-- 1. Company Total Revenue
select
sum(quantity * price_per_unit) as total_revenue
from orderdetails;

-- 2. Monthly Revenue Trend
select
year(o.order_date) as year,
month(o.order_date) as month,
sum(quantity * price_per_unit) as monthly_revenue
from orders as o
join orderdetails as od
on o.order_id = od.order_id
group by year, month
order by year, month;

-- 3. Top 5 Products by Revenue
select
p.name,
sum(quantity * price_per_unit) as revenue
from orders as o
join orderdetails as od
on o.order_id = od.order_id
join products as p
on od.product_id = p.product_id
group by p.name
order by revenue desc
limit 5;


-- 4. Top 5 Customers by Spending
select 
c.name,
sum(od.quantity * od.price_per_unit) as total_spending
from customers as c
join orders as o
on c.customer_id = o.customer_id
join orderdetails as od
on o.order_id = od.order_id
group by c.name
order by total_spending desc 
limit 5;

-- 5. Repeat vs One-Time Customers
with base as(
select
c.customer_id,
count(o.order_id) as order_count
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by c.customer_id
)
select
case
when order_count =1 then 'One-Time'
else 'repeat' end as customer_type,
count(*) as customer_count
from base
group by 
customer_type;

-- 6. Best Performing City
select
c.location,
sum(od.quantity * od.price_per_unit) as city_revenue
from customers as c
join orders as o
on c.customer_id = o.customer_id
join orderdetails as od
on o.order_id = od.order_id
group by c.location
order by city_revenue desc;

-- 7. Customer Lifetime Value (CLV)
with base as(
select
c.customer_id,
sum(od.quantity * od.price_per_unit) as total_spent
from customers as c
join orders as o
on c.customer_id = o.customer_id
join orderdetails as od
on o.order_id = od.order_id
group by c.customer_id
)
select
avg(total_spent) as avg_customer_value
from base;

-- 8. Monthly Growth Rate
with base as(
select
year(o.order_date) as year,
month(o.order_date) as month,
sum(od.quantity * od.price_per_unit) as revenue
from orders as o
join orderdetails as od
on o.order_id = od.order_id
group by year , month
)
select
year,
month,
revenue,
lag(revenue) over(order by year,month) as prev_month,
round(
100*
(revenue - lag(revenue) over(order by year,month))
/
lag(revenue) over(order by year,month)
,2) as growth_percent
from base;

-- 9. Revenue Concentration (Pareto Analysis)
with base as(
select
c.customer_id,
sum(od.quantity * price_per_unit) as total_revenue
from customers as c
join orders as o
on c.customer_id = o.customer_id
join orderdetails as od
group by c.customer_id
),
bucketing as(
select
*,
ntile(5) over (order by total_revenue) as bucket
from base
)
select
bucket,
sum(total_revenue) as bucket_revenue
from bucketing
group by bucket;

-- 10. Order Frequency Analysis
with base as(
select
customer_id,
count(order_id) as total_orders
from orders
group by customer_id
)
select
round(avg(total_orders),2) as avg_orders
from base;