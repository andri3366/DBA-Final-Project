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

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_user1')
    DROP USER hospital_user1;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_user2')
    DROP USER hospital_user2;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_user3')
    DROP USER hospital_user3;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_user4')
    DROP USER hospital_user4;
GO

IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'hospital_user5')
    DROP USER hospital_user5;
GO

-- Switch to master - logins are in server level
USE master;
GO

-- Remove existing logins
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_admin')
    DROP LOGIN hospital_admin;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_user1')
    DROP LOGIN hospital_user1;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_user2')
    DROP LOGIN hospital_user2;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_user3')
    DROP LOGIN hospital_user3;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_user4')
    DROP LOGIN hospital_user4;
GO

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'hospital_user5')
    DROP LOGIN hospital_user5;
GO

-- Create logins
-- NOTE: for the project the pws are hardcoded 
CREATE LOGIN hospital_admin WITH PASSWORD = 'DbprojectAdmin';
GO
CREATE LOGIN hospital_user1 WITH PASSWORD = 'DbprojectUser1';
GO
CREATE LOGIN hospital_user2 WITH PASSWORD = 'DbprojectUser2';
GO
CREATE LOGIN hospital_user3 WITH PASSWORD = 'DbprojectUser3';
GO
CREATE LOGIN hospital_user4 WITH PASSWORD = 'DbprojectUser4';
GO
CREATE LOGIN hospital_user5 WITH PASSWORD = 'DbprojectUser5';
GO

-- Switch back to Hospital DB
USE HospitalDB;
GO

-- Map logins
CREATE USER hospital_admin FOR LOGIN hospital_admin;
GO
CREATE USER hospital_user1 FOR LOGIN hospital_user1;
GO
CREATE USER hospital_user2 FOR LOGIN hospital_user2;
GO
CREATE USER hospital_user3 FOR LOGIN hospital_user3;
GO
CREATE USER hospital_user4 FOR LOGIN hospital_user4;
GO
CREATE USER hospital_user5 FOR LOGIN hospital_user5;
GO

-- Assign roles
-- Hospital Admin user given db_owner (built-in role) = full access
ALTER ROLE db_owner ADD MEMBER hospital_admin;
GO

-- Hospital users given db_datareader (built-in role) = read-only acess
ALTER ROLE db_datareader ADD MEMBER hospital_user1;
GO
ALTER ROLE db_datareader ADD MEMBER hospital_user2;
GO
ALTER ROLE db_datareader ADD MEMBER hospital_user3;
GO
ALTER ROLE db_datareader ADD MEMBER hospital_user4;
GO
ALTER ROLE db_datareader ADD MEMBER hospital_user5;
GO

-- List user names and role names
SELECT USER_NAME(member_principal_id) AS UserName, USER_NAME(role_principal_id) AS RoleName
FROM sys.database_role_members;
GO