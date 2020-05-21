/*
Description:
Test if the table dbo.PostTypes exists

Changes:
Date		Who					Notes
----------	---					--------------------------------------------------------------
5/14/2020	sstad				Initial test
*/
CREATE PROCEDURE [TestBasic].[test If table dbo.PostTypes exists]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSERT -------------------------------------------------
    EXEC tSQLt.AssertObjectExists @ObjectName = N'dbo.PostTypes';
END;
