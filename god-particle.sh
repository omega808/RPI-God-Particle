#!/bin/bash
#Author:NewWavex86
#Startup script for the raspberry pi, modified Git vewrsion for users not using my local configurations

#source $HOME/snippets/color #Cant do for git

VAR=0 #Container for while loop

#For git, create a bin directory and move the backup script to it
#mkdir /home/pi/bin
#mv backup.sh /home/pi/bin/backup


#Create array of packages to check
PACKAGES=("tmux" "htop" "nmap" "neofetch" "vim" "docker.io" "figlet" "cmatrix" "terminology" "rename")
ARRAYSIZE=${#PACKAGES[@]} #This variable is created because the length of array would decrease while
			 #through the while loop

package-install(){

echo "Checking installed packages: "
#Run through array, and remove already installed packages
while [ $VAR -lt $ARRAYSIZE  ];
do
	echo "Checking ${PACKAGES[$VAR]}"
	sleep 1
						#Redirect Standard Error to prevent errors coming on user's screen
	if [[ $(dpkg-query -s ${PACKAGES[$VAR]} 2> /dev/null ) ]];
	then
		echo "       Installed!"
	else
		echo "       Need to install"
		unset ${PACKAGES[$VAR]} #Remove installed packages from array
	fi
	
	let VAR++
	
done


#Install the uninstalled
echo "Installing the packages"
sudo apt install ${PACKAGES[@]}

}


#Turned into a function so I can run this after VIM is installed
vim-line-count(){
	
	#Add line count to VI
	read -p "Would you like to add line count to Vim?[Y/n]" REPLY1
		if [[ "$REPLY1" =~ ^[y-Y]$ ]];
		then
			sudo sed -i ' 50i\set number ' /etc/vim/vimrc
		fi
}


#Startup Scripts that run in the .bashrc file
startup-scripts(){

	read -p "Would you like any scripts to be run automatically when you log in[Y/n]" RE
	if [[ "$RE" =~ [y-Y]+ ]];
	then
		#Setup counter for loop
		N=1
		while [ $N -le 2 ];
		do       
			read -p "Enter script name: " SCRIPT
	       		
 			#Echo would suffice here, but I use sed for practice			
			LENGTH=$( wc -l /home/pi/.bashrc | awk ' {print $1}' )
			sudo sed -i "${LENGTH}i\ sudo bash $SCRIPT " /home/pi/.bashrc
			
			read -p "Would you like to add another script[Y/n]" REPLY
			if [[ $REPLY =~ [y-Y]+ ]];
			then
				N=1
			
			else
				N=2

			fi
		done
	fi		

				
}

add-path(){
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


}

backup-job(){
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


}

#The actual program
echo "The Unix wizard casts his spell.."
sleep 1
echo "It begins.."
#Add bin folder to env path
add-path

#Make cron run the backup scripts
backup-job

#Install various packages
package-install

#Add line count to VIM after it is installed
vim-line-count

#Make user input scripts run at startup
startup-scripts

echo -e  "The Unix wizard disappears back into the ether"
sudo reboot


exit 0
