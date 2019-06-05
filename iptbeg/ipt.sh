#!/bin/bash
#This is a penttesting script for Internal Penetration Tests, developed by Robert Craig
#It requires a file with nmap friendly ranges named, "ranges"
#Any needed routes will be added in gateway.txt. IF you have some other gateway (gw) you can change it
echo "Make sure your ranges and gateway.txt are in place before running this!!!"
echo "You don't have to have a file named 'exclusions.txt', but if you do those indiduated addresses will be removed."
echo

if [ ! -f ranges ]; 
	then
    	echo "ranges file not found!"
	exit
fi


if [ -f "gateway.txt" ]
	then 
	echo "1.1 Making proper Routes using CIDR in gateway.txt (gateway.txt should be all CIDR)"
	echo
	for a in $(cat gateway.txt);
	do route add -net $a gw 19.1.1.2; 
	echo "do route add -net $a gw 19.1.1.2;";
	done

else
	echo "No Gateway.txt? You sure bro? No routes? You're in person on their network?"
	sleep 5
fi
#
#
#	Part 1 Getting Hosts, Removing Exclusions, Telnet, SSH, FTP
#

#
#portless scan, finding live hosts based on various nmap "Ping Scans"
echo " 1.2 Getting Hosts"
nmap -iL ranges -sn -oG - | awk '/Up/{print $2}' > hosts 

#
#If you need exclusions of specific addresses you can make a file called exclusions.txt
if [ -f "exclusions.txt" ]
	then
	grep -v -x -f exclusions.txt hosts | tee hostfile
	#-v to select non-matching lines
	#-x to match whole lines only
	#-f exlusions.txt to get patterns from exclusions.txt
	cat hostfile > hosts
fi

echo
echo "Getting FTP Ports"
nmap -Pn -iL hosts -p 21 -oG - | awk '/open/{print $2}' | tee ftp-hosts.txt

echo
echo "Getting Telnet Ports"
nmap -Pn -iL hosts -p 23 -oG - | awk '/open/{print $2}' | tee telnet-hosts.txt

echo
echo "Getting SSH Ports"
nmap -Pn -iL hosts -p 22 -oG - | awk '/open/{print $2}' | tee ssh-hosts.txt

echo
echo "Getting DNS Ports"
nmap -Pn -iL hosts -p 53 -oG - | awk '/open/{print $2}' | tee dns-hosts.txt


#	Finding Websites
echo
echo "Find Website Ports"
nmap -Pn -iL hosts -p 80,443,8080,8443 -oG - | grep open | tee http-hosts.txt 
echo



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
cat http-urls.txt > allURLS.txt
cat https-urls.txt >> allURLS.txt
cat http8080-urls.txt >> allURLS.txt
cat https8443-urls.txt >> allURLS.txt
mkdir websites
mv allURLS.txt websites


echo
echo
echo "Finding SMB Ports"
nmap -Pn -iL hosts -p 445 -oG - | awk '/open/{print $2}' | tee smb-hosts.txt   
echo



#
#
#SNMP, MSQL Tests Etc
echo
echo "Finding SNMP Ports"
nmap -Pn -iL hosts -sU -p 161 -oG - | awk '/open/{print $2}' | tee snmp-hosts.txt;

echo
echo "Getting versions of SNMP"
#nmap -Pn -p 161 -sUV -iL snmp-hosts.txt -oG snmpVersion.txt
echo
echo "SNMP Version 1 or 2"
#cat snmpVersion.txt | grep open/udp | grep -v SNMPv3 | cut -d " " -f 2 | tee snmpver1or2.txt
echo
echo "SNMP Version 3"
#cat snmpVersion.txt | grep open/udp | grep SNMPv3 | cut -d " " -f 2 | tee snmpver3.txt   #for version 3
echo
echo "Finding IPMI ports"
nmap -Pn -iL hosts -p 623 -oG - | awk '/open/{print $2}' | tee ipmi623.txt
nmap -Pn -sU -iL hosts -p 623 -oG - | awk '/open/{print $2}' >> ipmi623.txt
echo

