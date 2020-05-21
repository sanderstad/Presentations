/*
Description:
Test if the table dbo.Posts exists

Changes:
Date		Who					Notes
----------	---					--------------------------------------------------------------
3/3/2020	sstad				Initial test
*/
CREATE PROCEDURE [TestBasic].[test If table dbo.Posts exists]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSERT -------------------------------------------------
    EXEC tSQLt.AssertObjectExists @ObjectName = N'dbo.Posts';
END;
