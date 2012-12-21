#!/bin/bash

############################################################################
#
# This script is run at 4:00pm each afternoon by the Unix cron daemon to
# produce a backup of the WordPress database. It deletes any backup copies
# that are more than one week old.
#
# Author: Andrew Ferguson <adf@cs.brown.edu>
#
############################################################################

cd ~/db-backup/

mysqldump -u root sysread | gzip > sysread-`date +%F`.sql.gz
mysqldump -u root mysql | gzip > mysql-`date +%F`.sql.gz

num_backups=`ls -1 sysread-????-??-??.sql.gz | wc -l`

if [ $num_backups -gt 7 ] ; then
    num_delete=`expr $num_backups - 7`
    ls -1 sysread-????-??-??.sql.gz | head -$num_delete | xargs rm -f
    ls -1 mysql-????-??-??.sql.gz | head -$num_delete | xargs rm -f
fi
