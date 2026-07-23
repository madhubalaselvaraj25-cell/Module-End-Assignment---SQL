CREATE DATABASE elearning_db;
USE elearning_db;
SELECT DATABASE();
CREATe TABLE learners(
	learner_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);
DESC learners;

CREATE TABLE courses(
	course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);
DESC courses;

CREATE TABLE purchases(
	purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    quantity INT,
    purchase_date DATE,
    FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
);
DESC purchases;
SHOW TABLES;

INSERT INTO learners
VALUES
(101,'Karthick','India'),
(102,'Priya','India'),
(103,'Harsiv','USA'),
(104,'Sara','UK'),
(105,'Bala','Singapore');

SELECT * FROM learners;

INSERT INTO courses
VALUES
(201,'Python for Beginners','Beginner',10000.00),
(202,'Advanced SQL','Intermediate',15000.00),
(203,'Power BI Dashboard','Analytics',9000.00),
(204,'Machine Learning','Advanced',17000.00),
(205,'Excel for Data Analysis','Beginner',10000.00);

SELECT * FROM courses;

INSERT INTO purchases
VALUES
(301,101,201,2,'2026-01-10'),
(302,101,202,1,'2026-01-15'),
(303,102,203,2,'2026-02-05'),
(304,103,201,1,'2026-02-12'),
(305,103,204,1,'2026-03-01'),
(306,104,202,3,'2026-03-10'),
(307,105,203,1,'2026-03-20'),
(308,102,204,2,'2026-04-02');

SELECT * FROM purchases;

-- JOINS ---

SELECT
	l.full_name AS learner_name,
    c.course_name,
    c.category,
    p.quantity,
    ROUND(p.quantity * c.unit_price,2) AS total_amount,
    p.purchase_date
FROM purchases p
INNER JOIN learners l
ON p.learner_id = l.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id    
ORDER BY total_amount DESC;  

SELECT
    l.full_name AS learner_name,
    c.course_name,
    c.category,
    p.quantity,
    ROUND(p.quantity * c.unit_price,2) AS total_amount,
    p.purchase_date
FROM learners l
LEFT JOIN purchases p
ON l.learner_id = p.learner_id
LEFT JOIN courses c
ON p.course_id = c.course_id
ORDER BY total_amount DESC;

SELECT
    l.full_name AS learner_name,
    c.course_name,
    c.category,
    p.quantity,
    ROUND(p.quantity * c.unit_price,2) AS total_amount,
    p.purchase_date
FROM learners l
RIGHT JOIN purchases p
ON l.learner_id = p.learner_id
RIGHT JOIN courses c
ON p.course_id = c.course_id
ORDER BY total_amount DESC;
 
--  Q1. Display each learner’s total spending with their country--
  
  SELECT
	l.full_name,
    l.country,
    ROUND(sum(p.quantity * c.unit_price),2) AS Total_Spending
    FROM learners l
    JOIN purchases p
    ON l.learner_id = p.learner_id
    JOIN courses c
    ON p.course_id = c.course_id
    GROUP BY full_name,l.country;
    
-- Q2. Find the top 3 most purchased courses by quantity - -

SELECT
c.course_name,
sum(p.quantity) AS Total_Quantity
FROM courses c
JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.course_name
ORDER BY Total_Quantity DESC
LIMIT 3;

-- Q3. Total revenue and Number of unique learners --

SELECT 
c.category,
sum(p.quantity * c.unit_price) AS Total_Revenue,
COUNT(DISTINCT p.learner_id) AS Unique_Learners
FROM courses c
INNER JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category;

-- Q4. List learners who purchased from more than one category - --

SELECT 
l.full_name AS Learner_Name,
COUNT(DISTINCT c.category) AS Categories
FROM learners l
INNER JOIN purchases p
ON  l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.full_name
HAVING COUNT(DISTINCT c.category)>1;  

-- Q5. Identify courses never purchased - -

SELECT
c.course_id AS Course_ID,
c.course_name AS Course_Name,
c.category AS Category
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
WHERE p.course_id IS NULL;

-- Q6. learners whose total spending is above the average learner spending--

SELECT
l.full_name AS Learner_Name,
FORMAT(SUM(p.quantity * c.unit_price), 2) AS Total_Spending
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(Total_Spending)
    FROM
    (
        SELECT
            SUM(p.quantity * c.unit_price) AS Total_Spending
        FROM purchases p
        INNER JOIN courses c
        ON p.course_id = c.course_id
        GROUP BY p.learner_id
    ) AS Avg_Spending
);

-- Q7. courses whose price is higher than any course in the ‘Beginner’ category- -

SELECT
course_name AS Course_Name,
category AS Category,
unit_price AS Unit_Price
FROM courses
WHERE unit_price >
(
    SELECT MAX(unit_price)
    FROM courses
    WHERE category = 'Beginner'
);

-- Q8 . Find learners who spent more than the average spending in their country--

SELECT
    l.full_name,
    l.country,
    SUM(p.quantity * c.unit_price) AS Total_Spending
FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
HAVING SUM(p.quantity * c.unit_price) >
(
    SELECT AVG(country_spending)
    FROM
    (
        SELECT
            l2.country,
            l2.learner_id,
            SUM(p2.quantity * c2.unit_price) AS country_spending
        FROM learners l2
        JOIN purchases p2
        ON l2.learner_id = p2.learner_id
        JOIN courses c2
        ON p2.course_id = c2.course_id
        WHERE l2.country = l.country
        GROUP BY l2.country, l2.learner_id
    ) AS CountryAverage
);

-- Q9. CTE - learners spending above 10,000--

WITH Learner_Spending AS
(
    SELECT
        l.learner_id,
        l.full_name,
        SUM(p.quantity * c.unit_price) AS Total_Spending
    FROM learners l
    JOIN purchases p
    ON l.learner_id = p.learner_id
    JOIN courses c
    ON p.course_id = c.course_id
    GROUP BY l.learner_id, l.full_name
)

SELECT *
FROM Learner_Spending
WHERE Total_Spending > 10000;

-- Q10. CASE Expression -

SELECT
    l.full_name,
    SUM(p.quantity * c.unit_price) AS Total_Spending,

    CASE
        WHEN SUM(p.quantity * c.unit_price) > 15000 THEN 'High Value'

        WHEN SUM(p.quantity * c.unit_price) BETWEEN 8000 AND 15000 THEN 'Medium Value' ELSE 'Low Value'
    END AS Customer_Category

FROM learners l
JOIN purchases p
ON l.learner_id = p.learner_id
JOIN courses c
ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name;

-- Q11 . NULL Handling --

SELECT
    c.course_name,
    COALESCE(COUNT(p.purchase_id),0) AS Purchase_Count
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name;

-- Q12 . View --

CREATE VIEW category_performance_view AS
SELECT
    c.category AS Category,
    SUM(p.quantity * c.unit_price) AS Total_Revenue,
    COUNT(p.purchase_id) AS Number_of_Purchases,
    ROUND(AVG(p.quantity * c.unit_price),2) AS Average_Revenue_Per_Purchase
FROM courses c
INNER JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category;

SELECT * 
FROM category_performance_view;