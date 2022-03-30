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

-- Question 1: What is the total amount each customer spent at the restaurant?
SELECT customer_id, SUM(price) AS spend
FROM Menu
LEFT JOIN Sales ON `Menu`.`product_id` = `Sales`.`product_id`
GROUP BY customer_id;

-- Question 2: How many days has each customer visited the restaurant?
SELECT customer_id, count(order_date) AS visit
FROM sales
GROUP BY customer_id;

-- Question 3: What was the first item from the menu purchased by each customer?
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

-- Question 4: What is the most purchased item on the menu and how many times was it purchased by all customers?
-- how to handle tie in ranking? cross join?? 
SELECT count(menu.product_id), product_name
FROM menu 
LEFT JOIN sales ON menu.product_id = sales.product_id
GROUP BY product_name
ORDER BY count(menu.product_id) DESC;
-- QC 
SELECT count(product_id)
FROM sales;

-- Question 5: Which item was the most popular for each customer?
SELECT sales.customer_id,COUNT(menu.product_name) AS number, product_name
FROM sales
LEFT JOIN member ON sales.customer_id = member.customer_id
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
ORDER BY customer_id, number DESC ;
-- version B 
DROP TABLE IF EXISTS Q5_V1;
CREATE TABLE Q5_V1 AS
SELECT sales.customer_id,COUNT(menu.product_name) AS number, product_name
FROM sales
LEFT JOIN member ON sales.customer_id = member.customer_id
LEFT JOIN menu ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
ORDER BY customer_id, number DESC ;

DROP TABLE IF EXISTS Q5_V2;
CREATE TABLE Q5_V2 AS
SELECT customer_id, product_name, row_number() over (partition by customer_id order by number) AS flag
FROM Q5_V1;

DROP TABLE IF EXISTS Q5_V3;
CREATE TABLE Q5_V3 AS
SELECT customer_id, product_name, flag
FROM Q5_V2
WHERE flag = 1;

SELECT *
FROM Q5_V3;

-- Question 6: Which item was purchased first by the customer after they became a member?
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

-- Question 7: Which item was purchased just before the customer became a member?
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

-- Question 8: What is the total items and amount spent for each member before they became a member?
SELECT customer_id,COUNT(menu.product_id) AS total_num_items, SUM(price) AS amount_spent_before_membership
FROM menu 
LEFT JOIN Q6_V1 ON menu.product_id = Q6_V1.product_id
GROUP by customer_id; 

-- Question 9: If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
DROP TABLE IF EXISTS Q9_V1;
CREATE TABLE Q9_V1 AS
SELECT member.customer_id, product_name, price, CASE WHEN product_name = 'sushi' THEN 2 
WHEN product_name = 'curry' THEN 1 
WHEN product_name ='ramen' THEN 1 END AS multipler, (price * CASE WHEN product_name = 'sushi' THEN 2 
WHEN product_name = 'curry' THEN 1 
WHEN product_name ='ramen' THEN 1 END) AS points
FROM menu 
LEFT JOIN sales ON menu.product_id = sales.product_id
LEFT JOIN member ON sales.customer_id = member.customer_id
ORDER BY customer_id;

SELECT customer_id, SUM(points)
FROM Q9_V1
GROUP BY customer_id;

SELECT * 
FROM Q9_V1;

-- Question 10: In the first week after a customer joins the program (including their join date) cont... 
-- conti...they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT sales.customer_id, price, product_name, join_date, order_date, menu.product_id, DATE_ADD(join_date, INTERVAL 7 DAY) AS first_week, DATE_ADD(DATE_ADD(join_date, INTERVAL 7 DAY), INTERVAL 7 DAY) AS second_week, (price*2) AS points
FROM sales
LEFT JOIN member ON sales.customer_id = member.customer_id
LEFT JOIN menu ON sales.product_id = menu.product_id
WHERE order_date BETWEEN DATE_ADD(join_date, INTERVAL 7 DAY) AND DATE_ADD(DATE_ADD(join_date, INTERVAL 7 DAY), INTERVAL 7 DAY);

