-- create role backup admin
-- DROP ROLE backup_admin;
CREATE ROLE backup_admin;
-- SAP HANA studio Backup Console
GRANT BACKUP ADMIN, CATALOG READ, DATABASE ADMIN TO backup_admin;
-- SAP HANA cockpit
call GRANT_ACTIVATED_ROLE ('sap.hana.backup.roles::Administrator', 'SYSTEM');

-- create user backup admin
CREATE USER backup PASSWORD Initial1;
GRANT backup_admin TO backup;

-- create user backup operator
CREATE USER backup_operator PASSWORD <enter_complex_password> NO FORCE_FIRST_PASSWORD_CHANGE;
GRANT BACKUP OPERATOR to backup_operator;
ALTER USER backup_operator DISABLE PASSWORD LIFETIME;
