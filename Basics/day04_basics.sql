-- SELECT statement for T-SQL 
SELECT OrderDate, COUNT(OrderID) AS Orders
FROM Sales.SalesOrder
WHERE Status = 'Shipped'
GROUP BY OrderDate
HAVING COUNT(OrderID) > 1
ORDER BY OrderDate DESC;

/* The SELECT clause returns the OrderDate column, and the count of OrderID values, 
to which is assigns the name (or alias) Orders */

SELECT OrderDate, COUNT(OrderID) AS Orders -- alias column
FROM Sales.SalesOrder -- database.table dot notation T-SQL format
WHERE Status = 'Shipped' -- filter or conditions
GROUP BY OrderDate -- aggregate data based on the filter
HAVING COUNT(OrderID) > 1 -- filtering the aggregate data
ORDER BY OrderDate DESC; -- sorts the output

/*
Runtime Logic - Order in which the script runs
*/
FROM Sales.SalesOrder
WHERE Status = 'Shipped'
GROUP BY OrderDate 
HAVING COUNT(OrderID) > 1
SELECT OrderDate, COUNT(OrderID) AS Orders
ORDER BY OrderDate DESC;

-- SELECT ALL is called star within T-SQL 
SELECT * FROM Production.Product;

-- specific columns
SELECT ProductID, Name, ListPrice, StandardCost
FROM Production.Product;

-- Selecting expressions, you can use operators to do calculations
SELECT ProductID,
      Name + '(' + ProductNumber + ')', -- combine Name with Product Number
  ListPrice - StandardCost -- subtract ListPrice from StandardCost
FROM Production.Product;

-- you can you aliases for clear descriptors
SELECT ProductID AS ID, -- alias ID
      Name + '(' + ProductNumber + ')' AS ProductName, -- alias ProductName
  ListPrice - StandardCost AS Markup -- alias Markup
FROM Production.Product;

/*
FORMATTING RULES

Capitalize T-SQL keywords, like SELECT, FROM, AS, and so on. Capitalizing keywords is a commonly used 
convention that makes it easier to find each clause of a complex statement.

Start a new line for each major clause of a statement.

If the SELECT list contains more than a few columns, expressions, or aliases, consider listing each 
column on its own line.Indent lines containing subclauses or columns to make it clear which code 
belongs to each major clause.

*/

SELECT CAST(ProductID AS varchar(4)) + ': ' + Name AS ProductName
FROM Production.Product 
-- use cast to switch a datatype to another compatible format

SELECT CAST(Size AS integer) As NumericSize
FROM Production.Product;

/*
this will throw error. Error: Conversion failed when converting the nvarchar value 'M' to data type int.
use a TRYCAST Given that at least some of the values in the column are numeric, you might want to convert 
those values and ignore the others. You can use the TRY_CAST function to convert data types.
*/
SELECT TRY_CAST(Size AS integer) As NumericSize
FROM Production.Product;

-- the values that can be converted to a numeric data type are returned as decimal values
-- the incompatible values are returned as NULL, used to indicate that a value is unknown.
-- CAST is the ANSI standard SQL function for converting between data types
-- In Transact-SQL, you can also use the CONVERT function

SELECT CONVERT(varchar(4), ProductID) + ': ' + Name AS ProductName
FROM Production.Product;

/*
RESULT

ProductName

680: HL Road Frame - Black, 58

706: HL Road Frame - Red, 58

707: Sport-100 Helmet, Red

708: Sport-100 Helmet, Black

Like CAST, CONVERT has a TRY_CONVERT variant that returns NULL for incompatible values. 
But has better features like including Formatting when converting DATE and Numeric values => String
*/

SELECT SellStartDate,
       CONVERT(varchar(20), SellStartDate) AS StartDate,
       CONVERT(varchar(10), SellStartDate, 101) AS FormattedStartDate 
       -- T-SQL DATE format is with or without century which means 1 = mm/dd/yy or 101 = mm/dd/yyyy
       -- this format can be changed to ANSI or Country for international work
