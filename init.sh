#!/bin/sh

set -e

[ "$DEBUG" == 'true' ] && set -x

LOGFILE=/data/logs/dovecot.log
if [ ! -f $LOGFILE ]; then
	touch $LOGFILE
fi
chmod 666 $LOGFILE
chown 5000:5000 /data/home
chmod 775 /data/home

if [ ! -f /etc/dovecot/fullchain.pem ]; then
   cp /etc/ssl/dovecot/server.pem /etc/dovecot/fullchain.pem
   cp /etc/ssl/dovecot/server.key /etc/dovecot/privkey.pem 
fi

if [ ! -f /data/common/dh-dovecot.pem ]; then
	openssl dhparam 2048 > /data/common/dh-dovecot.pem
fi

dovecot
tail -f /data/logs/dovecot.log

