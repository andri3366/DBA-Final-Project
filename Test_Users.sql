/*
CST 2102 - Test Queries
Purpose:
- To verify if:
- Admin user = full access
- Normal users = read-only access
*/

Use HospitalDB;
GO

-- Read
SELECT TOP 5 * FROM Patient;

-- Insert
INSERT INTO Patient (PatientID, FirstName, LastName)
VALUES (9999, 'Test', 'Test');

SELECT TOP 1 *
FROM Patient
WHERE PatientID = 9999;

-- Update 
UPDATE Patient
SET FirstName = 'Edit'
WHERE PatientID = 9999;

SELECT TOP 1 *
FROM Patient
WHERE PatientID = 9999;

-- Delete
DELETE FROM Patient
WHERE PatientID = 9999;

SELECT TOP 1 *
FROM Patient
WHERE PatientID = 9999;