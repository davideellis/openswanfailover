#!/bin/bash
logfile=/var/log/ipsec_check.log
conffile=/etc/ipsec_check.conf
tmpconf=/tmp/ipsec_check.conf

grep -v ^# $conffile > /tmp/ipsec_check.conf

#Read the config file for sites/IPs
cat $tmpconf | while read line
	do
		ip_a=($(echo $line | cut -d"=" -f2 | cut -f1 -d","))
		ip_b=($(echo $line | cut -d"," -f2))
		vpn=($(echo $line | cut -d"=" -f1))
		echo "Checking $vpn..."
		ping -c 1 -W 1 $ip_a > /dev/null
		checkping_a=$?
		if [[ $checkping_a -eq 0 ]]; then
			echo "$ip_a... success!"
		else 
			echo "$ip_a... zomg!"
		fi
        	ping -c 1 -W 1 $ip_b > /dev/null
		checkping_b=$?
		if [[ $checkping_b -eq 0 ]]; then
			echo "$ip_b... success!"
		else
			echo "$ip_b... zomg!"
		fi
	
		#Decide if the VPN should be kicked over to the failover.
		checkping=$((checkping_a + checkping_b))
		if [[ $checkping -ge 2 ]]; then
			echo "panic!"
			timestamp=$(date +%s)
        	        echo "$timestamp $vpn failed! Swapping to backup VPN tunnel." >> $logfile
			/usr/bin/ipsec_swap.sh $vpn >> $logfile
			echo "" >> $logfile
		else
			echo ""
		fi
		echo ""
done
