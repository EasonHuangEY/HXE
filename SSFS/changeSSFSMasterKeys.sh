#!/bin/sh

## SAP HANA Academy
## Playlist: SAP HANA express edition
## Tutorial video: https://www.youtube.com/watch?v=F53iPBsq6AY
## Sample script provided for educational purposes
## Info: hanaacademy@sap.com

echo '********************************************************************************************'
echo 'Script to change the SSFS master keys (instance and PKI) and generate new DPAPI root key'
echo 'Before running this script, read'
echo ' - SAP Note 2183624 and 2229831'
echo ' - SAP HANA Administration Guide, section Managing Encryption Keys'
echo ''
echo 'Make sure that the internal credential is empty before running this script'
echo ' SELECT * FROM SYS.CREDENTIALS / SYS.P_DPAPI_KEY_ / PSE_CERTIFICATES'
echo '********************************************************************************************'
echo ''
read -rsp $'Use ctrl-c to exit or press enter to continue...\n'

echo .
echo 'Stopping the SAP HANA database ...'
# Command (script) 'HDB stop' calls command sapcontrol with preconfigured parameters
# Using HDB stop has the advantage that the prompt is returned when the database is stopped.
# For distributed systems, sapcontrol is required
## sapcontrol -nr 00 -function Stop
HDB stop
echo .
HDB info
echo .
echo 'Verify that SAP HANA is stopped (no hdbnameserver process)'
echo 'Otherwise exit this script and first stop SAP HANA (HDB stop).'
echo .
read -rsp $'Use ctrl-c to exit or press enter to continue...\n'

echo .
echo 'changing PKI SSFS master key (securing internal communication)'
export RSEC_SSFS_DATAPATH=/usr/sap/HXE/SYS/global/security/rsecssfs/data
export RSEC_SSFS_KEYPATH=/usr/sap/HXE/SYS/global/security/rsecssfs/key
rsecssfx changekey $(rsecssfx generatekey -getPlainValueToConsole)
echo .
rsecssfx list
sleep 5

echo .
echo 'changing instance SSFS master key (securing the internal encryption service)'
export RSEC_SSFS_DATAPATH=/usr/sap/HXE/SYS/global/hdb/security/ssfs
export RSEC_SSFS_KEYPATH=/usr/sap/HXE/SYS/global/hdb/security/ssfs
rsecssfx changekey $(rsecssfx generatekey -getPlainValueToConsole)
echo .
rsecssfx list
sleep 5

echo .
echo 'generating a new root key for the secure internal credential store (DPAPI)'
hdbnsutil -generateRootKeys --type=DPAPI

echo .
echo 'Starting the SAP HANA database ...'
# Command (script) 'HDB start' calls command sapcontrol with preconfigured parameters
# Using HDB start has the advantage that the prompt is returned when the database is started.
# For distributed systems, sapcontrol is required
## sapcontrol -nr 00 -function Start
HDB start
echo .
echo 'Verify that SAP HANA is started (hdbnameserver process)'
echo 'Otherwise exit this script and first start SAP HANA (HDB start).'
echo .
HDB info
echo .
read -rsp $'Use ctrl-c to exit or press enter to continue...\n'

# The default path of the key file is $DIR_GLOBAL/hdb/security/ssfs.
# If you change the default path, you may need to reconfigure it in the event of a system rename.
# SQL command just sets the path to the default path, making it visible (not required),
echo .
echo 'Enter the SystemDB SYSTEM user password to add the SSFS key file path'
hdbsql -u system -d SystemDB "ALTER SYSTEM ALTER CONFIGURATION ('global.ini', 'SYSTEM') SET ('cryptography', 'ssfs_key_file_path') = '/usr/sap/HXE/SYS/global/hdb/security/ssfs' WITH RECONFIGURE"

# cf. SAP Note 2228829 - How to Change the DPAPI Root Key
echo .
echo 'Resetting the consistency information in the SSFS'
hdbcons "crypto ssfs resetConsistency" -e hdbnameserver
sleep 3
hdbcons "crypto ssfs resetConsistency" -e hdbnameserver
echo .
echo 'Enter the SystemDB SYSTEM user password to set the (default) path to the instance SSFS master key'
hdbsql -u system -d SystemDB "ALTER SYSTEM APPLICATION ENCRYPTION CREATE NEW KEY"

# optional check
##echo .
##echo 'Enter the SystemDB SYSTEM user password to verify the reset count of the DPAPI key'
##hdbsql -u system -d SystemDB "select * from SYS.M_SECURESTORE"
