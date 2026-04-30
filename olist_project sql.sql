create database olist_database;
use olsit_databse;
select * from olist_databse.olist_customers;
select * from olist_databse.olist_orders_dataset;
select * from olist_databse.olist_order_items_dataset;
select * from olist_databse.olist_products;
select * from olist_databse.product_category_name_translation;
select * from olist_databse.olist_geolocation;
select * from olist_database.olist_order_reviews;
select * from olist_databse.olist_order_payments_dataset;
select * from olist_databse.olist_sellers_dataset;
show tables;
select count(*) from olist_orders_dataset;
select count(*) from olist_customers;
select count(*) from olist_order_items_dataset;
select count(*) from olist_geolocation;
select count(*) from olist_order_payments_dataset;
select count(*) from olist_order_reviews;
select count(*) from olist_products;
select count(*) from olist_sellers_dataset;
select count(*) from product_category_name_translation;
select * from olist_orders_dataset limit 5;
select * from  olist_customers limit 5;
select * from order_items limit 5;
select * from olist_geolocation limit 5;
select * from olist_order_payments_dataset limit 5;
select * from olist_order_reviews limit 5;
select * from olist_products limit 5;
select * from olist_sellers_dataset limit 5;
select * from product_category_name_translation limit 5;
describe olist_orders_dataset;
-- 1st kpi weekday vs weekend --
SELECT 
    CASE 
        WHEN DAYOFWEEK(o.order_purchase_timestamp) IN (1,7) 
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_payment
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
GROUP BY day_type;
-----------------
-- 2nd kpi orders with review score =5 and payment=credit card--
SELECT 
    COUNT(DISTINCT r.order_id) AS total_orders
FROM olist_order_reviews r
JOIN olist_order_payments_dataset p 
ON r.order_id = p.order_id
WHERE r.review_score = 5
AND p.payment_type = 'credit_card';

-- 3rd kpi average delivery days for pet shop products ---
SELECT 
    o.order_id,
    pr.product_category_name,
    DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    ) AS delivery_days
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
JOIN olist_products pr ON oi.product_id = pr.product_id
WHERE pr.product_category_name = 'pet_shop'
AND o.order_delivered_customer_date IS NOT NULL
limit  5;


------------------------
-- 4th kpi average price nd payment value ---

SELECT 
    ROUND(AVG(oi.price), 2) AS avg_product_price,
    ROUND(AVG(p.payment_value), 2) AS avg_payment_value
FROM olist_customers c
JOIN olist_orders_dataset o 
    ON c.customer_id = o.customer_id
JOIN olist_order_items_dataset oi 
    ON o.order_id = oi.order_id
JOIN olist_order_payments_dataset p 
    ON o.order_id = p.order_id
WHERE LOWER(c.customer_city) = 'sao paulo';
-----------------------

-- 5th kpi shipping days vs review score relationship --

select 
    r.review_score,
    ROUND(AVG(
        DATEDIFF(o.order_delivered_customer_date,
                 o.order_purchase_timestamp)
    ), 2) AS avg_shipping_days
FROM olist_orders_dataset o
JOIN olist_order_reviews r
    ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY r.review_score
ORDER BY r.review_score;
---- END---
