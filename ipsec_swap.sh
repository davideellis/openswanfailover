#!/bin/bash

if [ -z "$1" ]; then
	echo ""
	echo "SYNTAX: ./ipsec_swap.sh <vpn name without a/b>"
	echo ""
	
	routed=($(ipsec status | grep erouted | cut -d'"' -f2))
	count=${#routed[@]}
	inc=0
	echo "Active VPN Path"
	while [ $inc -lt $count ]
	do
		echo ${routed[$inc]}
		inc=$((inc+1))
	done	
	echo ""
	
	unrouted=($(ipsec status | grep unrouted | cut -d'"' -f2))
	count=${#unrouted[@]}
	inc=0
	echo "Inactive VPN Path"
	while [ $inc -lt $count ]
	do
		echo ${unrouted[$inc]}
		inc=$((inc+1))
	done
else

	route_remove=($(ipsec status | grep erouted | grep $1 | cut -d'"' -f2))
	route_add=($(ipsec status | grep unrouted | grep $1 | cut -d'"' -f2))
	ipsec auto --down $route_remove
	ipsec auto --unroute $route_remove
	ipsec auto --up $route_add
	ipsec auto --route $route_add
	sleep 2
	
	echo ""
	routed=($(ipsec status | grep erouted | cut -d'"' -f2))
	timestamp=$(date +%s)
	echo "$timestamp Current VPN Routes"
	count=${#routed[@]}
	inc=0
	while [ $inc -lt $count ]
	do
		echo ${routed[$inc]}
		inc=$((inc+1))
        done
fi
