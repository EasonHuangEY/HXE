-- connect as SYSTEM to the SystemDB

-- Secure Store
select * from SYS.M_SECURESTORE

-- 2229831 - HANA Internal Data Encryption Service and DPAPI Root Key
SELECT * FROM SYS.CREDENTIALS;
SELECT * FROM SYS.P_DPAPI_KEY_ WHERE caller = 'XsEngine';
SELECT * FROM PSE_CERTIFICATES WHERE certificate_usage = 'OWN';