echo "Finding MSSQL Ports 1433"
nmap -Pn -iL hosts -p 1433 -oG - | awk '/open/{print $2}' | tee mssql-hosts.txt;

echo
echo "Finding MySQL Ports"
nmap -Pn -iL hosts -p 3306 -oG - | awk '/open/{print $2}' | tee mysql-hosts.txt;

echo
echo "Finding Oracle Ports"
nmap -Pn -iL hosts -p 1521 -oG - | awk '/open/{print $2}' | tee oracle-hosts.txt;

echo
echo "Finding PostGres Ports"
nmap -Pn -iL hosts -p 5432 -oG - | awk '/open/{print $2}' | tee postgres-hosts.txt;

echo
echo "Finding DcHosts Ports"
nmap -Pn -iL hosts -p 389 -oG - | awk '/open/{print $2}' | tee dc-hosts.txt;

echo
echo "Finding VNCHosts Ports"
nmap -Pn -iL hosts -p 5800,5900-5905 -oG - | awk '/open/{print $2}' | tee vnc-hosts.txt;
echo

echo
echo "Finding RPCBind Ports TCP"
nmap -Pn -iL hosts -p 111 -oG - | awk '/open/{print $2}' | tee rpcbind-hosts.txt;
echo

echo
echo "Finding RPCBind Ports TCP"
nmap -Pn -sU -iL hosts -p 111 -oG - | awk '/open/{print $2}' | tee rpcbind-hostsUDP.txt;
echo

#
#
#	Part 2 Running Tests
#



#	FTP tests
echo "2.1 FTP Tests"
for i in $(cat ftp-hosts.txt); do echo $i; curl ftp://$i/ --max-time 30; echo ""; done | tee ftp-scan.log
echo
echo
echo

#	Make files readable by plunder and run
echo
echo "2.2 Running Plunder"
for a in $(cat smb-hosts.txt); do echo "smb://$a" >> smb-urls.txt; done
echo "plunder-1.7.jar -q -u "" -p "" -f smb-urls.txt -P shares"
plunder-1.7.jar -q -u "" -p "" -f smb-urls.txt -P shares | tee plunder_anon.log #plunder is in my sbin
echo
echo
echo
#plunder-1.7.jar -q -u "" -p "" -f smb-urls.txt -P shares | tee plunder_aberegovsky.log



#Setting up SMB Metasploit and Bluesky scan
echo "2.3 Running Metapsloit Tests"
metasploitSMB(){ 
	#Run the SMB_Version module 
	touch smbMetasploit.rc
	echo "spool SMB-VERSION.log">>smbMetasploit.rc	
	echo "use auxiliary/scanner/smb/smb_version">>smbMetasploit.rc 
	echo "set RHOSTS file:smb-hosts.txt">>smbMetasploit.rc  
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc  
	echo "spool off">>smbMetasploit.rc
	#
	echo "spool SMB_ETERNALR_MS17_CHECK.log">>smbMetasploit.rc
	echo "use auxiliary/admin/smb/ms17_010_command">>smbMetasploit.rc 
	echo "set rhosts file:smb-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool SMB_MS17.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/smb/smb_ms17_010">>smbMetasploit.rc 
	echo "set rhosts file:smb-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool TELNET-CHECK.log">>smbMetasploit.rc
	echo "use scanner/telnet/telnet_version">>smbMetasploit.rc 
	echo "set rhosts file:telnet-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool SSH-CHECK.log">>smbMetasploit.rc
	echo "use scanner/ssh/ssh_version">>smbMetasploit.rc 
	echo "set rhosts file:ssh-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool SNMP-VER1-CHECK.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/snmp/snmp_login">>smbMetasploit.rc 
	echo "set rhosts file:snmp-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool MSQL-PING.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/mssql/mssql_ping">>smbMetasploit.rc 
	echo "set rhosts file:mssql-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool MSQL-CHECK.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/mssql/mssql_login">>smbMetasploit.rc 
	echo "set rhosts file:mssql-hosts.txt">>smbMetasploit.rc
	echo "set username admin" >>smbMetasploit.rc	
	echo "set password password" >>smbMetasploit.rc
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool VNC-AUTH-CHECK.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/vnc/vnc_none_auth">>smbMetasploit.rc 
	echo "set rhosts file:vnc-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool RPCBIND.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/nfs/nfsmount">>smbMetasploit.rc 
	echo "set rhosts file:rpcbind-hosts.txt">>smbMetasploit.rc
	echo "set protocol tcp">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool RPCBINDUDP.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/nfs/nfsmount">>smbMetasploit.rc 
	echo "set rhosts file:rpcbind-hostsUDP.txt">>smbMetasploit.rc
	echo "set protocol udp">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	#
	echo "spool IPMI-hash.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/ipmi/ipmi_dumphashes">>smbMetasploit.rc 
	echo "set rhosts file:ipmi623.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	echo "spool IPMI-ver.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/ipmi/ipmi_version">>smbMetasploit.rc 
	echo "set rhosts file:ipmi623.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	echo "spool IPMI-zero-cipher.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/ipmi/ipmi_cipher_zero">>smbMetasploit.rc 
	echo "set rhosts file:ipmi623.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	echo "exit">>smbMetasploit.rc 
	msfconsole -r smbMetasploit.rc
	
return 0
}

