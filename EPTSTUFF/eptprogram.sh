#!/bin/bash
#EPT Script   
#To begin just make a text called ranges in the folder from which you run this script. Make the ranges file grepable and nmap friendly 

#Example for ranges:
#192.168.1.1-254
#192.168.2.5-15
#Or CIDR 192.168.1.0/24

#Calling Check for whois, harvester, and DNSenum
harvwhocheck.sh

#Making Screenshot directory. Removing first if present
rm -r screenshots
mkdir screenshots


#List the IPs in "ranges"
echo "We are testing the following IPs..."
#LIST OF INDIVIDUATED IPS
# This will create a list of each IP in a grepable format. It serves the same function as Prips
#
nmap -sL -iL ranges | ipextract | sort -u | tee hosts;  
echo

#-----------------------------------------------------------------------------------------------------------------------------------
#Running a pretty crazy scan to find active ports and then do the version scan.
echo "Looking for open ports.... running versionless scans..."
echo

nmap -n -v -Pn -iL ranges -sS --top-ports 3000 --open -oG tcp_open_ports
nmap -n -v -Pn -iL ranges -sU --top-ports 100 --open -oG udp_open_ports1 #this doesn't output right, problem with nmap, correction on next line
cat udp_open_ports1 | grep open > udp_open_ports

#get only the active ips/ports
cat tcp_open_ports | ipextract | sort -u > ACTIVE-TCP-IPS
cat udp_open_ports | ipextract | sort -u > ACTIVE-UDP-IPS

/usr/local/sbin/trace_nmapparser.py tcp_open_ports | awk {'print $4'} | grep tcp | sed 's/.\{'4'\}$//' | sort -u | paste -d , -s >tcp_open
/usr/local/sbin/trace_nmapparser.py udp_open_ports | awk {'print $4'} | grep udp | sed 's/.\{'4'\}$//' | sort -u | paste -d , -s >udp_open

echo

#NMAP PARSER (TCP)
echo "Beginning nmap command -sSV -Pn --top-ports 2000 -iL ranges -oG tcp-hosts.txt --version-all with active ports only";
echo
nmap -n -v -sSV -Pn -p $(cat tcp_open) -iL ACTIVE-TCP-IPS --version-all -oG tcp-hosts.txt;
#This next line needs to be wherever your trace_nmapparser.py script is.
#
/usr/local/sbin/trace_nmapparser.py tcp-hosts.txt | tee screenshots/Nmap-TCP-Results.log
echo

#NMAP PARSER (UDP)
echo "Beginning NMAP nmap command 'nmap -sUV -Pn --top-ports 50 -iL ranges -oG udp-hosts.txt --version-all with active ports only'"
nmap -n -v -sUV -Pn -p $(cat udp_open) -iL ACTIVE-UDP-IPS --version-all -oG udp-hosts.txt;
/usr/local/sbin/trace_nmapparser.py udp-hosts.txt | tee screenshots/Nmap-UDP-Results.log
echo

#-----------------------------------------------------------------------------------------------------------------------------------




#PING SWEEP
#Ping sweep... make the list with prips first
#
echo "Addresses Responding to Ping Listed Below" > pinged.log
echo "fping -f pinglist.txt" >> pinged.log
cat ranges | grep -v "/" > pinglist.txt #make list of individual ips (ones not in ranges)
cat ranges | grep "/" > pinglistprranges #make list of CIDR ips
readarray iparray < pinglistprranges; for i in ${iparray[@]}; do prips $i >> pinglist.txt; done
fping -f pinglist.txt >> pinged.log
rm pinglistprranges
#pinglist.txt we keep since we use it for EPT auto upload tool

#


#http or https files with ports... can be used for various scripts
/usr/local/sbin/trace_nmapparser.py tcp-hosts.txt | grep "http" | grep -v "ssl|http" | cut -d " " -f 3,6 | tr " " ":" | trim.sh 4 > httpwithports.txt
/usr/local/sbin/trace_nmapparser.py tcp-hosts.txt | grep "ssl|http" | cut -d " " -f 3,6 | tr " " ":" | trim.sh 4 > httpswithports.txt

