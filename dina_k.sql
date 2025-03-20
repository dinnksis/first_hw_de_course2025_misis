
--№1
SELECT category_name, 
ROUND(AVG (total_price),2)  AS avg_order_amount 
FROM (SELECT categories.name as category_name ,
SUM(quantity*price) as total_price, created_at FROM categories 
FULL JOIN products ON categories.id=products.category_id
FULL JOIN order_items ON order_items.product_id=products.id
FULL JOIN  orders ON orders.id=order_items.order_id
WHERE (created_at<'2023-04-01' AND created_at>='2023-03-01')
GROUP BY orders.id, categories.name
)
GROUP BY category_name


--№2
SELECT name AS user_name, sum(amount) AS total_spent, ROW_NUMBER() OVER (ORDER BY sum(amount) DESC) as user_rank
FROM users 
FULL JOIN orders ON users.id=orders.user_id 
FULL JOIN payments ON payments.order_id=orders.id
WHERE status='Оплачен'
GROUP BY user_name
ORDER BY total_spent DESC
LIMIT 3


--№3
SELECT TO_CHAR (created_at,'YYYY-MM') as date, COUNT(orders.id) AS total_orders , SUM(amount) as total_payments
FROM payments
FULL JOIN orders ON orders.id=payments.order_id 
GROUP BY date 
ORDER BY date

--№4

SELECT name, SUM(quantity) AS total_sold, ROUND((SUM(quantity)*100.0/(SELECT SUM(quantity) FROM order_items)),2) AS sales_percantage
FROM products 
FULL JOIN order_items ON order_items.product_id=products.id
GROUP BY name
ORDER BY total_sold DESC
LIMIT 5


--№5
SELECT name AS user_name, SUM(amount) AS total_spent FROM orders
FULL JOIN payments ON orders.id=payments.order_id 
FULL JOIN users ON users.id=orders.user_id
WHERE status='Оплачен'
GROUP BY user_name
HAVING (SUM(amount) > 
(SELECT AVG(amount) FROM orders
FULL JOIN payments ON orders.id=payments.order_id 
WHERE status='Оплачен'))
ORDER BY total_spent DESC

--выводится на 1 строчку больше(у меня получилось что средняя по всем заказам оплаченным около 36K, ф у анны 46)

--№6
SELECT categories.name AS category_name , products.name AS product_name, SUM(quantity)  AS total_sold
FROM categories 
FULL JOIN products ON products.category_id=categories.id 
FULL JOIN order_items ON products.id=order_items.product_id
GROUP BY categories.name,products.id
ORDER BY category_name,total_sold DESC, product_name DESC 
 


--№7
SELECT date AS month,category_name, total_revenue
FROM (SELECT TO_CHAR(created_at,'YYYY-MM') as date, categories.name AS category_name, 
SUM(quantity*price) AS total_revenue ,RANK() OVER (PARTITION BY TO_CHAR(created_at,'YYYY-MM') ORDER BY SUM(quantity*price) DESC) 
FROM orders
FULL JOIN order_items ON orders.id=order_items.order_id 
FULL JOIN products ON order_items.product_id=products.id
FULL JOIN categories ON products.category_id=categories.id
GROUP BY categories.name,date
ORDER BY date)
WHERE (rank=1)


--№8
SELECT TO_CHAR(payment_date,'YYYY-MM')  AS month, SUM (quantity*price) AS monthly_payments,
SUM(SUM (quantity*price)) OVER (ORDER BY TO_CHAR(payment_date,'YYYY-MM') ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_payments
FROM payments FULL JOIN orders ON payments.order_id=orders.id
FULL JOIN order_items ON orders.id=order_items.order_id
FULL JOIN products ON products.id=order_items.product_id
WHERE (TO_CHAR(payment_date,'YYYY-MM') IS NOT NULL)
GROUP BY month
ORDER BY month