#Calling Metasploit Function
echo
metasploitSMB; #calling function
sleep 20; #in case you want to look
rm smbMetasploit.rc 

echo


#Running Automated "Anonymous LDAP Enumeration"	
echo "2.4 Running automated Anonymous LDAP Enumeration"
#lets get the domains
cat SMB-VERSION.log | grep domain | cut -d ":" -f 5 | trim.sh 1 | tail -n +2 | sort -u | uniq > domainnames.txt #you will need trim to make this work. Make a .sh file with sed 's/.\{'$1'\}$//' $2

#Double For Loop, trying anaonymous LDAP on each DC hosts and then each domain found by SMB
#Going through DC hosts in 'first' for loop
#Next inner for loop is of domains
echo
for i2 in $(cat dc-hosts.txt); #First outer loop of Dc-Hosts
	do echo "DC host $i2" >> anon-ldap-enum.log; 
	for i in $(cat domainnames.txt); #Inner loop of domainnames using the Dc-Host as 2nd variable
		do 
		echo "For Domain name $i using $i2" >> anon-ldap-enum.log;
		echo "rpcclient -U "%" -W $i -c enumdomusers $i2" >> anon-ldap-enum.log;
		rpcclient -U "%" -W $i -c enumdomusers $i2 >> anon-ldap-enum.log; 
	
		done;
echo ".........................................." >> anon-ldap-enum.log; 
done;

cat anon-ldap-enum.log

#Moving all logs to one file
mkdir metasploit-logs
for a in $(find *.log)
do mv $a metasploit-logs
done

#Changing to Metasploit Logs direcotry and then taking automated screenshots of logs. 
cd metasploit-logs
echo " 2.5 Make sure screen is fullsize for screenshots! Then hit a key and press ENTER"
read answer
renamer.sh #screenshots for SSL
screenshot2.sh


#
#
#	Part 3 Running Nmap Tests On Outdated Operaitng Systems 
#

echo
echo "3.1 Finding outdated versions..." >> oldOS.txt 
echo 'cat SMB-VERSION.log | grep -v "Windows 7" | grep -v "Windows 2012" | grep -v "Windows 10" | grep -v "not be identified" | grep -v "Windows 2016"' >> oldOS.txt

cat SMB-VERSION.log | grep -v "Windows 7" | grep -v "Windows 2012" | grep -v "Windows 10" | grep -v "not be identified" | grep -v "Windows 2016" | grep -v "Windows 10" | grep -v "Windows 8.1"

cat SMB-VERSION.log | grep -v "Windows 7" | grep -v "Windows 2012" | grep -v "Windows 10" | grep -v "not be identified" | grep -v "Windows 2016" | grep -v "Windows 10" | grep -v "Windows 8.1" | cut -d " " -f 2 | ipextract | tee oldOS.txt
echo
echo
echo "old Os nmap running..."
nmap -Pn -A -sSV --script "safe" -iL oldOS.txt -oG oldosgrep


