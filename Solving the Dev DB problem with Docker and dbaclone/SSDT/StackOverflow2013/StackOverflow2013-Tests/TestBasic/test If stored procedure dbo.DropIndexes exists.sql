/*
Description:
Test if the stored procedure dbo.DropIndexes exists

Changes:
Date		Who					Notes
----------	---					--------------------------------------------------------------
5/14/2020	sstad				Initial test
*/
CREATE PROCEDURE [TestBasic].[test If stored procedure dbo.DropIndexes exists]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSERT -------------------------------------------------
    EXEC tSQLt.AssertObjectExists @ObjectName = N'dbo.DropIndexes';
END;
