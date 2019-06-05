#!/bin/bash
echo "This script assumes that you have two -oG nmap files named tcp-hosts.txt and udp-hosts.txt in the directory where you are running the script." #can be deleted
echo "It also assumes nmapparser.py is at /usr/local/sbin/trace_nmapparser.py. Once this is done feel free to remove this message and the sleep command" #can be deleted
sleep 10 #can be deleted


#Script Begins with TCP
/usr/local/sbin/trace_nmapparser.py tcp-hosts.txt > parser.txt
sed '/+--/d' ./parser.txt > parser2.txt #removes extra spaces by removing any line with "+--"
cat parser2.txt | tr -s " " | cut -c4- | sort -u | sort -g | tail -n +3 > parser3.txt #removes extra whitespce, then cuts first 3 characters, and then removes any duplicates, and then sorts numerically, and then removes the first two lines
rm parser.txt
rm parser2.txt
touch autoinput.txt
IFS="$(printf '\n\t')" #ignores spaces as delimiters
NUMBER=1
var=""
lineTransfer(){
	for i in $(cat parser3.txt);
        do
		nameaddition=""
		echo $i
		tail -n+$NUMBER parser3.txt | head -n1 | cut -d " " -f 1 >>autoinput.txt
		tail -n+$NUMBER parser3.txt | head -n1 | cut -d " " -f 3 >>autoinput.txt
		nameaddition=$(tail -n+$NUMBER parser3.txt | head -n1 | cut -d " " -f 5)                    #we want to add the last two together onto a single line since CSO only has three spaces
 		nameaddition+=" "                                                                          #adding a space
		nameaddition+=$(tail -n+$NUMBER parser3.txt | head -n1 | cut -d " " -f 7- | sed 's/|$//')  #The sed removes any extra | also the hyphen after 7 prints all fields after 7
		echo $nameaddition >>autoinput.txt
		#echo $var >>autoinput.txt


		let "NUMBER += 1" #adding 1 to number
        done
	
	return 0;
}
lineTransfer
rm parser3.txt
clear
echo
echo




#now for UDP
/usr/local/sbin/trace_nmapparser.py udp-hosts.txt > parser.txt
sed '/+--/d' ./parser.txt > parser2.txt #removes extra spaces by removing any line with "+--"
cat parser2.txt | tr -s " " | cut -c4- | sort -u | sort -g | tail -n +3 > parser3.txt #removes extra whitespce, then cuts first 3 characters, and then removes any duplicates, and then sorts numerically, and then removes the first two lines
rm parser.txt
rm parser2.txt
touch autoinputudp.txt
IFS="$(printf '\n\t')" #ignores spaces as delimiters
NUMBER1=1
var=""
lineTransfer2(){
	for i in $(cat parser3.txt);
        do
		nameaddition=""
		echo $i
		tail -n+$NUMBER1 parser3.txt | head -n1 | cut -d " " -f 1 >>autoinputudp.txt
		tail -n+$NUMBER1 parser3.txt | head -n1 | cut -d " " -f 3 >>autoinputudp.txt
		nameaddition=$(tail -n+$NUMBER1 parser3.txt | head -n1 | cut -d " " -f 5)                    #we want to add the last two together onto a single line since CSO only has three spaces
 		nameaddition+=" "                                                                          #adding a space
		nameaddition+=$(tail -n+$NUMBER1 parser3.txt | head -n1 | cut -d " " -f 7- | sed 's/|$//')  #The sed removes any extra | also the hyphen after 7 prints all fields after 7
		echo $nameaddition >>autoinputudp.txt
		


		let "NUMBER1 += 1" #adding 1 to number
        done
	
	return 0;
}
lineTransfer2
rm parser3.txt
echo 
clear

echo
for i in $(cat autoinputudp.txt)
do echo $i >> autoinput.txt
done


echo "You can copy paste this portion if you want; however the file is named autoinput.txt"
cat autoinput.txt
rm autoinputudp.txt
#parser tcp-hosts.txt | sed '/-------/d' | tr -s '[:space:]'   way simpler way of doing it lol, but oh well

