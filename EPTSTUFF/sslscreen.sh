#!/bin/bash
#sslscreenshot by Robert Craig 
#Searches for files named <blank>sslscan and screenshots them. These files are put into a folder called SSLScreenshots. Check out the main eptscript if you are wondering about how to get the files. 
#The methodology is somewhat primitive, but it works. 
#

#Screenshot SSLScans
#
#CREATING 443 ADDRESSES
#
echo "" > ssl-hosts.txt #blanking the file
echo "------------------List of open 443 addresses------------------" 
grep -F "ssl|http" tcp-hosts.txt | grep open | cut -d " " -f 2 | uniq | sort -n | tee -a ssl-hosts.txt
echo "------------------end 443 list------------------" 


#SSLSCANS
#This portion of the script outputs your SSL scans to the screen and outputs each to a file using the 'tee' command. 
#
readarray array443 < ssl-hosts.txt;
echo "This might take a few minutes..."
for i in ${array443[@]}
do 
	sslscan $i | tee $i."sslscan"
	echo "Working..."
done
echo
clear

#sslscreenshot "renamer" by Robert Craig 
#Searches for files named <blank>sslscan and screenshots them. These files are put into a folder called SSLScreenshots. Check out the main eptscript if you are wondering about how to get the files. 
#The methodology is somewhat primitive, but it works. 
#

#Screenshot SSLScans
#

reNamer()
{
	nameaddition=""

	#if cat $1 | grep -E 'TLSv1.0' 2> /dev/null | grep -E 'DES-CBC3-SHA' 2> /dev/null 
	#then 
	#	nameaddition="TLS-1.0, "
#
#	elif cat $1 | grep -E 'TLSv1.0' 2> /dev/null | grep -E 'RC4-SHA' 2> /dev/null 
#	then 
#		nameaddition="TLS-1.0, "
#	
#	elif cat $1 | grep -E 'TLSv1.0' 2> /dev/null | grep -E 'RC4-MD5' 2> /dev/null 
#	then 
#		nameaddition="TLS-1.0, "
#	fi
	
	if cat $1 | grep -E 'TLSv1.0' 2> /dev/null 	
	then 
		nameaddition="TLS-1.0, "
	fi

	if cat $1 | grep 'SSLv3' 2> /dev/null 	
	then 
		nameaddition+="SSLv3, "
	fi
	
	if cat $1 | grep 'SSLv2' 2> /dev/null 	
	then 
		nameaddition+="SSLv2, "
	fi
	
	if ( grep 'DES-CBC3-SHA' $1 ) || ( grep -E 'RC4-SHA' $1 ) || ( grep -E 'RC4-MD5' $1 ) || ( grep -E 'ECDHE-RSA-DES-CBC3-SHA' $1 ) || ( grep -E 'EDH-RSA-DES-CBC3-SHA' $1 ) \
|| ( grep -E 'DES-CBC3-MD5' $1 )    
	then 
		nameaddition+="Weak-Ciphers"
	fi
	
	if ( grep 'sha1WithRSAEncryption' $1 ) || ( grep -E 'md5WithRSAEncryption' $1 )
 
	then 
		nameaddition+=" Weak-Certificate"
	fi
	
	if ( grep 'RSA Key Strength:    1024' $1 )  
	then 
		nameaddition+=" Weak-RSA-Key"
	fi

#taking out the comma if TLS has no weak ciphers	
	#if nameaddition="TLS-1.0, "
	#then
	#	nameaddition="TLS-1.0"
	#fi

	cp $1 "$1 $nameaddition"
	rm $1

	
	return 0;
}

find *sslscan 2> /dev/null 1>/dev/null
if [ $? -eq 0 ] #Looking at the exit code of the previous command to see if we should run this code
then
	sslscans=$(find *sslscan) #1>/dev/null  #creates a list of the sslscan files and  puts it into a variable
	#
	for i in $sslscans
	do
	reNamer $i
	done	
fi
#####NOW we find them and screenshot
find *sslscan* 2> /dev/null
if [ $? -eq 0 ] #Looking at the exit code of the previous command to see if we should run this code
then
	echo "Taking SSL Scan screenshots... make sure we are on fullscreen!"
	mkdir "SSLScreenshots"
	IFS="$(printf '\n\t')" #setting the delimiter to ignore spaces
	find *sslscan* > screenarray.txt
	readarray sslscans < screenarray.txt	
#sslscans=$[ find *sslscan* ] #creates a list of the sslscan files and  puts it into a variable
	#
	for i in ${sslscans[@]}
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
			mv "$i 1.png" ./SSLScreenshots;		#moves screenshots
			mv "$i 2.png" ./SSLScreenshots;
			mv "$i 3.png" ./SSLScreenshots;
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
			mv "$i 1.png" ./SSLScreenshots;		#moves screenshots
			mv "$i 2.png" ./SSLScreenshots;
			sleep 0.5;
			rm x00;					#deletes split files
			rm x01;
			sleep 0.5; 
		
		else		
			cat $i;					#cats the sslscan
			gnome-screenshot -w -b -f $i.png;	#screenshot
			mv $i.png ./SSLScreenshots;		#moves it to the screenshots folder
		fi
	clear
	sleep 0.5;
	done
fi








