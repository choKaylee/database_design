-- INFO330AB5 : E-Commerce Grocery Store
-- Uijin Lim, Kaylee Cho, Re Lee, Sally Shin
-- 2024.03.08
-------------------------------------------------------------------------------
-- Q0: the name of the database on the class server in which I can find your schema

-- name of database : rlee22_db 
-------------------------------------------------------------------------------
-- Q1: a list of CREATE TABLE statements implementing your schema
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(20),
    last_name VARCHAR(20),
    city VARCHAR(20),
    state VARCHAR(20),
    phone_number VARCHAR(20),
    address VARCHAR(100)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_price DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_name VARCHAR(20),
    price DECIMAL(10, 2),
    discount_percentage DECIMAL(5, 2),
    stock INT,
    rating DECIMAL(3,1)
);

CREATE TABLE OrderDetails (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

CREATE TABLE Payments (
    payment_id INT PRIMARY KEY,
    customer_id INT,
    payment_method VARCHAR(20),
    amount DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Shipment (
    shipment_id INT PRIMARY KEY,
    order_id INT,
    customer_id INT,
    shipment_date DATE,
    company_name VARCHAR(20),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Suppliers (
    supplier_id INT PRIMARY KEY,
    company_name VARCHAR(20)
);

CREATE TABLE SupplierProvides(
    supplier_id INT,
    product_id INT,
    PRIMARY KEY (supplier_id, product_id),
    FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-------------------------------------------------------------------------------
-- Q2: a list of 10 SQL statements using your schema, along with the English question it implements.

-- Q1 What are the recent order products? (Customer)
SELECT 
	o.order_id,
	o.order_date,
	p.product_name,
	od.quantity
FROM Orders o
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
WHERE o.order_date = (SELECT MAX(order_date) FROM Orders);

-- Q2 Which products currently have fewer than 150 stocks?(Owner, Customer)
SELECT product_name, stock
FROM Products
WHERE stock < 150;

-- Q3 Which items are currently being offered at a discount more than 10%? (Customer)
SELECT product_name, price, discount_percentage
FROM Products
WHERE discount_percentage > 10;

-- Q4 How many orders were shipped for each shipping company? (Owner)
SELECT company_name, COUNT(*) AS num_orders_shipped
FROM Shipment
GROUP BY company_name;

-- Q5 What is the average rating of products in each category? (Customer)
SELECT category_name, AVG(rating) AS average_rating
FROM Products
GROUP BY category_name;

-- Q6 What quantity of each product was sold in specific cities and states? (Owner, Analysts)
SELECT 
	c.city,
    c.state,
    p.product_name,
    SUM(od.quantity) AS total_quantity_sold
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
JOIN Shipment s ON o.order_id = s.order_id
GROUP BY c.city, c.state, p.product_name
ORDER BY c.state, c.city, total_quantity_sold DESC;

-- Q7 What is the date of the most recent order for each state?(Owner, Analysts)
SELECT
  c.state,
  MAX(o.order_date) AS latest_order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.state;

-- Q8 What is the average stock quantity for each product category? (Owner, Analysts)
SELECT
  category_name,
  AVG(stock) AS average_stock
FROM Products
GROUP BY category_name;

-- Q9. Who are our top suppliers by volume for the past year? (Owner)
SELECT s.company_name, COUNT(*) as count_supplied_products
FROM Suppliers s
JOIN SupplierProvides sp on s.supplier_id = sp.supplier_id
JOIN  Products p on p.product_id = sp.product_id
GROUP BY s.company_name
ORDER BY count_supplied_products DESC;

-- Q10. How fast does a product with a high discount rate(>=10%) get sold out? (Analyst)
-- first query returns order date of discount_percentage > 10
SELECT discount_percentage, order_date
FROM Products as p
JOIN Orders as o on o.order_id = p.product_id
WHERE discount_percentage > 10
ORDER BY order_date;
-- second query returns order date of discount_percentage < 10
SELECT discount_percentage, order_date
FROM Products as p
JOIN Orders as o on o.order_id = p.product_id
WHERE discount_percentage < 10
ORDER BY order_date;

-- Q11. Can we identify any patterns in payment methods preferred by customers from various states? (Analysts, Owner)
-- By each state, I've returned payment methods that are used and the count used for each payment method.
-- EX Findings: CA-likes cash & debit card, FL-likes debit card, OH-likes paypal and so on
SELECT c.state, p.payment_method, COUNT(*) as payment_method_count
FROM Customers c
JOIN Payments p on c.customer_id = p.customer_id
GROUP BY c.state, p.payment_method
ORDER BY state, payment_method_count DESC;
-------------------------------------------------------------------------------
-- Q3: a list of 3-5 demo queries that return (minimal) sensible results. 
-- Please specify the team member responsible for each. These can be a subset of the 10 queries implemented for Q2, in which case it's okay to list them twice.

-- Uijin Lim : 
-- Q7 What is the date of the most recent order for each state?(Owner, Analysts)
SELECT
  c.state,
  MAX(o.order_date) AS latest_order_date
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.state;

-- "state"	"latest_order_date"
-- "NV"	"2024-03-15"
-- "OH"	"2024-04-14"
-- "NY"	"2024-03-01"
-- "MI"	"2024-03-17"
-- "OR"	"2024-04-11"
-- "WI"	"2024-04-03"
-- "TN"	"2024-03-30"
-- "WA"	"2024-03-11"
-- "MA"	"2024-03-12"
-- "CO"	"2024-03-14"
-- "AZ"	"2024-03-05"
-- "HI"	"2024-04-16"
-- "IN"	"2024-03-28"
-- "FL"	"2024-04-02"
-- "UT"	"2024-03-22"
-- "CA"	"2024-04-17"
-- "TX"	"2024-04-19"
-- "KY"	"2024-03-29"
-- "MO"	"2024-03-24"
-- "NC"	"2024-04-10"
-- "OK"	"2024-03-31"
-- "GA"	"2024-03-13"
-- "MN"	"2024-03-18"
-- "PA"	"2024-04-13"
-- "AK"	"2024-04-18"
-- "MD"	"2024-04-09"
-- "IL"	"2024-03-03"
-------------------------------------------------------------------------------
-- Re Lee : 
-- Q1 What are the recent order products? (Customer)
SELECT 
	o.order_id,
	o.order_date,
	p.product_name,
	od.quantity
FROM Orders o
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id
WHERE o.order_date = (SELECT MAX(order_date) FROM Orders);

-- "order_id"	"order_date"	"product_name"	"quantity"
-- 50	"2024-04-19"	"Remote Control Car"	3
-------------------------------------------------------------------------------
-- Sally Shin : 
-- Q3 Which items are currently being offered at a discount more than 10%? (Customer)
SELECT product_name, price, discount_percentage
FROM Products
WHERE discount_percentage > 10;

-- "product_name"	"price"	"discount_percentage"
-- "Microwave Oven Pro"	299.99	15.00
-- "Comfy Sofa"	899.99	20.00
-- "Powerful Laptop"	999.99	12.00
-- "Noise-Canceling Headphones"	699.99	18.00
-- "Leather Sofa"	1299.99	15.00
-- "Gaming Laptop"	1199.99	12.00
-- "Wireless Earbuds"	199.99	15.00
-- "Coffee Table"	299.99	20.00
-- "Fitness Tracker"	149.99	12.00
-- "Dining Table"	699.99	15.00
-- "Lounge Chair"	499.99	15.00
-- "Writing Desk"	199.99	15.00
-------------------------------------------------------------------------------
-- Kaylee Cho : 
-- Q9. Who are our top suppliers by volume for the past year? (Owner)
SELECT s.company_name, COUNT(*) as count_supplied_products
FROM Suppliers s
JOIN SupplierProvides sp on s.supplier_id = sp.supplier_id
JOIN  Products p on p.product_id = sp.product_id
GROUP BY s.company_name
ORDER BY count_supplied_products DESC;

-- "company_name"	"count_supplied_products"
-- "Smith Enterprises"	11
-- "Johnson & Sons"	10
-- "ABC Company"	10
-- "XYZ Corporation"	10
-- "Global Foods Inc."	10
-------------------------------------------------------------------------------
-- Q4: reflection on what you learned and challenges

-- Sally Shin: 
-- I have gained valuable insights into the significance of carefully evaluating 
-- the connections between different entities and ensuring the integrity of data. 
-- It was crucial to comprehend how tables are interrelated and establish appropriate 
-- foreign key constraints in order to maintain consistency and accuracy within the database. 
-- While designing the table schema using ERD, I encountered challenges in establishing 
-- relationships between tables using foreign keys. Understanding the one-to-many and many-to-many 
-- relationships between tables and accurately reflecting the business requirements proved to be difficult. 
-- At times, determining the relationships between tables while considering various requirements 
-- could be intricate and perplexing. However, to overcome these challenges, collaboration with 
-- team members and conducting thorough analysis to deepen our understanding of the business 
-- requirements were indispensable. Through these collaborative efforts, we successfully developed 
-- an efficient and scalable data model.

-- Re Lee:
-- The most challenging aspect of the database design and implementation process for me was understanding 
-- the intricacies of entity relationships within the database. Recognizing the significance of one-to-many 
-- and many-to-many relationships and accurately representing them in the schema deepened my understanding 
-- of database architecture.
-- During our collaborative efforts in creating tables as a group, establishing foreign key relationships 
-- between tables posed a significant challenge. However, through open communication and reflection on our 
-- learnings, we overcame this obstacle successfully, which was a rewarding experience. Personally, I found 
-- great enjoyment and growth in improving my proficiency in SQL syntax and constructing complex queries 
-- throughout the project. Working with my group was particularly gratifying as we all contributed our efforts 
-- towards achieving our common goal.Overall, the experience of designing and implementing the database schema 
-- has been enriching and transformative. It not only enhanced my understanding of database architecture but 
-- also fostered valuable teamwork and collaboration skills.

-- Uijin Lim:
-- Reflecting on the design and implementation process of the database schema, several key learnings 
-- and challenges emerged. The process of database design and implementation was crucial for efficiently 
-- storing and managing data, particularly in scenarios involving complex relationships between various 
-- entities such as customers, orders, products, and suppliers. Designing the foreign key relationships 
-- between tables was both enlightening and challenging, requiring a thorough understanding of how 
-- different entities relate to one another. The implementation phase reinforced the necessity of being 
-- proficient in SQL syntax and queries. Writing SQL statements to create tables, insert data, and, 
-- especially, constructing complex queries involving multiple joins and subqueries to answer specific 
-- questions presented a significant learning curve. Ensuring data integrity while designing foreign key
-- constraints posed another challenge. It was crucial to accurately define these constraints to prevent 
-- orphan records and maintain the relational integrity of the database. This required a deep understanding 
-- of the relationships between different entities in the database. 

-- Kaylee Cho:
-- Creating entity relation diagrams and constantly checking on the relationships between the tables 
-- to successfully answer the questions we generated was the most challenging part. Sometimes, we noticed 
-- that the foreign key relationships between the tables needed modification after writing the query for 
-- each question. Moreover, avoiding redundancy was also a part where we had to be very considerate throughout 
-- the project since there were a lot of attributes in each entity. However overall this process really made me 
-- learn how to design a product database system as well as being able to reflect on the stakeholders as 
-- developing the database. It was vital to put on the stakeholders shoes while writing up the questions. 
-- Therefore, I learned how and why businesses would hire data engineers, database designers, and analysts 
-- to maximize their profit and resources. I really enjoyed working as a group too since we were able to 
-- learn from each other and fix errors that I wasn’t able to detect by myself.










