#!/bin/sh

## SAP HANA Academy
## Playlist: SAP HANA express edition
## Tutorial video:
## Sample script provided for educational purposes
## Info: hanaacademy@sap.com

echo '********************************************************************************************'
echo 'Script to change the SSFS master keys (instance and PKI) and generate new DPAPI root key'
echo 'Before running this script, read'
echo ' - SAP Note 2183624, 2228829 and 2229831'
echo ' - SAP HANA Administration Guide, Managing Encryption Keys'
echo ''
echo 'During the procedure the SAP HANA database is stopped and restarted'
echo '********************************************************************************************'
echo ''
read -rsp $'Use ctrl-c to exit or press enter to continue...\n'

# Update the SSFS master key for PKI
# Path = $DIR_GLOBAL/security/rsecssfs/data and ../key

echo ''
echo '>>> changing PKI SSFS master key (securing internal communication)'
echo ''
export RSEC_SSFS_DATAPATH=/usr/sap/HXE/SYS/global/security/rsecssfs/data
export RSEC_SSFS_KEYPATH=/usr/sap/HXE/SYS/global/security/rsecssfs/key
rsecssfx changekey $(rsecssfx generatekey -getPlainValueToConsole)
echo ''
rsecssfx list

# Update the SSFS master key for the internal encryption service
# Path = $DIR_GLOBAL/hdb/security/ssfs

echo ''
echo '>>> changing instance SSFS master key (securing the internal encryption service)'
echo ''
export RSEC_SSFS_DATAPATH=/usr/sap/HXE/SYS/global/hdb/security/ssfs
export RSEC_SSFS_KEYPATH=/usr/sap/HXE/SYS/global/hdb/security/ssfs
rsecssfx changekey $(rsecssfx generatekey -getPlainValueToConsole)
echo ''
rsecssfx list

# Administration Guide and Note 2183624 document to set the ssfs_key_file_path parameter
# This is only require if the default path of the key file is changed:
# $DIR_GLOBAL/hdb/security/ssfs
# Note that you cannot change the location of the secure store (datapath)
# hdbsql -u system -d SystemDB "ALTER SYSTEM ALTER CONFIGURATION ('global.ini', 'SYSTEM') SET ('cryptography', 'ssfs_key_file_path') = '/usr/sap/HXE/SYS/global/hdb/security/ssfs' WITH RECONFIGURE"

# Shutdown the database enable DPAPI root key generation
echo '>>> Stopping the SAP HANA database'
echo ''
HDB stop
echo ''
echo '>>> generating a new root key for the secure internal credential store (DPAPI)'
echo ''
hdbnsutil -generateRootKeys --type=DPAPI
echo ''
echo '>>> Starting the SAP HANA database'
HDB start

# cf. SAP Note 2228829 - How to Change the DPAPI Root Key
echo ''
echo '>>> resetting the consistency information in the SSFS'
echo ''
hdbcons "crypto ssfs resetConsistency" -e hdbnameserver
echo ''
hdbcons "crypto ssfs resetConsistency" -e hdbnameserver
echo ''
echo '>>> Enter the SystemDB SYSTEM user password to create the new DPAPI key'
hdbsql -u system -d SystemDB "ALTER SYSTEM APPLICATION ENCRYPTION CREATE NEW KEY"

echo ''

echo '********************************************************************************************'
echo ' Backup up your HANA system after changing the encryption key'
echo '********************************************************************************************'
echo ''

# optional check
##echo .
##echo 'Enter the SystemDB SYSTEM user password to verify the reset count of the DPAPI key'
##hdbsql -u system -d SystemDB "select * from SYS.M_SECURESTORE"
