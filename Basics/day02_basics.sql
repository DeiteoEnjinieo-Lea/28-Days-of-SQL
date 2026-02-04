/*
This is Day 2 of my 28 day SQL Journey. I utilize AI to provide me with daily task similar to what I would be doing 
if I was currently working in the role that I am applying for which is an Entry Level SQL Engineer or Developer. 
To explain this, I go onto Indeed job boards looking for jobs with the qualifications that I meet and then a provide 
the following AI prompt:

Imagine you are extracting sales data from a legacy CRM into a staging table. 
Your goal is to retrieve only "Load-Ready" records while identifying data quality issues

In a real "enclave" environment, you cannot manually run a script every day. You must build 
an automated process that moves "cold" data (older than 1 year) into an Archive Table and 
then purges it from the Production Table to save space and speed up querie 

ORIGINAL CODE IS BELOW

-- TASK 1: Extract "Load-Ready" records
SELECT OrderID, CustomerID, OrderDate, TotalAmount
FROM Raw_Sales
WHERE TotalAmount IS NOT NULL 
  AND TotalAmount > 0 
  AND CustomerName NOT LIKE 'Test_%'
  AND OrderDate >= DATEADD(day, -30, GETDATE());
 -- TASK 2: Identify Duplicate OrderIDs 
SELECT OrderID, COUNT(*) as OrderQuantity
FROM Raw_Sales
GROUP BY OrderID
HAVING COUNT(*) > 1;
-- Create the Vault
SELECT *
INTO Archived_Sales
FROM Raw_Sales;
JOIN Archived_Sales ON Raw_Sales.OrderID=Archived_Sales.OrderID;
WHERE OrderDate >= DATEADD(year, -1, GETDATE());
-- Remove the entries that doesnt meet the requirements
DELETE FROM Raw_Sales
WHERE OrderDate >= DATEADD(year, -1, GETDATE());

COMMIT; -- Runs only if both above succeed

-- Create a View
CREATE VIEW v_All_Sales_Unified AS
SELECT * FROM Archived_Sales
UNION ALL 
SELECT * FROM Raw_Sales;
*/

--   Project: Data Lifecycle Management (DLM)
--   Description: Moves 'cold' records to archive and provide a unified view for customers.

IF OBJECT_ID('Archived_Sales', 'U') IS NULL 
    SELECT TOP 0 * INTO Archived_Sales FROM Raw_Sales;

-- The Archival Process (Maintenance Duty) - Creating the Vault
-- Try Catch = Try Except Python 
-- Execute Archival Transaction with Error Handling (The "Try-Except" Pattern)
BEGIN TRANSACTION;
    BEGIN TRY
        -- Move "Cold" data (Older than 1 year)
        INSERT INTO Archived_Sales
        SELECT * FROM Raw_Sales 
        WHERE OrderDate < DATEADD(year, -1, GETDATE()); -- this is day, year, month format

        -- Purge the moved data from Production
        DELETE FROM Raw_Sales 
        WHERE OrderDate < DATEADD(year, -1, GETDATE());

        COMMIT; -- Save Changes 
    END TRY
    BEGIN CATCH
        ROLLBACK; -- If something fails, undo everything to prevent data loss
    END CATCH;
-- Create the View (Facilitating data access)
-- Note: Views must be the first statement in a batch, so use 'GO'
GO
CREATE OR ALTER VIEW v_All_Sales_Unified AS
SELECT *, 'ARCHIVED' AS Source FROM Archived_Sales -- Source is the Column Alias. You are naming this new "virtual" column
UNION ALL 
SELECT *, 'LIVE' AS Source FROM Raw_Sales; -- -- Using String Literals ('LIVE', 'ARCHIVED') as source indicators

/*
when you combine multiple tables into one View, the user loses track of where 
the data actually lives. Adding that extra column tells the user exactly which 
"enclave" the record came from.

*/