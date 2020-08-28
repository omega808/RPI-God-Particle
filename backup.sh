#!/bin/bash
#Author:NewWavex86
#Simple script to backup home directory for cronjob

#Check if backup exists
if [ -f /home/pi/launch-pad/backup.tar.gz ];
then
	sudo rm -r /home/pi/launch-pad/backup.tar.gz
fi

sudo tar -zcvf /home/pi/backup.tar.gz /home/pi/

#Copy onto usb
if [ -d /media/pi/DOm ];
then
	cp /home/pi/backup.tar.gz  /media/pi/DOm
	echo "Backup done on $(date)" >> /var/log/cron-log.txt

#If usb isn't plugged in, error log
else
	echo "Backup failed on $(date)" >> /var/log/cron-log.txt
fi




exit 0

