#!/bin/bash
#Author:NewWavex86
#Startup script for the raspberry pi, modified Git vewrsion for users not using my local configurations
 

VAR=0 #Container for while loop

#For git, create a bin directory and move the backup script to it
mdkir /home/pi/bin
mv backup.sh /home/pi/bin/backup


#Create array of packages to check
PACKAGES=("tmux" "htop" "nmap" "neofetch" "vim" "figlet" "cmatrix" "terminology" "rename")
ARRAYSIZE=${#PACKAGES[@]} #This variable is created because the length of array would decrease while
			 #through the while loop

#Turned into a function so I can run this after VIM is installed
vim-line-count(){
	#Add line count to VI
	read -p "Would you like to add line count to Vim?[Y/n]" REPLY1
		if [[ "$REPLY1" =~ ^[y-Y]$ ]];
		then
			sudo sed -i ' 50i\set number ' /etc/vim/vimrc
		fi
}
#Startup Scripts
startup-scripts(){

 	read -p "Would you like any scripts to be run automatically when you log in[Y/n]" RE
        
	if [[ "$RE" =~ [y-Y]+ ]];
        then
                #Setup counter for loop
                N=1
                #Loops allows user to input mutiple scripts
		while [ $N -le 2 ];
                do
                        read -p "Enter script name: " SCRIPT

                        #Echo would suffice here, but I use sed for practice
                        LENGTH= $( wc -l /home/pi/.bashrc | awk ' {print $1}' ) #Figure out last line of .bashrc
                        sudo sed -i "${LENGTH}i\ sudo bash $SCRIPT " /home/pi/.bashrc

                        read -p "Would you like to add another script[Y/n]" REPLY
                        if [[ $REPLY =~ [y-Y]+ ]];
                        then
                                n=1

                        else
                                n=2

                        fi
                done
        fi





}


#check if ~/bin is added to env Path
cat /etc/profile | grep ^PATH > /dev/null
EXITSTATUS=$?

if [ $EXITSTATUS != 0 ];
then
	read -p "PATH is not added to profile, would you like to add it? [Y/n]" REPLY2
	if [ "$REPLY2" == "Y" -o "$REPLY2" == "y" ]; #Account for lower and uppercase input
	then
		sudo echo 'PATH=$PATH/home/pi/bin' >> /etc/profile
	
	fi

fi


#Added for git users forking code
if [ ! -f /home/pi/bin/backup ];
then
	echo "Backup shellscript not found, please create a bin folder in home dir and move the shellscript to it!"

else

	#Add the Backups
	read -p "Would you like to schedule cron to do a backup[Y/n]" REPLY3
		if [ "$REPLY3" == "Y" -o "$REPLY3" == "y" ];
		then
			sudo sed -i "18i\ 1 */3 * * * root  bash /home/pi/bin/backup" /etc/crontab
			echo "All done added backup to /etc/crontab"
			sleep 1
		fi
fi

echo "Checking installed packages: "
#Run through array, and remove already installed packages
while [ $VAR -lt $ARRAYSIZE  ];
do
	sleep 1
	dpkg -l | grep -i ${PACKAGES[$VAR]} && unset PACKAGES[$VAR]
	let VAR++
	
done

#Install the uninstalled
echo "Installing the packages"
sudo apt install ${PACKAGES[@]}

#Add line count to VIM after it is installed
vim-line-count

#Allow user-inputed scripts to run upon login
startup-scripts

echo  " Everything is good to go! "
shutdown -r


exit 0
