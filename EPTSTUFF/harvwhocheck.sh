#!/bin/bash

#HARVESTER FUNCTION, WHOIS and ZONE TRANSFER CALL
#
echo "What is the name of the domain? Press ENTER when done."
read domainName
echo "The domain name is $domainName"

if [ -z "$domainName" ]
	then
	echo "empty"
	exit
fi

harvestcheck2 () {
   if [ -z "$domainName" ]                           
     then
        echo "-Type somehting for domain name-"  # Or no parameter passed.
     else
        echo "-The domain name is \"$domainName\".-"
        echo "Performing Harvest..."
        theharvester -d $domainName -b google -h -f harvestfile
	echo
	echo "Harvester-Ending"
	#creates two files, one a userfile composed from harvester names, the other a passfile with two default passwords.
	#these files are used for the metasploit OWA brute force attack, etc
     	cat harvestfile.xml | tr ">" '\n' | grep @ | cut -d "<" -f 1 | sort -u > userfile  
     	echo 'password!' > passfile; 
     	echo 'Summer2018!@#' >> passfile;
	echo
	#metagoofil -d "$domainName" -t doc,pdf,xls,ppt -l 200 -n 50 -o metagoofiles -f results.html
	
   fi
   return 0
}


#CALLING HARVEST2 FUNCTION
#Calling function to check if a parameter was passed. If nothing is passed this is skipped.
#
echo
harvestcheck2 "$domainName" | tee Harvester-Results.log
dnsenum $domainName | tee DNS-Enumeration.log
whois $domainName | tee Whois-Results.log
#
