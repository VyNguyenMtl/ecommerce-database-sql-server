use midtermProject

--sequence for invoice_number
ALTER TABLE invoices
ADD CONSTRAINT DF_invoices_number
DEFAULT NEXT VALUE FOR Sequence_invoices_number
FOR invoice_number

--Query 1: Write a single query to insert 2 rows in the cities table.
INSERT INTO cities(city_name, province_id)
VALUES			('Vancouver',3),
				('Albany', 4)

--Query 2: Write a query to modify the price and quantity of one product in the database 
--(use any condition in the WHERE clause).
UPDATE products
SET price = 39.99, quantity_available = 4
WHERE product_description = 'Keyboard'

--Query 3: Write a query to delete a country based on its name.
DELETE FROM countries
WHERE country_name = 'France'

--Query 4: Write two queries to delete an invoice and all its details.
DELETE FROM invoice_details 
WHERE invoice_id = 7
DELETE FROM invoices 
WHERE invoice_id = 7


--Query 5: Write a query to display one customer based on its first name and last name. 
--Use the view created earlier to display all the details (city, province, etc.).
SELECT *
FROM View_4tables

--Query 6: Write a query to display all the products in a certain price range 
--(minimum and maximum). Choose the price range.
SELECT *
FROM products
WHERE price BETWEEN 20 AND 100 
ORDER BY product_description

--Query 7: Write a query to display all the cities located in a specific country name (choose which one). 
--Display the city, province and country names.
SELECT city_name, province_name, country_name
FROM cities
	INNER JOIN provinces
	ON cities.province_id = provinces.province_id
	INNER JOIN countries
	ON provinces.country_id = countries.country_id
	AND country_name = 'Canada'
ORDER BY city_name

--Query 8: Write a query to show all the product numbers 
--where at least one of the translated description (french, english, etc.) 
--contains the letter Z anywhere in the description. 
--Do not display the product numbers many times 
--if the letter is found in more than one language for the same product.
SELECT product_number
FROM products
	INNER JOIN product_descriptions
	ON products.product_id = product_descriptions.product_id
	AND product_number LIKE '%Z%'
GROUP BY product_number
ORDER BY product_number

--Query 9: Show all the ids and numbers for the products that have only zero (0) or one (1) 
--translation for their description.
SELECT products.product_id,product_number
FROM products
	LEFT JOIN product_descriptions
ON products.product_id = product_descriptions.product_id
GROUP BY products.product_id, product_number
HAVING COUNT(language_code) <=1
ORDER BY product_number

--Query 10: Show all the customers who have 3 invoices or more.
SELECT customers.customer_id, firstname, lastname
FROM customers INNER JOIN invoices
ON customers.customer_id = invoices.customer_id
GROUP BY customers.customer_id, firstname, lastname
HAVING COUNT(invoices.customer_id) >= 3  
ORDER BY firstname

--Query 11: Show all the customers including the average price they paid for all their invoices. 
--Customers with no invoices should show 0($). TODO
SELECT firstname, lastname, 
CASE 
      WHEN AVG(grand_total) IS NULL THEN 0 
      ELSE AVG(grand_total) 
      END AS average_price
FROM customers  LEFT JOIN invoices
ON customers.customer_id = invoices.customer_id
GROUP BY firstname, lastname 
ORDER BY firstname

--Query 12: Show all the provinces starting with the letter N, O or Q.
select *
from provinces
where province_name like '[NOQ]%'
order by province_name

--Query 13: Show all the product descriptions where the 4th character is a number 
--and where the 5th character is a letter.
select *
from products
where product_description like '___[0-9][A-Za-z]%'
order by product_description

--Query 14: Write a query to modify the existing products table. 
--Add a field (column) to know if the product is new (true or false). 
--This field must allow NULL values.
ALTER TABLE products
ADD product_is_new bit NULL

--Query 15: Write a query to see state of the products (using the field created in the query 14). 
--If the product is new (if the field is true) display ‘New’, else display ‘Used’. 
--If the value is NULL display ‘Unknown’.
select product_description, product_is_new,
	case 
	when product_is_new IS NULL then 'Unknown'
	when product_is_new = 1
	then 'New'
	else 'Used'
	end as state_of_products
from products

--Query 16: Write a query to display all the products that were never sold. 
--Use a subquery to do it (WHERE ... IN (SELECT...)).
SELECT product_id, product_description
FROM products
WHERE product_id NOT IN (
    SELECT product_id
    FROM invoice_details)

--Query 17: Write a query to show all the customers (use the view) 
--with a postal code starting with H2K, H3K or H4K. 
--Use a single LIKE operator to implement it (do not use AND or OR operators).
select *
from View_4tables
where postal_code like 'H[234]K%'
order by firstname

--Query 18: Write a query to show the total of the 5 most recent invoices in the system. 
--Display the firstname, lastname, invoice number, date, and the total. 
--Sort by date from the most recent invoice to the oldest one.
select top 5 firstname, lastname, invoice_number, invoice_date, grand_total
from customers inner join invoices
on customers.customer_id = invoices.customer_id
order by invoice_date desc

--Query 19: Write a query to see all the invoice details for the invoice(s) with the greatest total.
select invoices.invoice_id, invoice_number, max(sub_total) as greatest_total
from invoice_details left join invoices
on invoice_details.invoice_id = invoices.invoice_id
group by invoices.invoice_id, invoice_number
order by invoice_number

