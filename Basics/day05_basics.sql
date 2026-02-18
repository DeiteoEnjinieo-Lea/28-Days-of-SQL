-- Counts and Totals in T-SQL 
-- Write a query that returns an aggregation 
SELECT MixDesc, SUM(Quantity) AS Total
FROM Shipments
-- Group by the relevant column
GROUP BY MixDesc

-- Count the number of rows by MixDesc
SELECT MixDesc, COUNT(*)
FROM Shipments
GROUP BY MixDesc

-- when handling dates in T-SQL, follow the format MM-DD-YYYY. There are two main functions
-- DATEDIFF or DATEADD, you must provided the date elements and the dates used

-- Return the difference in OrderDate and ShipDate, DATEDIFF(datepart,date1,date2)
SELECT OrderDate, ShipDate, 
       DATEDIFF(DD, OrderDate, ShipDate) AS Duration
FROM Shipments

-- DATEADD ( datepart , number , date )
-- Return the DeliveryDate as 5 days after the ShipDate
SELECT OrderDate, 
       DATEADD(DD,5,ShipDate) AS DeliveryDate
FROM Shipments

-- Rounding numbers in T-SQL | ROUND(number,length [,function])
-- Round Cost to the nearest dollar
SELECT Cost, 
       ROUND(Cost,0) AS RoundedCost
FROM Shipments

-- TRUNCATING | ROUND(value, decimal_places, 1)
-- Truncate cost to whole number
SELECT Cost, 
       ROUND(Cost,0,1) AS TruncateCost
FROM Shipments

-- absolute value is the non negative value of a number 
-- Return the absolute value of DeliveryWeight
SELECT DeliveryWeight,
       ABS(DeliveryWeight) AS AbsoluteValue
FROM Shipments

-- MTH Fx
-- Return the square and square root of WeightValue
SELECT WeightValue, 
       SQUARE(WeightValue) AS WeightSquare, 
       SQRT(WeightValue) AS WeightSqrt
FROM Shipments

-- Variables are needed to set values and must be declared or instatiated
-- must use @ character to do so: DECLARE @variablename data_type i.e. JAVA
-- VARCHAR is alphanumeric, INT is numeric, DECIMAL is float DECIMAL(p,s) or NUMERIC(p,s)

-- Declare Snack as a VARCHAR with length 10
DECLARE @Snack VARCHAR(10)

-- Set the value 
SET @Snack = 'Cookies'

-- Show the value
SELECT @Snack

-- Create Candy
DECLARE @Snack VARCHAR(10)

SET @Snack = 'Candy'

SELECT @Snack

/*

WHILE uses the same logic as in any programming structure, to iterate as long as the conditions exists
or TRUE. To get out of that loop, the condition must be met or it can be broken using a BREAK or keeping going 
with the usage of CONTINUE. This can be seen in a DO WHILE setup as well 

*/

-- Declare the var ctr
DECLARE @ctr INT

-- assign value
SET @ctr = 1

-- provide the conditions 
WHILE @ctr < 10
    -- start the LOOP
    BEGIN
        -- keep increment the value of var
        SET @ctr = @ctr + 1 -- x+=1 in python 
        -- END LOOP
    END
-- View the value afterwards
SELECT @ctr

-- BREAKING THE LOOP
DECLARE @ctr INT

SET @ctr = 1

WHILE @ctr < 10
    -- start the LOOP
    BEGIN

        SET @ctr = @ctr + 1 -- x+=1 in python 
        -- if ctr equals 4
        IF @ctr = 4
            -- BREAK LOOP if condition is met
            BREAK
        -- END LOOP
    END

SELECT @ctr

-- creating variables and using variables
-- Declare the variable (a SQL Command, the var name, the datatype)
DECLARE @counter INT

-- Declare the variable (a SQL Command, the var name, the datatype)
DECLARE @counter INT 

-- Set the counter to 20
SET @counter = 20

-- Select and increment the counter by one 
SET @counter = @counter + 1

-- Print the variable
SELECT @counter

-- Creating a WHILE loop
DECLARE @counter INT 
SET @counter = 20

-- Create a loop, condition is enforced as long as counter is below 30
WHILE @counter < 30

-- Loop code starting point
BEGIN
	SELECT @counter = @counter + 1
-- Loop finish
END

-- Check the value of the variable
SELECT @counter

