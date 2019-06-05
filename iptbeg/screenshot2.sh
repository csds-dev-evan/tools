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
		split -l 49 -d $i		
		clear
		linecount=$(wc -l "$i" | cut -d " " -f 1) 	#cuts and prints the line count number. Basically, "How many lines are in this file $i "?
		screens=$(echo $[$linecount /49])
			for i2 in $(seq 0 $screens)
			do
				if [ "$i2" -lt 10 ]			
				then
			
					basetext="x0"	
				else	
					
					basetext="x"	
				fi
				cat "$basetext$i2"
				count=$[ $i2 + 1 ]                     #I want to use a screenshot thats says  "screenshot 1' rather than 'screenshot 0'
				name=$(echo $i | cut -d "." -f 1)      #removing log portion of file
				gnome-screenshot -w -b -f "$name $count.png";	#screenshot
				mv "$name $count.png" ./output;		#moves it to the screenshots folder
				rm $basetext$i2
				sleep 1	
			done
		
		
		
	
	done
fi
rm array.txt






