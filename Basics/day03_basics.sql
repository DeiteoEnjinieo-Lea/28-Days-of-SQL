/*
Basic of SQL invovles CRUD Operations

Create  
Read 
Update  
Delete 

CRUD - Create, Read, Update, Delete
Create
- Create Databases, Tables or Views
    table and column names, type of data column will store, size or amount of data stored in the column
- Users, Permissions and Security Groups
Read
- Example: SELECT statements
Update
- Amend existing database records
Delete
- Deleting records if permission allows
*/

CREATE TABLE unique_tblname(
    test_date date, 
    test_name varchar(20), -- char limit
    test_int int
) -- column name, data type, size

-- Create the table
CREATE TABLE results (
	-- Create track column
	track VARCHAR(200),
    -- Create artist column
	artist VARCHAR(120),
    -- Create album column
	album VARCHAR(160),
    -- Create integer column
    track_length_mins INT
	);

-- Select all columns from the table
SELECT 
  track, 
  artist, 
  album, 
  track_length_mins 
FROM 
  results;

-- INSERT into Table
INSERT INTO table_name (col1,col2,col3)
VALUES
('value1','value2','value3')

-- INSERT SELECT
INSERT INTO table_name (col1,col2,col3)
SELECT
    col1,
    col2,
    col3
FROM other_table
WHERE 
-- conditions apply

-- UPDATE
UPDATE table_name
SET column = value
WHERE 
-- Condition(s);

UPDATE table_name
SET
    col1 = value1,
    col2 = value2
WHERE
-- Condition(s);

-- DELETE
DELETE 
FROM table_name
WHERE 
-- Conditions
TRUNCATE TABLE table_name
-- this doesnt accept or require a wHERE clause, it will remove all data 
-- from all columns at once

-- Create the INSERT table
CREATE TABLE tracks(
	-- Create track column
	track VARCHAR(200),
    -- Create album column
  	album VARCHAR(160),
	-- Create track_length_mins column
	track_length_mins INT
);
-- Select all columns from the new table
SELECT 
  * 
FROM 
  tracks;

-- Create the table
CREATE TABLE tracks(
  -- Create track column
  track VARCHAR(200), 
  -- Create album column
  album VARCHAR(160), 
  -- Create track_length_mins column
  track_length_mins INT
);
-- Complete the statement to enter the data to the table         
INSERT INTO tracks
-- Specify the destination columns
(track, album, track_length_mins)
-- Insert the appropriate values for track, album and track length
VALUES
  ('Basket Case','Dookie', 3);
-- Select all columns from the new table
SELECT 
  *
FROM 
  tracks;

-- UPDATE 
-- Select the album
SELECT 
  title 
FROM 
  album
WHERE 
  album_id = 213;
-- Run the query
-- UPDATE the album table
UPDATE
  album
-- SET the new title    
SET 
  title = 'Pure Cult: The Best Of The Cult'
WHERE album_id = 213;

-- DELETE 
-- Run the query
SELECT 
  * 
FROM 
  album 
  -- DELETE the record
DELETE FROM 
  album
WHERE 
  album_id = 1 
  -- Run the query again
SELECT 
  * 
FROM 
  album;

-- Variables are your placeholders, similar to OOP using this to 
-- run your queries eliminate unnecessary entry and simple update
-- to create variable in SQL Server you declare it to init

DECLARE @ 
-- integer variable
DECLARE @test_int INT

-- varchar variable
DECLARE @my_artist VARCHAR(100)

-- to assign a value to a variable, we use keyword SET immediately after
-- the DECLARE statement
DECLARE @test_int INT

SET @test_int = 5

-- variable character
DECLARE @my_artist VARCHAR(100)

SET @my_artist = 'AC/DC'

-- Declare Two Variables
DECLARE @my_artist VARCHAR(100)
DECLARE @my_album VARCHAR(300)

SET @my_artist = 'AC/DC'
SET @my_album = 'Let There Be Rock';

SELECT -- 
FROM -- 
WHERE artist = @my_artist
AND album = @my_album;

DECLARE @my_artist VARCHAR(100)
DECLARE @my_album VARCHAR(300);

SET @my_artist = 'U2'
SET @my_album = 'Pop';

SELECT --
FROM -- 
WHERE artist = @my_artist
AND album = @my_album;

-- Temporary Tables Example
SELECT
    col1,
    col2,
    col3 INTO #my_temp_table
    /*
    
    Between Select + From using the INTO keyword with hash table_name
    #my_temp_table exists until connection or session ends, or we manually remove it with 
    The DROP TABLE statement 
    
    */
FROM my_existing_table
WHERE
-- Conditions

DROP TABLE #my_temp_table
-- Remove table manually

-- EXAMPLE
-- DECLARE and SET a variable
-- Declare the variable @region, and specify the data type of the variable
DECLARE @region VARCHAR(10)

-- Update the variable value
SET @region = 'RFC'

SELECT description,
       nerc_region,
       demand_loss_mw,
       affected_customers
FROM grid
WHERE nerc_region = @region;

-- Declare multiple variables
-- Declare @start
DECLARE @start DATE

-- Declare @stop
DECLARE @stop DATE

-- Declare @affected
DECLARE @affected INT

-- SET @start to '2014-01-24'
SET @start = '2014-01-24'

-- SET @stop to '2014-07-02'
SET @stop = '2014-07-02'

-- Set @affected to 5000
SET @affected = 5000

/*
Retrieve all rows where event_date is BETWEEN @start and @stop and affected_customers is 
greater than or equal to @affected. Putting it all together
*/

-- Declare your variables
DECLARE @start DATE
DECLARE @stop DATE
DECLARE @affected INT;
-- SET the relevant values for each variable
SET @start = '2014-01-24'
SET @stop  = '2014-07-02'
SET @affected =  5000 ;

SELECT 
  description,
  nerc_region,
  demand_loss_mw,
  affected_customers
FROM 
  grid
-- Specify the date range of the event_date and the value for @affected
WHERE event_date BETWEEN @start AND @stop
AND affected_customers >= @affected;

/*
Sometimes you want to save the results of a query aka search so you can 
do more work with the data. You can save the results in a temp
table that remains in the database until SQL Server is restarted
*/
SELECT  album.title AS album_title,
  artist.name as artist,
  MAX(track.milliseconds / (1000 * 60) % 60 ) AS max_track_length_mins
-- Name the temp table #maxtracks
INTO #maxtracks
FROM album
-- Join album to artist using artist_id
INNER JOIN artist ON album.artist_id = artist.artist_id
-- Join track to album using album_id
INNER JOIN track ON album.album_id = track.album_id
GROUP BY artist.artist_id, album.title, artist.name,album.album_id
-- Run the final SELECT query to retrieve the results from the temporary table
SELECT album_title, artist, max_track_length_mins
FROM  #maxtracks
ORDER BY max_track_length_mins DESC, artist;



