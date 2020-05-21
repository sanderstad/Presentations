/*
Description:
Test if the table dbo.PostLinks exists

Changes:
Date		Who					Notes
----------	---					--------------------------------------------------------------
5/14/2020	sstad				Initial test
*/
CREATE PROCEDURE [TestBasic].[test If table dbo.PostLinks exists]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSERT -------------------------------------------------
    EXEC tSQLt.AssertObjectExists @ObjectName = N'dbo.PostLinks';
END;
