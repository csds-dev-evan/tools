#!/bin/bash
#screenshot by Robert Craig 
#Searches for files named <blank> and screenshots them. These files are put into a folder called SSLScreenshots. Check out the main eptscript if you are wondering about how to get the files. 
#The methodology is somewhat primitive, but it works. 
#


#Screenshot 
#
find * 2> /dev/null
if [ $? -eq 0 ] #Looking at the exit code of the previous command to see if we should run this code.
# 'echo $?' tells us if the last command executed successfully, True = 0, which is odd. False = 1
then
	echo "Screenshots... make sure we are on fullscreen!"
	mkdir "output"
	IFS="$(printf '\n\t')" #setting the delimiter to ignore spaces
	find * -maxdepth 0 -type f > array.txt #maxdepth 0 makes non-recurisive, -type -f selects files
	#
	for i in $(cat array.txt)
	do
		clear
		linecount=$(wc -l "$i" | cut -d " " -f 1) 	#cuts and prints the line count number. Basically, "How many lines are in this file $i "?
		if [ "$linecount" -gt 98 ]              	#check to see if the line count in the file is greater than 98. That's about two full screens in the terminal at regular view. 
			then	
			split -l 49 -d $i;               	#splits the file by 50 lines, the d is for numbers, file is $i
			cat x00;                     		#cats the first split file named x00
			gnome-screenshot -w -b -f "$i 1.png";   #screenshot
			clear;
			cat x01;     				#cats the second split file named x01	
			gnome-screenshot -w -b -f "$i 2.png";   #screenshot
			clear;
			cat x02;     				#cats the second split file named x01
			gnome-screenshot -w -b -f "$i 3.png";   #screenshot
			clear;
			mv "$i 1.png" ./output;		#moves screenshots
			mv "$i 2.png" ./output;
			mv "$i 3.png" ./output;
			sleep 0.5;
			rm x00;					#deletes split files
			rm x01;
			rm x02;
			sleep 0.5;
		elif [ "$linecount" -gt 48 ]              	#check to see if the line count in the file is greater than 48. That's about two full screens in the terminal at regular view. 
			then	
			split -l 48 -d $i;               	#splits the file by 50 lines, the d is for numbers, file is $i
			cat x00;                     	#cats the first split file named x00
			gnome-screenshot -w -b -f "$i 1.png";   #screenshot
			clear;
			cat x01;     				#cats the second split file named x01
			gnome-screenshot -w -b -f "$i 2.png";    #screenshot
			clear;
			mv "$i 1.png" ./output;		#moves screenshots
			mv "$i 2.png" ./output;
			sleep 0.5;
			rm x00;					#deletes split files
			rm x01;
			sleep 0.5; 
		
		else		
			cat $i;					#cats the sslscan
			gnome-screenshot -w -b -f $i.png;	#screenshot
			mv $i.png ./output;		#moves it to the screenshots folder
		fi
	clear
	sleep 0.5;
	done
fi
rm array.txt






