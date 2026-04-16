/*
CST 2102 - HOSPITAL DCL
Purpose:
- Create 1 admin and 5 normal users
- Admin = full access
- Normal users = read-only access
*/

-- Use Hospital DB
USE HospitalDB;
GO

-- Remove existing users in DB level
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_admin')
    DROP USER hospital_admin;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'nurse_user')
    DROP USER nurse_user;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'receptionist_user')
    DROP USER receptionist_user;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'technician_user')
    DROP USER technician_user;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'doctor_user')
    DROP USER doctor_user;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'operations_admin_user')
    DROP USER operations_admin_user;
GO

-- Switch to master - logins are in server level
USE master;
GO

-- Remove existing logins
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_admin')
    DROP LOGIN hospital_admin;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'nurse_user')
    DROP LOGIN nurse_user;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'receptionist_user')
    DROP LOGIN receptionist_user;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'technician_user')
    DROP LOGIN technician_user;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'doctor_user')
    DROP LOGIN doctor_user;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'operations_admin_user')
    DROP LOGIN operations_admin_user;
GO

-- Create logins
-- NOTE: for the project the pws are hardcoded 
CREATE LOGIN hospital_admin WITH PASSWORD = 'DbprojectAdmin';
GO
CREATE LOGIN nurse_user WITH PASSWORD = 'DbprojectNurse';
GO
CREATE LOGIN receptionist_user WITH PASSWORD = 'DbprojectReceptionist';
GO
CREATE LOGIN technician_user WITH PASSWORD = 'DbprojectTechnician';
GO
CREATE LOGIN doctor_user WITH PASSWORD = 'DbprojectDoctor';
GO
CREATE LOGIN operations_admin_user WITH PASSWORD = 'DbprojectOperationsAdmin';
GO

-- Switch back to Hospital DB
USE HospitalDB;
GO

-- Map logins
CREATE USER hospital_admin FOR LOGIN hospital_admin;
GO
CREATE USER nurse_user FOR LOGIN nurse_user;
GO
CREATE USER receptionist_user FOR LOGIN receptionist_user;
GO
CREATE USER technician_user FOR LOGIN technician_user;
GO
CREATE USER doctor_user FOR LOGIN doctor_user;
GO
CREATE USER operations_admin_user FOR LOGIN operations_admin_user;
GO

-- Assign roles
-- Hospital Admin user given db_owner (built-in role) = full access
ALTER ROLE db_owner ADD MEMBER hospital_admin;
GO

-- Hospital users given db_datareader (built-in role) = read-only acess
ALTER ROLE db_datareader ADD MEMBER nurse_user;
GO
ALTER ROLE db_datareader ADD MEMBER receptionist_user;
GO
ALTER ROLE db_datareader ADD MEMBER technician_user;
GO
ALTER ROLE db_datareader ADD MEMBER doctor_user;
GO
ALTER ROLE db_datareader ADD MEMBER operations_admin_user;
GO

-- List user names and role names
SELECT USER_NAME(member_principal_id) AS UserName, USER_NAME(role_principal_id) AS RoleName
FROM sys.database_role_members;
GO