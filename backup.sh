#!/bin/bash
#Author:NewWavex86
#Simple script to backup home directory for cronjob

USB_PATH=""
USB_BACKUP=""


#Check if backup exists
if [ -f /home/pi/backup.tar.gz ];
then
	sudo rm -r /home/pi/backup.tar.gz
fi

#Actual backup of file
sudo tar -zcvf /home/pi/backup.tar.gz --exclude "/home/pi/.cache" --exclude "/home/pi/Bookshelf" --exclude "/home/pi/Music" --exclude "/home/pi/Movies" --exclude "/home/pi/Public" /home/pi/
			#Get rid of unwatned directories to archive

#See if user wanted a sub backup
if [[ $USB_BACKUP =~ [y-Y] ]];
then
	#Copy onto usb
	if [ -d "$USB_PATH" ];
	then
		cp /home/pi/backup.tar.gz  $USB_PATH
		echo "Backup done on $(date)" >> /var/log/cron-log.txt

	#If usb isn't plugged in, error log
	else
	echo "Backup failed on $(date)" >> /var/log/cron-log.txt
	fi
fi



exit 0