--Query 20: Write a query to see all the cities NOT starting with the letters D, E, F, G or H.
select *
from cities
where city_name like '[^DEFGH]%'
order by city_name

--Query 21: Write a query to see all the cities where products were sold. 
--Show each city name once even if many invoices were created for that city.
select city_name, count(invoice_id) as products_were_sold  
from View_8tables
group by city_name
order by city_name

--Query 22: Write a query to create a SYNONYM on the invoices table.
create synonym second_invoice_table
for midtermProject.dbo.invoices

--Query 23: Write a query to view the customers from Montréal or from Ontario.
select firstname, lastname, city_name, province_name
from View_4tables
where city_name = 'Montreal' or province_name = 'Ontario'
order by firstname

--Query 24: Write a query to display, in the same column, the full name (first name and last name) 
--of all the customers who spent 1000$ or more on the website.
select firstname + ' ' + lastname as fullname, 
		sum(grand_total) as total_spent
from customers inner join invoices
on customers.customer_id = invoices.customer_id
group by firstname, lastname
having sum(grand_total) >= 1000 
order by fullname

--Query 25: Use the ANY or ALL operator to write a query that will return
--the products that we sold at least 5 times on the website.
SELECT product_id, product_description
FROM products
WHERE product_id = ANY (
    SELECT product_id
    FROM invoice_details
    GROUP BY product_id
    HAVING COUNT(product_id) >= 5)

--Query 26: Write a query that will tell which customers are ‘Good’ 
--(if they made 10 purchases or more), ‘Average’ (if they made 3 to 9 purchases) 
--or ‘Not profitable’ (less than 3 purchases)
select firstname, lastname,
case
	when count(customer_id2) >= 10 then 'Good'
	when count(customer_id2) between 3 and 9 then 'Average'
	else 'Not profitable'
	end as customer_evaluation
from View_8tables
group by firstname, lastname
order by firstname

--Query 27: The company want to give Gift Points to customers, when they do many purchases. 
--The company will give 5 Gift Points (which are not stored in the database) for each 100$ 
--purchased on the website. So if a customer buy for 275$, he/she will get 10 Gift Points. 
--Write a query to display the number of Gift Points for each customer in the system 
--even when customers never purchased anything. 
SELECT customers.customer_id, firstname, lastname, SUM(grand_total) AS total_spent,
CASE
     WHEN SUM(grand_total) IS NULL THEN 0
     ELSE FLOOR(SUM(grand_total) / 100) * 5
     END AS gift_points
FROM customers LEFT JOIN invoices
ON  customers.customer_id = invoices.customer_id
GROUP BY customers.customer_id, firstname, lastname
ORDER BY firstname

--Query 28: Write a query to display only the 3 first letters of all the countries 
--where we shipped products. Do not show duplicate values.
SELECT LEFT(country_name, 3) AS shipped_country
FROM countries

--Query 29: Write a query to view the description of the products. 
--If the description contains “MS” display “Microsoft” instead (ex: “MS Office” will display “Microsoft Office”).
SELECT REPLACE(product_description, 'MS', 'Microsoft') as modified_description
FROM products

--Query 30: Write a query to show the end of the warranty for each invoice. 
--The warranty is good for 1 year so display the invoice date + 1 year.
SELECT invoice_date,
DATEADD(year, 1, invoice_date) AS warranty_end_date
FROM invoices
ORDER BY invoice_date
 
--Query 31: Write a query to insert an invoice with at least 2 invoice details. 
--Calculate the taxes (9.975% for the QST and 5% for the GST). 
insert into invoices(customer_id, invoice_date, total_before_taxes, QST, GST, grand_total)
			values (1, '2024-04-20', 69.98, 6.95, 3.50, 80.43 )
insert into invoice_details(invoice_id, product_id, quantity_purchased, sub_total)
			values (11, 1, 1,29.99),
					(11, 3, 1, 39.99)
--Query 32: Write a query to view the name of all the tables which contain the text “Inv” in your database.
SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%Inv%'

--Query 33: Write a query to view the name of all the columns with the data type 
--NUMERIC or DECIMAL in your database (match the query with the data type you used in your database).
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('numeric', 'decimal') 

--Query 34: Write a query to change the existing weight field so that it can handle 2 decimals (ex: 2.25 kg).
ALTER TABLE products
ALTER COLUMN weight_in_kg decimal(4,2)

--Query 35: Write a query to modify the constraint created in the first part. 
--The weight must now be between 0.01 and 50 kg.
ALTER TABLE products
DROP CONSTRAINT CK_products_weight;
 
ALTER TABLE products
ADD CONSTRAINT CK_products_weight
CHECK (weight_in_kg between 0.01 and 50)

--Query 36: Write a query to display the number of days between the date of the oldest invoice 
--and the date of the most recent invoice.
SELECT DATEDIFF(DAY, MIN(invoice_date), MAX(invoice_date)) AS days_difference
FROM invoices

--Query 37: Write a query to backup the database in a binary file on the disk 
--(do not have to submit this binary file on Omnivox).
backup database Practice_dtb
to disk = 'C:\Users\vnguy\OneDrive - College LaSalle\Documents\DATABASE\Backup' 
