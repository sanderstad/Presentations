/*
Description:
Test if the table has the correct indexes

Changes:
Date		Who						Notes
----------	---						--------------------------------------------------------------
5/14/2020	sstad				Initial procedure
*/
CREATE PROCEDURE [TestBasic].[test If table dbo.Posts has the correct indexes]
AS
BEGIN
    SET NOCOUNT ON;

    ----- ASSEMBLE -----------------------------------------------
    -- Create the tables
    CREATE TABLE #actual
    (
        [IndexName] sysname NOT NULL
    );

    CREATE TABLE #expected
    (
        [IndexName] sysname NOT NULL
    );

    INSERT INTO #expected
    (
        IndexName
    )
    VALUES
	('PK_Posts_Id');

    ----- ACT ----------------------------------------------------

    INSERT INTO #actual
    (
        IndexName
    )
    SELECT ind.name
    FROM sys.indexes ind
        INNER JOIN sys.tables t
            ON ind.object_id = t.object_id
        INNER JOIN sys.schemas AS s
            ON s.schema_id = t.schema_id
    WHERE s.name = 'dbo'
        AND t.name = 'Posts'
        AND ind.Name IS NOT NULL;

    ----- ASSERT -------------------------------------------------

    -- Assert to have the same values
    EXEC tSQLt.AssertEqualsTable @Expected = '#expected', @Actual = '#actual';

END;
GO
