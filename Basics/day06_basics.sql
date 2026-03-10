/*

TRY_CAST is exactly as it states where your are trying to cast a specific data type to another format
 It either works or returns NULL.Use it for simple conversions (like String to Int) when you want 
 your code to be more portable to other database systems

TRY_CONVERT will just attempt to convert the dtype to another 
 It is specific to T-SQL.Does TYPE_CAST with a twist: here is exactly how it's formatted
 Use it whenever you are dealing with Dates, Times, or Money where the format matters - Style Parameter

AI PROMPT TYPECASTING

You have been given a Staging_Users table containing raw data imported from a CSV. 
The data is messy, and trying to move it into your production Users table currently causes 
the migration script to crash.

*/

-- CREATE TABLE
CREATE TABLE Staging_Users (
    StagingID INT IDENTITY(1,1),
    Raw_Name VARCHAR(100),
    Raw_Age VARCHAR(50),
    Raw_JoinDate VARCHAR(50),
    Raw_Balance VARCHAR(50)
);

INSERT INTO Staging_Users (Raw_Name, Raw_Age, Raw_JoinDate, Raw_Balance)
VALUES 
('Alice', '25', '01/15/2023', '150.50'),    -- Valid
('Bob', 'Thirty', '02/20/2023', '200.00'),   -- Invalid Age
('Charlie', '45', '2023-13-01', '50.00'),    -- Invalid Date (Month 13)
('Diana', '32', '03/10/2023', '1,200.00'),   -- Invalid Balance (Commas)
('Eve', NULL, '04/05/2023', '0.00');         -- Valid (NULL Age is okay)

-- TRY_CAST to verify if RAW_AGE can be converted to INT
SELECT * FROM Staging_Users
WHERE TRY_CAST(Raw_Age AS INT) IS NULL 
  AND Raw_Age IS NOT NULL;

-- TRY_CONVERT to verify if RAW_JoinDate can be converted to DATE
SELECT * FROM Staging_Users
WHERE TRY_CONVERT(DATE, RAW_JoinDate, 101) IS NULL 
  AND RAW_JoinDate IS NOT NULL;

--SELECT * FROM Staging_Users
--WHERE TRY_CAST(RAW_JoinDate AS DATE) IS NULL 
  --AND RAW_JoinDate IS NOT NULL;


-- TRY_CONVERT for Decimal format 
SELECT * FROM Staging_Users
WHERE TRY_CONVERT(DECIMAL(10,2),Raw_Balance) IS NULL
    AND Raw_Balance IS NOT NULL;

-- Reformat into one query instead of 3 seperate transactions
SELECT * 
FROM Staging_Users
WHERE 
    -- Check Age
    (TRY_CAST(Raw_Age AS INT) IS NULL AND Raw_Age IS NOT NULL)
    OR 
    -- Check JoinDate
    (TRY_CONVERT(DATE, Raw_JoinDate, 101) IS NULL AND Raw_JoinDate IS NOT NULL)
    OR 
    -- Check Balance
    (TRY_CONVERT(DECIMAL(10,2), Raw_Balance) IS NULL AND Raw_Balance IS NOT NULL);