echo "Find Website Ports"
nmap -Pn -iL ranges -p 80,443,8080,8443 -oG - | grep open | tee http-hosts.txt

#	Splitting ports of websites into separate files
echo "Splitting apart the various ports, 80,443,808,8443"
echo
echo "awk '/ 80\/open/{print "http://" $2 "/"}' < http-hosts.txt >> http-urls.txt;"
awk '/ 80\/open/{print "http://" $2 "/"}' < http-hosts.txt >> http-urls.txt;
cat http-urls.txt

echo
echo "awk '/ 443\/open/{print "https://" $2 "/"}' < http-hosts.txt >> https-urls.txt;"
awk '/ 443\/open/{print "https://" $2 "/"}' < http-hosts.txt >> https-urls.txt;
cat https-urls.txt

echo
echo "awk '/ 8080\/open/{print "http://" $2 ":8080/"}' < http-hosts.txt >> http8080-urls.txt;"
awk '/ 8080\/open/{print "http://" $2 ":8080/"}' < http-hosts.txt >> http8080-urls.txt;
cat http8080-urls.txt

echo
echo "awk '/ 8443\/open/{print "https://" $2 ":8443/"}' < http-hosts.txt >> https8443-urls.txt;"
awk '/ 8443\/open/{print "https://" $2 ":8443/"}' < http-hosts.txt >> https8443-urls.txt;
cat https8443-urls.txt

#Adding all URLs to one file
cat http-urls.txt > all-urls.txt
cat https-urls.txt >> all-urls.txt
cat http8080-urls.txt >> all-urls.txt
cat https8443-urls.txt >> all-urls.txt
mkdir websites
mv all-urls.txt websites


#NTP SERVER TESTS
#
echo "Testing for NTP servers"
cat udp-hosts.txt tcp-hosts.txt | grep -F "123/open" | cut -d " " -f 2 | uniq | tee -a ntpUDPranges
if [[ -s ntpUDPranges ]]
then
readarray ntpparray < ntpUDPranges
for i in ${ntpparray[@]}
do 
echo
echo "NTPQ test for $i"
echo "-----------------------------------------"
echo
echo "ntpq -c readvar $i"
ntpq -c readvar $i | tee -a ntptest.txt
echo "ntpq -c readvar -c peers -n $i"
ntpq -c readvar -c peers -n $i | tee -a ntptest.txt #the -a in tee appends
echo 
done
fi
rm ntpUDPranges
echo
echo
echo "Ike-Beginning"
#IKE-SCANS
ike-scanner.sh


#for running EPT apendix uploader
parsertoscript.sh 


echo "Make sure screen is fullsize for screenshots! Then hit a key and press ENTER"
read answer
winfocus.sh

sslscreen.sh #screenshots for SSL
#moving all .log files to screenshots folder, and then taking a screenshot for everything in screenshots folder
for i in $(find *.log); do mv $i screenshots; done
cd screenshots
screenshot.sh 

#cleanup
rm udp_open
rm udp_open_ports1
rm udp_open_ports
rm tcp_open
rm tcp_open_ports
rm stash.sqlite
rm ACTIVE-TCP-IPS
rm ACTIVE-UDP-IPS
rm screenarray.txt

#prepend awk '{print "http://" $0}' httpswithports.txt >httpsaddresses.txt

#nikto -h tcp-hosts.txt 

#If you ever have a ridiculous number of addresses for CSO uncomment this
#create a cso friednly file from Ip Addresses by adding commas
#awk '{ print $0 "," }' ranges > csoranges
#sed '$ s/.$//' csoranges

#Explanation of SED
#$ is a Sed address that matches the last input line only, thus causing the following function call (s/.$//) to be executed on the last line only.
#s/.$// replaces the last character on the (in this case last) line with an empty string; i.e., effectively removes the last char. (before the newline) on the line.
#. matches any character on the line, and following it with $ anchors the match to the end of the line; note how the use of $ in this regular expression is conceptually related, but technically distinct from the #previous use of $ as a Sed address.

