DROP DATABASE IF EXISTS Diner;
CREATE DATABASE Diner;
USE Diner;

DROP TABLE IF EXISTS Menu;
CREATE TABLE Menu(
product_id INT(2),
product_name VARCHAR(20) DEFAULT NULL,
price INT(3) DEFAULT NULL
);

DROP TABLE IF EXISTS Member;
CREATE TABLE Member(
customer_id VARCHAR(2),
join_date DATE DEFAULT NULL
);

DROP TABLE IF EXISTS Sales;
CREATE TABLE Sales (
customer_id VARCHAR(2),
order_date VARCHAR(20),
product_id INT(2) DEFAULT NULL
);

ALTER TABLE MEMBER
ADD PRIMARY KEY (customer_id);

ALTER TABLE Menu
ADD PRIMARY KEY (product_id);

ALTER TABLE Sales
ADD CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES Member(customer_id),
ADD CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES Menu(product_id);

INSERT INTO Member (customer_id, join_date) VALUES('A','2021-01-07');
INSERT INTO Member(customer_id, join_date) VALUES('B','2021-01-09');
INSERT INTO Member(customer_id, join_date) VALUES('C','2021-01-19');

INSERT INTO Menu (product_id, product_name, price) VALUES(1,'sushi',10);
INSERT INTO Menu (product_id, product_name, price) VALUES(2,'curry',15);
INSERT INTO Menu (product_id, product_name, price) VALUES(3,'ramen',12);


INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-01',1);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-01',2);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-07',2);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-10',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-11',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('A','2021-01-11',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-01-01',2);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-01-02',2);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-01-04',1);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-01-11',1);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-01-16',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('B','2021-02-01',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('C','2021-01-01',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('C','2021-01-01',3);
INSERT INTO Sales(customer_id, order_date,product_id) VALUES('C','2021-01-07',3);

-- What is the total amount each customer spent at the restaurant?
SELECT customer_id, Menu.product_id, product_name, sumprice
FROM Menu
LEFT JOIN Sales ON `Menu`.`product_id` = `Sales`.`product_id`;

DROP TABLE IF EXISTS Q1_V1;
CREATE TABLE Q1_V1 AS
SELECT customer_id, product_name, price
FROM Menu
LEFT JOIN Sales ON `Menu`.`product_id` = `Sales`.`product_id`
ORDER BY customer_id;

SELECT * 
FROM Q1_V1;

SELECT customer_id, sum(price) AS spend
FROM Q1_v1
GROUP BY customer_id;

-- How many days has each customer visited the restaurant?
SELECT customer_id, count(order_date) AS visit
FROM sales
GROUP BY customer_id;

-- What was the first item from the menu purchased by each customer?
DROP TABLE IF EXISTS Q3_V1;
CREATE TABLE Q3_V1 AS
SELECT customer_id, order_date,product_id, row_number() over (partition by customer_id order by order_date) as flag
FROM sales;

SELECT * 
FROM Q3_V1;

DROP TABLE IF EXISTS Q3_V2;
CREATE TABLE Q3_V2 AS
SELECT customer_id, product_id, flag
FROM Q3_V1
WHERE flag = 1;

SELECT customer_id,product_name
FROM menu
LEFT JOIN Q3_V2 ON menu.product_id = Q3_V2.product_id;

-- What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT count(menu.product_id), product_name
FROM menu 
LEFT JOIN sales ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY count(menu.product_id) DESC;
-- QC 
SELECT count(product_id)
FROM sales;

-- Which item was the most popular for each customer?
DROP TABLE IF EXISTS Q4_V1;
CREATE TABLE Q4_V1 AS
SELECT customer_id, product_id, count(product_id) over (partition by customer_id, product_id) AS number_of_purchase from sales;

DROP TABLE IF EXISTS Q4_V2;
CREATE TABLE Q4_V2 AS
SELECT distinct(customer_id), Q4_V1.product_id, number_of_purchase, product_name
FROM Q4_V1
LEFT JOIN menu ON Q4_V1.product_id = menu.product_id
ORDER BY number_of_purchase DESC;

SELECT *
FROM Q4_V2;

SELECT Q4_V2.customer_id, product_name, MAX(number_of_purchase)
FROM Q4_V2
GROUP BY Q4_V2.customer_id,product_name;

SELECT Q4_V2.customer_id, product_name, MAX(number_of_purchase)
FROM Q4_V2
WHERE MAX(number_of_purchase) = (
SELECT number_of_purchase
GROUP BY Q4_V2.customer_id,product_name);


-- Which item was purchased first by the customer after they became a member?
DROP TABLE IF EXISTS Q5_V1;
CREATE TABLE Q5_V1 AS
SELECT sales.customer_id,product_id,join_date, order_date
FROM sales
LEFT JOIN member ON sales.customer_id = member.customer_id
WHERE order_date > join_date
ORDER BY customer_id, order_date;

DROP TABLE IF EXISTS Q5_V2;
CREATE TABLE Q5_V2 AS
SELECT `Q5_V1`.`customer_id`, `Q5_V1`.`product_id`, product_name, order_date, ROW_NUMBER() OVER(PARTITION BY `Q5_V1`.`customer_id` ORDER BY order_date) AS FLAG
FROM menu
LEFT JOIN Q5_V1 ON menu.product_id = Q5_V1.product_id;

DROP TABLE IF EXISTS Q5_V3;
CREATE TABLE Q5_V3 AS
SELECT customer_id, product_name
FROM Q5_V2
WHERE FLAG = 1;

SELECT * 
FROM Q5_V3;

-- Which item was purchased just before the customer became a member?
DROP TABLE IF EXISTS Q6_V1;
CREATE TABLE Q6_V1 AS
SELECT sales.customer_id,product_id,join_date, order_date
FROM sales
LEFT JOIN member ON sales.customer_id = member.customer_id
WHERE order_date < join_date
ORDER BY customer_id, order_date;

SELECT * 
FROM Q6_V1;

DROP TABLE IF EXISTS Q6_V2;
CREATE TABLE Q6_V2 AS
SELECT `Q6_V1`.`customer_id`, `Q6_V1`.`product_id`, product_name, order_date, ROW_NUMBER() OVER(PARTITION BY `Q6_V1`.`customer_id` ORDER BY order_date DESC) AS FLAG
FROM menu
LEFT JOIN Q6_V1 ON menu.product_id = Q6_V1.product_id;

SELECT *
FROM Q6_V2;

DROP TABLE IF EXISTS Q6_V3;
CREATE TABLE Q6_V3 AS
SELECT customer_id, product_name
FROM Q6_V2
WHERE FLAG = 1;

SELECT * 
FROM Q6_V3;

-- What is the total items and amount spent for each member before they became a member?
SELECT customer_id,SUM(price) AS amount_spent_before_membership
FROM menu 
LEFT JOIN Q6_V1 ON menu.product_id = Q6_V1.product_id
GROUP by customer_id; 

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT member.customer_id, product_name, price
FROM menu 
LEFT JOIN sales ON menu.product_id = sales.product_id
LEFT JOIN member ON sales.customer_id = member.customer_id;

-- In the first week after a customer joins the program (including their join date) cont... 
-- conti...they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- add





