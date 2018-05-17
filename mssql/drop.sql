This query prints DROP TABLE query then you use results to drop tables manually

USER [select a database]
GO
SELECT 'DROP TABLE IF EXISTS dbo.' + name + ';' FROM sys.tables
GO

====================================================================================

This query prints DROP VIEW query then you use results to drop views manually

USER [select a database]
GO
SELECT 'DROP VIEW IF EXISTS dbo.' + name + ';' FROM sys.views
GO

====================================================================================

This query prints FOREIGN KEY query then you use results to drop views manually

USER [select a database]
GO
SELECT 'ALTER TABLE ' + Table_Name  +' DROP CONSTRAINT ' + Constraint_Name FROM Information_Schema.CONSTRAINT_TABLE_USAGE
GO
