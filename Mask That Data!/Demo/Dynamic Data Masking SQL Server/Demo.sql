USE WWI;
GO

-- Clean up the database and set it up
DROP TABLE IF EXISTS Sales.Customer;
DROP TABLE IF EXISTS Sales.OrderLine;
SELECT TOP ( 100 )
	   *
INTO Sales.Customer
FROM Sales.Customers
ORDER BY CustomerID;

SELECT TOP ( 100 )
	   *
INTO Sales.OrderLine
FROM Sales.OrderLines
ORDER BY OrderLineID;
GO

-- Select the unmasked data
SELECT TOP ( 10 )
	   CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
ORDER BY CustomerID;

-- Lets create a user that only sees masked data
DROP USER IF EXISTS user1;
GO
CREATE USER user1 WITHOUT LOGIN;
GRANT SELECT ON Sales.Customer TO user1;
GRANT SELECT ON Sales.OrderLine TO user1;
GO

-- Lets alter the table to only show masked data
ALTER TABLE Sales.Customer
ALTER COLUMN DeliveryAddressLine1
ADD MASKED WITH(FUNCTION='default()');
GO

-- Select the data again and see what changed 
SELECT TOP ( 10 )
	   CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
ORDER BY CustomerID;


-- Nothing Changed !!!


-- Let's run it under the context of the user
EXECUTE AS USER = 'user1';
SELECT TOP ( 10 )
	   CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
ORDER BY CustomerID;
REVERT;



-- Lets mask the phone number
ALTER TABLE Sales.Customer
ALTER COLUMN PhoneNumber
ADD MASKED WITH(FUNCTION='partial(6,"-XXX-XX",2)');

-- Let's run it under the context of the user
EXECUTE AS USER = 'user1';
SELECT TOP ( 10 )
	   CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
ORDER BY CustomerID;
REVERT;



-- Lets generate something random
ALTER TABLE Sales.OrderLine
ALTER COLUMN UnitPrice
ADD MASKED WITH(FUNCTION='random(100, 200)');

-- Let's run it under the context of the user
SELECT *
FROM Sales.OrderLine;
EXECUTE AS USER = 'user1';
SELECT TOP ( 10 )
	   OrderLineID,
	   Description,
	   UnitPrice
FROM Sales.OrderLine
ORDER BY OrderLineID;
REVERT;




-- Lets give the user the privilege to unmask
EXECUTE AS USER = 'user1';
SELECT CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
WHERE DeliveryAddressLine1 = 'Shop 38';
REVERT;

GRANT UNMASK TO user1

EXECUTE AS USER = 'user1';
SELECT CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
WHERE DeliveryAddressLine1 = 'Shop 38';
REVERT;

REVOKE UNMASK TO user1




-- Other functions are 

-- email()




-- This is all good and well, but where does it go wrong
EXECUTE AS USER = 'user1';
SELECT CustomerName,
	   DeliveryAddressLine1,
	   DeliveryAddressLine2,
	   DeliveryPostalCode,
	   PhoneNumber,
	   FaxNumber
FROM Sales.Customer
WHERE DeliveryAddressLine1 = 'Shop 38';
REVERT;





-- Get all the maked columns
SELECT t.name AS TableName,
	   mc.name AS ColumnName,
	   mc.masking_function AS MaskingFunction
FROM sys.masked_columns AS mc
	INNER JOIN sys.tables AS t
		ON mc.[object_id] = t.[object_id]
WHERE t.name IN ('Customer', 'OrderLine');
