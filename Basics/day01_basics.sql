

/*
This is Day 1 of my 28 day SQL Journey. I utilize AI to provide me with daily task similar to what I would be doing 
if I was currently working in the role that I am applying for which is an Entry Level SQL Engineer or Developer. 
To explain this, I go onto Indeed job boards looking for jobs with the qualifications that I meet and then a provide 
the following AI prompt:

Today I am starting my journey of building a portfolio to become a SQL Engineer 
based on this job description give me an assignment for day that would align 
with this role: 

Insert Job Description

The AI analyzes the responsbilites and provide me with the task for the day. 
For today here is what we will be working on:

Assignment: The "Clinic Ledger" Database Design

In finance and healthcare, "orphan records" (data with no owner) can be a legal or financial liability. 
Your task today is to design a schema that connects patients to their financial billing records. 

1. Create the Schema (DDL)

Design two tables with proper primary and foreign keys to ensure data integrity: 
Patients Table: Include PatientID (Primary Key), FirstName, LastName, and DateOfBirth.
Billing Table: Include BillID (Primary Key), PatientID (Foreign Key), ServiceDate, and Amount. 

2. Populate & Query (DML)

Insert Data: Add 5 patients and 3 billing records.
The Join Task: Write an INNER JOIN query to list patients who have an active bill.
The "Orphan" Check: Write a LEFT JOIN query to find patients who have no bills. This is a 
common task for Healthcare SQL Developers cleaning up clinical reporting data. 

3. Soft Skill Component

The job description emphasizes Interpersonal Skills. 

Task: Document your code. Write a 3-sentence summary explaining why a Foreign Key is essential for 
a bank or a hospital. Imagine explaining this to a non-technical manager. 
*/
CREATE TABLE Patients(
  ID INT PRIMARY KEY,
  FirstName VARCHAR(100), 
  LastName VARCHAR(100),
  DateOfBirth DATE
  );

CREATE TABLE Billing(
  BillID INT PRIMARY KEY,
  PatientID INT,
  ServiceDate DATE,
  Amount DECIMAL(10, 2),
  FOREIGN KEY (PatientID) REFERENCES Patients(ID)
  );

INSERT INTO Patients 
(ID, FirstName, LastName, DateOfBirth) 
VALUES 
(3456701,'John','Doe', '1994-01-30'),
(9158094,'Akulina','Hardy', '1987-07-12'),
(9122157,'Evelina','Kovac', '1977-12-22'),
(9231511,'Jonatan','Gass', '1999-04-17'),
(8681284,'Miguel','Luna', '2013-03-08');

INSERT INTO Billing 
(BillID,PatientID,ServiceDate,Amount)
VALUES
(560925690,9122157,'2019-04-18',22.069),
(947704766,9231511,'2022-07-15',406.00),
(354151047,9158094,'2021-07-23',119.00);

-- Query to find patients WITH BILLS
SELECT p.FirstName, p.LastName, b.Amount 
FROM Billing b
INNER JOIN Patients p ON (b.PatientID=p.ID)
WHERE b.Amount IS NOT NULL;

-- Query to find patients WITHOUT BILLS
SELECT p.FirstName, p.LastName
FROM Patients p
LEFT JOIN Billing b ON p.ID = b.PatientID
WHERE b.BillID IS NULL;

/*Write a 3-sentence summary explaining why a Foreign Key is essential for a bank or a hospital.
 Imagine explaining this to a non-technical manager
 
 Because all data within tables is relational meaning there is some
 connection between,there needs to be a way to establish that connection.
 We do this via keys, these are unique indentifers to specific rows of data
 that allows us to retrieve what we are looking for. These keys come in two 
 types as the primary key the main table and foreign key, its data that is identical to 
 the data in the main table and we pull it with the keys. The keys matching is vital to 
 retrieving the information.

 */