FROM SalesLT.Product;

-- PARSE function is designed to convert formatted strings that represent numeric or date/time values.
-- Like CAST and CONVERT, PARSE has a TRY_PARSE variant that returns incompatible values as NULL.
SELECT PARSE('01/01/2021' AS date) AS DateValue,
   PARSE('$199.99' AS money) AS MoneyValue;

-- For more info, see Transact-SQL reference documentation.
-- The STR function converts a numeric value to a varchar.
SELECT ProductID,  '$' + STR(ListPrice) AS Price
FROM Production.Product;

-- Data Exploration with EconomicIndicators Table
SELECT Country, Year, InternetUse, GDP
    ExportGoodsPercent, CellPhonesper100
FROM EconomicIndicators

-- Aggregate values for InternetUse
SELECT AVG(InternetUse) AS MeanInternetUse, MIN(InternetUse) AS MINInternet,
    MAX(InternetUse) AS MAXInternet
FROM EconomicIndicators
-- Apply a Filter
WHERE Country = "Solomon Islands"

-- Subtotaling Aggregrations into Groups with GROUP BY
SELECT Country, AVG(InternetUse) AS MeanInternetUse, 
       MIN(InternetUse) AS MINInternet,
       MAX(InternetUse) AS MAXInternet
FROM EconomicIndicators
GROUP BY Country

-- Cant use WHERE with GROUP BY as it will give you an error

GROUP BY
WHERE MAX(InternetUse) > 100
-- This throws an error

GROUP BY
HAVING MAX(InternetUse) > 100
-- This is how you filter with a GROUP BY

SELECT Country, AVG(InternetUse) AS MeanInternetUse,
MIN(GDP) AS SmallestGDP,
MAX(InternetUse) AS MAXInternetUse
FROM EconomicIndicators
GROUP BY Country
-- Having is the WHERE for Aggregations
HAVING MAX(InternetUse) > 100

-- Write a T-SQL query which will return the average, minimum, and maximum values
-- Calculate the average, minimum and maximum
SELECT AVG(DurationSeconds) AS Average, 
       MIN(DurationSeconds) AS Minimum, 
       MAX(DurationSeconds) AS Maximum
FROM Incidents

-- Calculate the aggregations by Shape
SELECT Shape,
       AVG(DurationSeconds) AS Average, 
       MIN(DurationSeconds) AS Minimum, 
       MAX(DurationSeconds) AS Maximum
FROM Incidents
GROUP BY Shape
-- Return records where minimum of DurationSeconds is greater than 1
HAVING MIN(DurationSeconds) > 1

-- Returning NO NULL Values in T-SQL
-- NULL is really a non-value, It's unknown.
SELECT Country, InternetUse, Year
FROM EconomicIndicators
WHERE InternetUse IS NOT NULL

-- Detecting NULLS in T-SQL 
SELECT Country, InternetUse, Year
FROM EconomicIndicators
WHERE InternetUse IS NULL 

-- A blank isnt the same as a NULL value
-- Can exclude blank values by returning rows 
-- only where length of the field is greater than 0
SELECT Country, GDP, Year
FROM EconomicIndicators
WHERE LEN(GDP) > 0

/* The ISNULL function takes two arguments. The first is an expression we are testing. 
If the value of that first argument is NULL, the function returns the second argument. 
If the first expression is not null, it is returned unchanged.*/

SELECT FirstName,
      ISNULL(MiddleName, 'None') AS MiddleIfAny,
      LastName
FROM Sales.Customer;

-- Can substitute a missing value with a placeholder
SELECT GDP, Country,
ISNULL(Country, 'Unknown') AS NewCountry
FROM EconomicIndicators

