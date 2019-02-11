---------------------------------------------------------------
-- How DDM doesn't work
---------------------------------------------------------------
ALTER TABLE dbo.CreditCards
ALTER COLUMN CreditCardCVV ADD MASKED WITH (FUNCTION ='default()')
GO

EXECUTE AS USER = 'maskeduser';

SELECT SUSER_NAME() AS SysUsername, USER_NAME() AS Username;

SELECT * FROM dbo.CreditCards WHERE CreditCardCVV = 477

REVERT;
GO

ALTER TABLE dbo.CreditCards
ALTER COLUMN CreditCardCVV DROP MASKED