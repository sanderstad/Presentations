/*
Description:
Test if the database has the correct collation

Changes:
Date		Who					Notes
----------	---					--------------------------------------------------------------
3/3/2020	sstad				Initial test
*/
CREATE PROCEDURE [TestBasic].[test If database has correct collation]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSEMBLE -----------------------------------------------

    DECLARE @expected VARCHAR(255),
        @actual VARCHAR(255)

    SELECT @expected = 'SQL_Latin1_General_CP1_CI_AS'

    ----- ACT ----------------------------------------------------

    SELECT @actual = CAST(DATABASEPROPERTYEX('StackOverflow2013', 'Collation') AS VARCHAR(255));

    ----- ASSERT -------------------------------------------------
    EXEC tSQLt.AssertEquals @expected, @actual;
END;