-- DERIVED TABLES are queries acting as temporary tables, held within main query
-- specified in the FROM clause, contain intermediate calculation or different joins 
-- than main query
-- Think of it as distributed processing for queries 

SELECT a.* FROM Kidney a
-- This derived table computes the Average age joined to the actual table
JOIN (SELECT AVG(Age) AS AverageAge 
      FROM Kidney) b
ON a.Age = b.AverageAge

-- A derived table is a query which is used in the place of a table.
SELECT a.RecordId, a.Age, a.BloodGlucoseRandom, 
-- Select maximum glucose value (use colname from derived table)    
       b.MaxGlucose
FROM Kidney a
-- Join to derived table
JOIN(SELECT Age, MAX(BloodGlucoseRandom) AS MaxGlucose FROM Kidney GROUP BY Age) b
-- Join on Age
ON a.Age = b.Age

-- QUERIES with Derived Tables
SELECT *
FROM Kidney a
-- Create derived table: select age, max blood pressure from kidney grouped by age
JOIN (SELECT Age, MAX (BloodPressure) AS MaxBloodPressure FROM Kidney GROUP BY Age) b
-- JOIN on BloodPressure equal to MaxBloodPressure
ON a.BloodPressure = b.MaxBloodPressure
-- Join on Age
AND a.Age = b.Age

--CTE ala Common Table Expressions, another derived table
--CTE defintions start with the keyword WITH
-- followed by the CTE names and the columns it contains 
WITH CTEName (Col1,Col2)
AS
-- Define CTE query
(
    -- The two columns from the definition above
    SELECT Col1, Col2
    FROM TableName
)

-- Create CTE to get the MAX BP by Age
WITH BloodPressureAge(Age,MaxBloodPressure)
AS
(SELECT Age, MAX(BloodPressure) AS MaxBloodPressure
 FROM Kidney
 GROUP BY Age)

-- Create a query to use the CTE as a table 
SELECT a.Age, MIN(a.BloodPressure), b.MaxBloodPressure
FROM Kidney a 
-- Join the CTE with the table
JOIN BloodPressureAge b 
    ON a.Age = b.Age
GROUP BY a.Age, b.MaxBloodPressure

-- CREATING CTES
-- Specify the keyowrds to create the CTE
WITH BloodGlucoseRandom (MaxGlucose) 
AS (SELECT MAX(BloodGlucoseRandom) AS MaxGlucose FROM Kidney)

SELECT a.Age, b.MaxGlucose
FROM Kidney a
-- Join the CTE on blood glucose equal to max blood glucose
JOIN BloodGlucoseRandom b
ON MaxGlucose = BloodGlucoseRandom

-- PART 2
-- Create the CTE
WITH BloodPressure (MaxBloodPressure) 
AS (SELECT MAX(BloodPressure) AS MaxBloodPressure FROM Kidney)

SELECT *
FROM Kidney a
-- Join the CTE  
JOIN BloodPressure b
ON a.BloodPressure = b.MaxBloodPressure

-- WINDOWS FUNCTIONS | Grouping Data in T-SQL 
SELECT SalesPerson, SalesYear, CurrentQuota, ModifiedDate
FROM SaleGoal
WHERE Sale = 2011;

-- create the windiw with OVER clause
-- PARTITION BY creates the frame, dont include it the frame is the entire table
-- arrage results, use ORDER BY
-- allows aggregations to be created at the same time as the window

-- Create a Window data grouping 
OVER (PARTITION BY SalesYear ORDER BY SalesYear)

-- ALL TOGETHER
SELECT SalesPerson, SalesYear, CurrentQuota
       SUM(CurrentQuota)
       OVER (PARTITION BY SalesYear) AS YearlyTotal,
       ModifiedDate AS ModDate 
FROM SaleGoal

-- Window functions with aggregations (I)
SELECT OrderID, TerritoryName, 
       -- Total price for each partition
       SUM(OrderPrice)
       -- Create the window and partitions
       OVER (PARTITION BY TerritoryName) AS TotalPrice
FROM Orders
-- CONT'D
SELECT OrderID, TerritoryName, 
       -- Number of rows per partition
       COUNT(*) 
       -- Create the window and partitions
       OVER(PARTITION BY TerritoryName) AS TotalOrders
FROM Orders
-- FIRST_VALUE returns 1st value in windows
-- LAST_VALUE retunrs last valie in windows