-- Substituting values from one column for another with ISNULL
-- The value substituted for NULL must be the same datatype as the expression being evaluated.
SELECT TradeGDPPercent, ImportGoodPercent, 
ISNULL(TradeGDPPercent,ImportGoodPercent) AS NewPercent
FROM EconomicIndicators

-- Substituting NULL values using COALESCE
-- COALESCE returns the first non-missing value

SELECT EmployeeID,
      COALESCE(HourlyRate * 40,
                WeeklySalary,
                Commission * SalesQty) AS WeeklyEarnings
FROM HR.Wages;

-- It will return the first expression in the list that is not NULL.
SELECT TradeGDPPercent, ImportGoodPercent,
COALESCE(TradeGDPPercent,ImportGoodPercent,'N/A') AS NewPercent
FROM EconomicIndicators

-- REMOVING MISSING VALUES
-- Return the specified columns
SELECT IncidentDateTime, IncidentState
FROM Incidents
-- Exclude all the missing values from IncidentState  
WHERE IncidentState IS NOT NULL;

-- Check the IncidentState column for missing values and replace them with the City column
SELECT IncidentState, ISNULL(IncidentState,City) AS Location
FROM Incidents
-- Filter to only return missing values from IncidentState
WHERE IncidentState IS NULL;

-- Replace missing values 
SELECT Country, COALESCE(Country, IncidentState, City) AS Location
FROM Incidents
WHERE Country IS NULL

-- The NULLIF function allows you to return NULL under certain conditions. 
-- This function has useful applications in areas such as data cleansing, 
-- when you wish to replace blank or placeholder characters with NULL.

SELECT SalesOrderID,
      ProductID,
      UnitPrice,
      NULLIF(UnitPriceDiscount, 0) AS Discount
FROM Sales.SalesOrderDetail;

-- NULLIF takes two arguments and returns NULL if they're equivalent. 
-- If they aren't equal, NULLIF returns the first argument.

/*
Binning Data With Case

The CASE statement which is used to evaluate conditions in a query
Use the CASE statement to check if a column contains a value and 
WHEN it does then replace the value with some other value of our 
choice, ELSE replace it with any other default value

4 keywords: CASE, WHEN, THEN and END

CASE
    WHEN boolean_exp THEN result_exp [...n]
    [ELSE else_result_exp]
END
*/

SELECT Continent, 
CASE WHEN Continent = 'Europe' OR Continent = 'Asia' THEN 'Eurasia'
    ELSE 'Other'
    END AS NewContinent
FROM EconomicIndicators

-- We are binning the data here into discrete groups; using CASE statements to create
-- value groups
SELECT Country, LifeExp,
CASE WHEN LifeExp < 30 THEN 1
     WHEN LifeExp > 29 AND LifeExp < 40 THEN 2
     WHEN LifeExp > 39 AND LifeExp < 50 THEN 3
     WHEN LifeExp > 49 AND LifeExp < 60 THEN 4
     ELSE 5
     END AS LifeExpGroup
FROM EconomicIndicators
WHERE Year = 2007

-- Using CASE Statements
SELECT Country, 
       CASE WHEN Country = 'US' THEN 'USA'
       ELSE 'International'
       END AS SourceCountry
FROM Incidents

-- Write a CASE statement to group the values in the DurationSeconds into 5 groups
-- Complete the syntax for cutting the duration into different cases
SELECT DurationSeconds, 
-- Start with the 2 TSQL keywords, and after the condition a TSQL word and a value
      CASE WHEN (DurationSeconds <= 120) THEN 1
-- The pattern repeats with the same keyword and after the condition the same word and next value          
       WHEN (DurationSeconds > 120 AND DurationSeconds <= 600) THEN 2
-- Use the same syntax here             
       WHEN (DurationSeconds > 601 AND DurationSeconds <= 1200) THEN 3
-- Use the same syntax here               
       WHEN (DurationSeconds > 1201 AND DurationSeconds <= 5000) THEN 4
-- Specify a value      
       ELSE 5 
       END AS SecondGroup   
FROM Incidents



