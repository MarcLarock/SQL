#1
SELECT * 
FROM offices;

#2
SELECT e.EmployeeNumber, e.LastName, e.FirstName, e.Extension
FROM employees e
JOIN offices o
ON e.officeCode = o.officeCode
WHERE country = 'France';

#3
SELECT ProductCode, ProductName, ProductVendor, QuantityInStock
FROM products
WHERE productLine LIKE 'classic%'
AND QuantityInStock BETWEEN 5000 AND 7000;

#4
SELECT ProductCode, ProductName, ProductVendor, BuyPrice, MSRP
FROM products
WHERE MSRP = 
(SELECT MIN(MSRP) 
FROM products);

#5
SELECT ProductName, (MSRP - BuyPrice) AS profit
FROM products
ORDER BY profit 
DESC LIMIT 1;

#6
SELECT country, COUNT(customerNumber) AS Counts
FROM customers
GROUP BY country
HAVING Counts >= 5
ORDER BY Counts DESC;

#7
SELECT p.ProductCode, p.ProductName, COUNT(o.orderNumber) AS orders
FROM products p
JOIN orderdetails o
ON p.ProductCode = o.ProductCode
GROUP BY p.ProductName, p.ProductCode
ORDER BY orders DESC LIMIT 1;


#8
SELECT country, city, territory, officeCode,
CASE
	WHEN country = 'USA' THEN 'Ops'
    WHEN country = 'UK' THEN 'Corporate'
    WHEN country = 'France' THEN 'Accounting'
	ELSE 'NA'
END AS Status
FROM offices
ORDER BY country DESC;

#9
SELECT o.orderNumber, o.orderDate, o.shippedDate, p.paymentDate, p.amount, t.OrderTotal
FROM orders o
JOIN payments p
ON o.customerNumber = p.customerNumber
JOIN TopCustomers t 
ON p.customerNumber = t.customerNumber
ORDER BY t.OrderTotal DESC;

#10
SELECT t.OrderTotal, t.OrderCount, c.customerName, c.city, c.country
FROM TopCustomers t
JOIN customers c
ON t.customerNumber = c.customerNumber
ORDER BY OrderTotal
DESC LIMIT 10;

#11
SELECT o.orderNumber, o.orderDate, c.customerNumber, c.customerName
FROM orders o
JOIN customers c
ON o.customerNumber = c.customerNumber
ORDER BY customerNumber;

#12
SELECT e.lastName, e.firstName, e.extension
FROM employees e
JOIN offices o
ON e.officeCode = o.officeCode
WHERE o.city LIKE 'Paris';

#13
SELECT productCode, productName, productLine, productVendor
FROM products
WHERE quantityInStock BETWEEN 5000 AND 7000
AND productLine LIKE 'Classic Cars';

#14
SELECT customerName, SUM(quantityOrdered) as TotalProducts
FROM customers c
JOIN orders o
ON o.customerNumber = c.customerNumber
JOIN orderdetails d
ON d.orderNumber = o.orderNumber
GROUP BY customerName
HAVING TotalProducts > 2000;

#15
SELECT DISTINCT e.firstname, e.lastname, e.employeeNumber, e.jobTitle, c.salesRepEmployeeNumber,
CASE 
	WHEN c.salesRepEmployeeNumber IS NULL THEN 'Non-Producer'
    ELSE 'Producer'
END AS Status
FROM employees e
LEFT JOIN customers c
ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE jobTitle = 'Sales Rep';

#16
SELECT c.customerName, c.country, COUNT(o.customerNumber) AS OrderCounts
FROM customers c
JOIN orders o
ON o.customerNumber = c.customerNumber
WHERE c.country LIKE 'Spai%'
GROUP BY c.customerName, c.country;

#17
SELECT DISTINCT c.customerName AS 'Top Earners', c.city, c.country, (d.priceEach*d.quantityOrdered) AS Total 
FROM customers c
JOIN orders o
ON c.customerNumber = o.customerNumber
JOIN orderdetails d
ON o.orderNumber = d.orderNumber
ORDER BY Total DESC LIMIT 3;