SELECT SalesPerson, SalesYear, CurrentQuota,
-- Select the columns
-- First value from every window
    FIRST_VALUE(CurrentQuota)
    OVER(PARTITION BY SalesYear ORDER BY ModifiedDate) AS StartQuota,
-- Last value from every window
   LAST_VALUE(CurrentQuota)
   OVER(PARTITION BY SalesYear ORDER BY ModifiedDate) AS EndQuota,
   ModifiedDate as ModDate
FROM SaleGoal

-- LEAD, compare val of current row to value next row in window
SELECT SalesPerson, SalesYear, CurrentQuota,
-- Create a window function to get the values from the next row
    LEAD(CurrentQuota)
    OVER(PARTITION BY SalesYear ORDER BY ModifiedDate) AS NextQuota,
    ModifiedDate AS ModDate
FROM SaleGoal

-- LAG
SELECT SalesPerson, SalesYear, CurrentQuota,
-- Create a window fx to get the value from the previous row
    LAG(CurrentQuota)
    OVER(PARTITION BY SalesYear ORDER BY ModifiedDate) AS PreviousQuota,
    ModifiedDate AS ModDate
FROM SaleGoal

-- First Value Window
SELECT TerritoryName, OrderDate, 
       -- Select the first value in each partition
       FIRST_VALUE(OrderDate) 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS FirstOrder
FROM Orders

-- Previous and next values
SELECT TerritoryName, OrderDate, 
       -- Specify the previous OrderDate in the window, LAG previous 
       LAG(OrderDate) 
       -- Over the window, partition by territory & order by order date
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS PreviousOrder,
       -- Specify the next OrderDate in the window, LEAD next
       LEAD(OrderDate) 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS NextOrder
FROM Orders

-- Focusing on HealthTech: Practice PySpark Fundamentals Advanced SQL Integrate Metadata Standards: SNOMED LOINC HL7 
-- Build Clinical Data Pipeline -  Azure Health Data Services Key Components

-- ROW_NUMBER creates a numeric index for entries | Creating running totals
SELECT TerritoryName, OrderDate, 
       -- Create a running total
       SUM(OrderPrice)
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS TerritoryTotal	  
FROM Orders

--Numbered Index
SELECT TerritoryName, OrderDate, 
       -- Assign a row number
       ROW_NUMBER() 
       -- Create the partitions and arrange the rows
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS OrderCount
FROM Orders

-- Calculating standard deviation
SELECT OrderDate, TerritoryName, 
       -- Calculate the standard deviation
	   STDEV(OrderPrice)
       OVER(PARTITION BY TerritoryName ORDER BY OrderDate) AS StdDevPrice	  
FROM Orders

-- Calculating MODE
-- Create a CTE Called ModePrice which contains two columns
WITH ModePrice(OrderPrice, UnitPriceFrequency)
AS
(
	SELECT OrderPrice, 
	ROW_NUMBER() 
	OVER(PARTITION BY OrderPrice ORDER BY OrderPrice) AS UnitPriceFrequency
	FROM Orders 
)

-- Select everything from the CTE
SELECT * FROM ModePrice

-- CONT'D
-- CTE from the previous exercise
WITH ModePrice (OrderPrice, UnitPriceFrequency)
AS
(
	SELECT OrderPrice,
	ROW_NUMBER() 
    OVER (PARTITION BY OrderPrice ORDER BY OrderPrice) AS UnitPriceFrequency
	FROM Orders
)

-- Select the order price from the CTE
SELECT OrderPrice AS ModeOrderPrice
FROM ModePrice
-- Select the maximum UnitPriceFrequency from the CTE
WHERE UnitPriceFrequency IN (SELECT MAX(UnitPriceFrequency) FROM ModePrice)

/*
To wrap up your intermediate T-SQL lesson, here is a practical assignment centered on a Customer Support Ticketing System. 
This scenario will require you to apply window functions for reporting and CHECK constraints for data integrity

The Scenario: Support Ticket Analysis
You are a database engineer for a tech company. You need to ensure that the support tickets table only accepts valid data 
and then write a query to analyze the "lifecycle" of tickets for each customer
*/

-- Create Table: Create a table named SupportTickets that enforces the following business rules to reject "bad" data
-- Task 1: Schema Enforcement with CHECK Constraints
-- Use AI to streamline the process

