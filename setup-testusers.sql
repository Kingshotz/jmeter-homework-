-- Creates the JMeterHomework database, the TestUsers table and a read-only SQL login for JMeter.
-- Run with: sqlcmd -S localhost\SQLEXPRESS -E -C -i setup-testusers.sql

IF DB_ID('JMeterHomework') IS NULL
    CREATE DATABASE JMeterHomework;
GO

USE JMeterHomework;
GO

IF OBJECT_ID('dbo.TestUsers') IS NOT NULL
    DROP TABLE dbo.TestUsers;
GO

CREATE TABLE dbo.TestUsers (
    id         INT          NOT NULL PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    last_name  NVARCHAR(50) NOT NULL,
    email      NVARCHAR(100) NOT NULL
);
GO

-- Mirrors reqres.in users 1-6. User 5 is stored as "Charlie" instead of "Charles",
-- so the concatenated email does not match the API and the If Controller logs a warning.
INSERT INTO dbo.TestUsers (id, first_name, last_name, email) VALUES
    (1, 'George',  'Bluth',  'george.bluth@reqres.in'),
    (2, 'Janet',   'Weaver', 'janet.weaver@reqres.in'),
    (3, 'Emma',    'Wong',   'emma.wong@reqres.in'),
    (4, 'Eve',     'Holt',   'eve.holt@reqres.in'),
    (5, 'Charlie', 'Morris', 'charlie.morris@reqres.in'),
    (6, 'Tracey',  'Ramos',  'tracey.ramos@reqres.in');
GO

USE master;
GO

IF SUSER_ID('jmeter_user') IS NULL
    CREATE LOGIN jmeter_user WITH PASSWORD = 'JmLi0dAYK0N96DWT#7', CHECK_POLICY = ON;
GO

USE JMeterHomework;
GO

IF USER_ID('jmeter_user') IS NULL
    CREATE USER jmeter_user FOR LOGIN jmeter_user;
GO

ALTER ROLE db_datareader ADD MEMBER jmeter_user;
GO
