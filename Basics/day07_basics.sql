/*
Write a query to find all Linux assets in a hardware table
that havent been updated since 2023 using WHERE and IS NULL
*/
-- Day 7 Inventory Audit 
CREATE TABLE hardware (
    id INT PRIMARY KEY,
    asset_name VARCHAR(100),
    os_type VARCHAR(50),
    last_updated DATE
);
-- find assets that are Linux based and not updated whatsoever
SELECT * FROM hardware
WHERE os_type = "Linux" AND last_updated IS NULL;

-- find assets that are Linux based and not updated since 2023
SELECT * FROM hardware
WHERE os_type = "Linux" AND DATEDIFF(year, '2023-01-01', '2023-12-31') AS Asset_Update;

-- as a single query
SELECT *
FROM hardware
WHERE os_type = 'Linux' 
    AND DATEDIFF(year,'2023-01-01', '2023-12-31') AS Asset_Update;

-- CODE submitted for AI Code Review For Errors, Revised Version
-- NOTE: double quotes = table name, single quotes = string values
SELECT *
FROM hardware
WHERE os_type = 'Linux'
  AND (YEAR(last_updated) <= 2023 OR last_updated IS NULL);

-- more efficent method,using indexing on columns
SELECT *
FROM hardware
WHERE os_type = 'Linux' 
  AND (last_updated < '2024-01-01' OR last_updated IS NULL);

-- query based on Linux distribution
SELECT * 
FROM hardware
WHERE os_type IN ('Ubuntu', 'Red Hat', 'CentOS', 'Debian')
  AND (last_updated < '2024-01-01' OR last_updated IS NULL);

-- cleaner method of using pattern matching with CASE
-- retrieves all variations of Linux distros
SELECT 
    asset_name,
    last_updated,
    -- Simplify the OS name into a single "Distro" column
    CASE 
        WHEN os_type LIKE 'Ubuntu%' THEN 'Ubuntu'
        WHEN os_type LIKE 'Red Hat%' THEN 'RHEL'
        WHEN os_type LIKE 'CentOS%' THEN 'CentOS'
        ELSE 'Other Linux'
    END AS Distro
FROM hardware
WHERE (os_type LIKE 'Ubuntu%' 
    OR os_type LIKE 'Red Hat%' 
    OR os_type LIKE 'CentOS%')
  AND (last_updated < '2024-01-01' OR last_updated IS NULL);

-- now to expand on Linux distros, include more flavors 
-- create a table for other Linux OS
CREATE TABLE ref_linux_distros (
    distro_name VARCHAR(50) PRIMARY KEY
);
-- enter the distributions into the Reference Table
INSERT INTO ref_linux_distros(distro_name)
VALUES ('SUSE'), ('Mint'), ('Fedora'), ('Arch'), ('Slackware'), ('Kali Linux'), ('Debian'), ('Linux');

-- JOIN query to the Reference Table
-- INNER JOIN 
SELECT 
    HW.asset_name, 
    HW.os_type, 
    HW.last_updated
FROM hardware HW
INNER JOIN ref_linux_distros r 
    ON HW.os_type = r.distro_name
WHERE (HW.last_updated < '2024-01-01' OR HW.last_updated IS NULL);

-- OPTION 2 User Input of Distros based on Release #
SELECT DISTINCT
    HW.asset_name, 
    HW.os_type, 
    HW.last_updated
FROM hardware HW
INNER JOIN ref_linux_distros r 
    ON HW.os_type LIKE '%' + r.distro_name LIKE '%'
WHERE (HW.last_updated < '2024-01-01' OR HW.last_updated IS NULL);