/*
AI PROMPT:
Write a T-SQL script to create a table with the following fields: Ticket ID, Ticket Status, Priority Level, Dates, Issue. 
Ticket ID is the Primary Key, Ticket Status is varchar, Priority Level is int, Dates is Date, Issue is varchar.
*/

CREATE TABLE SupportTickets (
    Ticket_ID INT IDENTITY(1,1) PRIMARY KEY,
    Ticket_Status VARCHAR(50) NOT NULL,
    Priority_Level INT NOT NULL,
    Ticket_Date DATE NOT NULL,
    Issue VARCHAR(MAX) NOT NULL
);

-- Unfamilar with using CHECK constraints, asked for AI Assistance to fix the table
ALTER TABLE SupportTickets
ADD CONSTRAINT CHK_TicketStatus
CHECK (Ticket_Status IN ('Open','In Progress','Closed'));

-- CHECK constraints | Priority Level: Must be an integer between 1 and 5 (1 = Low, 5 = Critical)
ALTER TABLE SupportTickets
ADD CONSTRAINT CHK_Priority_Level
CHECK (CHK_Priority_Level BETWEEN 1 AND 5);

-- LAST CHECK constraints |The ClosedDate must be greater than or equal to the CreatedDate
-- Need to add two columns
ALTER TABLE SupportTickets
ADD CreatedDate DATE NOT NULL
ADD ClosedDate DATE NOT NULL;

-- ADD CHECK Constraint 
ALTER TABLE SupportTickets
ADD CONSTRAINT CHK_ClosedDate
CHECK (ClosedDate >= CreatedDate);

-- SUBMITTED TO AI FOR CHECKING AND CORRECTION
-- MODIFIED AND CORRECTED CODE SCRIPT
CREATE TABLE SupportTickets (
    Ticket_ID INT IDENTITY(1,1) PRIMARY KEY,
    Ticket_Status VARCHAR(50) NOT NULL,
    Priority_Level INT NOT NULL,
    Issue VARCHAR(MAX) NOT NULL,
    CreatedDate DATE NOT NULL,
    ClosedDate DATE NULL, -- Changed to NULL because a ticket isn't closed when created

    -- Rule 1: Must be Open, In Progress, or Closed
    CONSTRAINT CHK_TicketStatus 
        CHECK (Ticket_Status IN ('Open', 'In Progress', 'Closed')),

    -- Rule 2: Integer between 1 and 5
    CONSTRAINT CHK_Priority_Level 
        CHECK (Priority_Level BETWEEN 1 AND 5),

    -- Rule 3: ClosedDate must be >= CreatedDate
    CONSTRAINT CHK_ClosedDate 
        CHECK (ClosedDate >= CreatedDate)
);

-- TEST SCRIPT | This should fail!
INSERT INTO SupportTickets (Ticket_Status, Priority_Level, Issue, CreatedDate, ClosedDate)
VALUES ('Open', 10, 'Broken Printer', '2023-01-01', '2023-01-02');


-- Task 2: Window Function Analysis
-- Assume your table is populated with ticket data. Write a single query 
-- that returns every ticket and adds the following calculated columns:

SELECT *
ROW_NUMBER(),
FIRST_VALUE(Issue),
OVER (PARTITION BY ROW_NUMBER ORDER BY CreatedDate) AS Original_Issue,
LAST_VALUE(Issue),
OVER (PARTITION BY ROW_NUMBER ORDER BY ClosedDate) AS Lastest_Update
FROM SupportTickets;

-- Issues with provided script and changes needed per AI Checking
-- To specify issues by customer, need a CustomerID

ALTER TABLE SupportTickets ADD Customer_ID INT;

-- Query
SELECT 
    SupportTickets.*, -- This returns every original column from the table
    
    -- 1. Customer Sequence
    ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY CreatedDate ASC) AS Customer_Sequence,
    -- 2. The Original Issue
    FIRST_VALUE(Issue) OVER ( PARTITION BY Customer_ID ORDER BY CreatedDate ASC) AS Original_Issue,
    -- 3. The Latest Update 
    LAST_VALUE(Issue) OVER (PARTITION BY Customer_ID ORDER BY CreatedDate ASC
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS Latest_Update

FROM SupportTickets;

-- You must use the column name (Priority_Level) inside the parentheses, not the name of the constraint. FYI!
