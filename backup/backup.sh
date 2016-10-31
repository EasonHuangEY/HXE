#!/bin/bash

# define backup prefix
TIMESTAMP="$(date +\%F\_%H\%M)"
BACKUP_PREFIX="SCHEDULED"
BACKUP_PREFIX="$BACKUP_PREFIX"_"$TIMESTAMP"
TENANT="TESTDB"
TIME_NEEDED_FOR_BACKUP="10"

## execute command with user key
# hdbuserstore -i SET backup hxehost:30013 backup_operator
hdbsql -U backup "backup data using file ('$BACKUP_PREFIX')"
hdbsql -U backup "backup data for $TENANT using file ('$BACKUP_PREFIX')"

# wait for the backups to complete
sleep $TIME_NEEDED_FOR_BACKUP

##  compress backup and
##  move the zip file to a temporary location ready for file transfer (sftp) 
# cd /usr/sap/HXE/HDB00/backup/data
# tar -zcvf /tmp/systemdb.tar.gz SYSTEMDB/
# tar -zcvf /tmp/$TENANT.tar.gz DB_$TENANT/

##  compress backup and
##  move the zip file to the shared folder defined for the VM 
cd /usr/sap/HXE/HDB00/backup/data
tar -zcvf /mnt/hgfs/Downloads/systemdb.tar.gz SYSTEMDB/
tar -zcvf /mnt/hgfs/Downloads/$TENANT.tar.gz DB_$TENANT/