#18 CTE (Common Table Expression)
WITH topsales2003 AS (
    SELECT 
        salesRepEmployeeNumber AS employeeNumber,
        SUM(quantityOrdered * priceEach) AS Sales
    FROM
        orders
            INNER JOIN
        orderdetails USING (orderNumber)
            INNER JOIN
        customers USING (customerNumber)
    WHERE
        YEAR(shippedDate) = 2003
            AND status = 'Shipped'
    GROUP BY salesRepEmployeeNumber
    ORDER BY sales DESC
    LIMIT 5
)
SELECT employeeNumber, firstName, lastName, sales
FROM
    employees
        JOIN
    topsales2003 USING (employeeNumber);
    

#19 Stroed Procedure
DELIMITER $$

CREATE PROCEDURE GetCustomers()
BEGIN
	SELECT 
		customerName, 
		city, 
		state, 
		postalCode, 
		country
	FROM
		customers
	ORDER BY customerName;    
END$$
DELIMITER ;

CALL GetCustomers();


#20 Stored Functions
DELIMITER $$
CREATE FUNCTION CustomerLevel(
	credit DECIMAL(10,2)
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE customerLevel VARCHAR(20);

    IF credit > 50000 THEN
		SET customerLevel = 'PLATINUM';
    ELSEIF (credit >= 50000 AND 
			credit <= 10000) THEN
        SET customerLevel = 'GOLD';
    ELSEIF credit < 10000 THEN
        SET customerLevel = 'SILVER';
    END IF;
	-- return the customer level
	RETURN (customerLevel);
END$$
DELIMITER ;



SHOW FUNCTION STATUS 
WHERE db = 'classicmodels';

SELECT 
    customerName, 
    CustomerLevel(creditLimit)
FROM
    customers
ORDER BY 
    customerName;


#21
WITH countrylist AS (
SELECT country, city, officeCode,
	CASE
		WHEN country = 'USA' THEN 'Ops'
		WHEN country = 'UK' THEN 'Accounting'
		WHEN country = 'France' THEN 'Corporate'
		ELSE 'NA'
	END AS Status
	FROM offices
	ORDER BY country DESC	
)

SELECT countrylist.country, countrylist.status, e.lastName, e.firstName
FROM  countrylist
JOIN employees e 
USING (officeCode)
ORDER BY country ASC;

#22
DELIMITER $$

CREATE PROCEDURE GetOfficeCode()
BEGIN
	SELECT officeCode, city, country
	FROM offices;
END $$

DELIMITER ;

CALL GetOfficeCode();

#23
SELECT *
FROM employees
WHERE officeCode = 4 OR officeCode = 5
ORDER BY officeCode;


WITH TopEarners AS (
	SELECT DISTINCT c.customerName AS 'Top Earners', c.city, c.country, (d.priceEach*d.quantityOrdered) AS Total 
	FROM customers c
	JOIN orders o
	ON c.customerNumber = o.customerNumber
	JOIN orderdetails d
	ON o.orderNumber = d.orderNumber
	ORDER BY Total DESC
)

SELECT *
FROM TopEarners
LIMIT 1 OFFSET 2;

#24
WITH MostOrdered AS (
	SELECT p.productCode, p.productName, p.productLine, COUNT(d.productCode) AS NumberOrdered
    FROM products p
    JOIN orderdetails d
    USING (productCode)
    GROUP BY p.productCode, p.productName, p.productLine
    ORDER BY COUNT(d.productCode) DESC
)

SELECT productName, MIN(NumberOrdered) AS Lowest
FROM MostOrdered
GROUP BY productName
ORDER BY Lowest LIMIT 2;

#25
SELECT productCode, productName, productLine, quantityInStock,
CASE
	WHEN quantityInStock <= 999 AND quantityInStock > 500 THEN 'Schedule Reorder'
    WHEN quantityInStock <= 500 AND quantityInStock > 150 THEN 'Reorder Critical'
    WHEN quantityInStock <= 150 AND quantityInStock >= 1 THEN 'Backorder'
    ELSE 'Fully Stocked'
END AS 'Stock Level'
FROM products
ORDER BY quantityInStock DESC;

