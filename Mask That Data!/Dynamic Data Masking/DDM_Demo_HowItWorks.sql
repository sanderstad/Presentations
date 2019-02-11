USE MaskThatData;
GO

---------------------------------------------------------------
-- E-mail adresses
---------------------------------------------------------------

-- Alter the table
ALTER TABLE dbo.People
ALTER COLUMN EmailAddress
ADD MASKED WITH(FUNCTION='email()');
GO

-- Check which user I'm selecting with
SELECT SUSER_NAME() AS SysUsername,
	   USER_NAME() AS Username;

-- Select the data again
SELECT PersonID,
	   FullName,
	   EmailAddress
FROM dbo.People;
GO

-- Change the user I'm executing as
EXECUTE AS USER = 'maskeduser';
SELECT SUSER_NAME() AS SysUsername,
	   USER_NAME() AS Username;
SELECT PersonID,
	   FullName,
	   EmailAddress
FROM dbo.People;
REVERT;
GO

---------------------------------------------------------------
-- Creditcards
---------------------------------------------------------------
-- Alter the table
ALTER TABLE dbo.CreditCards
ALTER COLUMN CreditCardNumber
ADD MASKED WITH(FUNCTION='partial(0, "XXXX XXXX XXXX ", 4)');

ALTER TABLE dbo.CreditCards
ALTER COLUMN CreditCardCVV
ADD MASKED WITH(FUNCTION='random(101, 999)');
GO

-- Select the data again
SELECT CustomerName,
	   CreditCardNumber,
	   CreditCardCVV
FROM dbo.CreditCards;
GO

-- Change the user I'm executing as
EXECUTE AS USER = 'maskeduser';
SELECT SUSER_NAME() AS SysUsername,
	   USER_NAME() AS Username;
SELECT CustomerName,
	   CreditCardNumber,
	   CreditCardCVV
FROM dbo.CreditCards;
REVERT;
GO

---------------------------------------------------------------
-- Granting unmask of data
---------------------------------------------------------------
GRANT UNMASK TO maskeduser;
GO

EXECUTE AS USER = 'maskeduser';
SELECT * FROM dbo.CreditCards;
REVERT
GO

REVOKE UNMASK TO maskeduser
GO

EXECUTE AS USER = 'maskeduser';
SELECT * FROM dbo.CreditCards;
REVERT
GO

---------------------------------------------------------------
-- Copying data
---------------------------------------------------------------
CREATE TABLE [dbo].[CreditCards_TEMP]
(
	[CustomerName]	   [VARCHAR](100) NULL,
	[IssuingCompany]   [VARCHAR](80)  NULL,
	[CreditCardNumber] [VARCHAR](40)  NULL,
	[CreditCardCVV]	   [SMALLINT]	  NULL
) ON [PRIMARY];
GO

GRANT INSERT ON dbo.CreditCards_TEMP TO maskeduser;
GO

EXECUTE AS USER = 'maskeduser';
INSERT INTO dbo.CreditCards_TEMP
(
	CustomerName,
	IssuingCompany,
	CreditCardNumber,
	CreditCardCVV
)
SELECT CustomerName,
	   IssuingCompany,
	   CreditCardNumber,
	   CreditCardCVV
FROM dbo.CreditCards;
REVERT

SELECT * FROM dbo.CreditCards_TEMP

---------------------------------------------------------------
-- Masked columns
---------------------------------------------------------------
SELECT OBJECT_NAME(object_id) TableName,
	   name ColumnName,
	   masking_function MaskFunction
FROM sys.masked_columns
ORDER BY TableName,
		 ColumnName;

---------------------------------------------------------------
-- Cleanup
---------------------------------------------------------------
ALTER TABLE dbo.CreditCards ALTER COLUMN CreditCardNumber DROP MASKED

ALTER TABLE dbo.CreditCards ALTER COLUMN CreditCardCVV DROP MASKED

ALTER TABLE dbo.People ALTER COLUMN EmailAddress DROP MASKED

DROP TABLE IF EXISTS dbo.CreditCards_TEMP