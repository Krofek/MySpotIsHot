#!/bin/bash

###################################################################################
########################START SCRIPT!!!############################################
###################################################################################
clear
echo "Welcome to MySpotIsHot!"
echo

if ! dpkg-query -W hostapd || ! dpkg-query -W dnsmasq; then
	sudo apt-get update
	if ! dpkg-query -W hostapd; then sudo apt-get install hostapd
	elif ! dpkg-query -W dnsmasq; then sudo apt-get install dnsmasq
	fi
else
	echo
	echo "The required packages are installed!"
fi
echo

#sudo apt-get install hostapd dnsmasq

#sudo service hostapd stop && sudo service dnsmasq stop
#sudo update-rc.d hostapd disable && sudo update-rc.d dnsmasq disable


#GLOBAL VARS
dnsmasq=/etc/dnsmasq.conf
hostapd=/etc/hostapd.conf

#BACKUP DNSMASQ
f_backup() {
if [ ! -f ${dnsmasq}.bak ]; then
	echo "$dnsmasq isn't backed up yet, please press any key to backup now!"
	read -sn 1
	cp $dnsmasq ${dnsmasq}.bak
	echo "$dnsmasq backup created!"
	echo
	break
else
	echo "Backup already created, press Enter to continue setup or R to restore $dnsmasq"
	read -sn 1 restore
	if [[ $restore = "" ]]; then
		break
	elif [[ $restore = "r" || $restore = "R" ]]; then
		cp ${dnsmasq}.bak $dnsmasq
		break
	else
		echo "WTF, only 1 of 2 possible keys to press and you f*** it up..."
		echo
	fi
fi
}

#CHECK DNSMASQ.CONF
f_showdns() {
egrep -xq "^interface=.*|^dhcp-range=.*" $dnsmasq
}

#DNSMASQ FUNC
f_dnsmasq() {
echo "Setting up /etc/dnsmasq.conf"
if f_showdns; then
	cat $dnsmasq | egrep "^bind-interfaces|^interface=.*|^dhcp-range=.*"
else
    	echo "/etc/dnsmasq.conf not yet configured"
	echo
fi

#Dnsmasq config
echo "Press N for new /etc/dnsmasq.conf settings or Enter to use the ones above:"
read -sn 1 cdnsmasq
if [[ $cdnsmasq = "" ]] && f_showdns; then 
	cdnsmasq=$dnsmasq
	break
elif [[ $cdnsmasq = "" ]] && ! f_showdns; then
	echo "/etc/dnsmasq.conf not yet configured"
	echo
elif [[ $cdnsmasq = "N" || $cdnsmasq = "n" ]]; then
	echo
	iwconfig 2>&1 | grep wlan
	echo

	#Chose wlan adapter
	echo "Choose the wlan interface adapter from the ones above [Default: wlan0]"
	read wlan
	if [[ $wlan = "" ]]; then
		unset wlan
	fi

	#Set dhcp range
	echo "Set the dhcp range [Default: 192.168.150.2,192.168.150.10]:"
	read dhcp

	if [[ $dhcp = "" ]]; then 
		unset dhcp 
	fi
	
	#Write to /etc/dnsmasq.conf
	if f_showdns; then
		sed -i "s/^interface=.*/interface=${wlan:-wlan0}/" $dnsmasq
		sed -i "s/^dhcp-range=.*/dhcp-range=${dhcp:-192.168.150.2,192.168.150.10}/" $dnsmasq
	else
		echo "bind-interfaces
interface=$wlan
dhcp-range=${dhcp:-192.168.150.2,192.168.150.10}" >> $dnsmasq
	break
	fi
fi
}

#HOSTAPD FUNC
f_hostapd() {
echo Setting up /etc/hostapd.conf
echo

if [ ! -f $hostapd ]; then
	echo "File $hostapd does not exist"
	echo
else
	echo "hostapd.conf:"
	cat $hostapd
	echo
fi

#Hostapd setup start
echo "Press N for new hostapd.conf or Enter to use the one above:"
read -sn 1 chostapd
if [[ $chostapd = "" && -f $hostapd ]]; then 
	chostapd=$hostapd
	break
elif [[ $chostapd = "" && ! -f $hostapd ]]; then
	echo "File $hostapd does not exist!"
	echo
elif [[ $chostapd = "N" || $chostapd = "n" ]]; then
	echo
	iwconfig 2>&1 | grep wlan
	echo

	#Chose wlan adapter
	echo "Choose the wlan interface adapter from the ones above [Default: wlan0]"
	read wlan
	if [[ $wlan = "" ]]; then
		unset wlan
	fi

	#SSID name
	echo "Chose a hotspot name"
	read ssid

	#Password
	echo "Type the hotspot password"
	read pass

	#Channel
	echo "Choose a channel from 1-12 [Default: 6]"
	read channel
	if [[ $channel = "" ]]; then
		unset channel
	fi

	#Radio mode
	echo "Chose a radio mode between b, g, n [Default: g]"
	read -n 1 hwmode
	if [[ $hwmode = "" ]]; then
		unset hwmode
	fi

	#WPA type
	echo "Enable WPA2 only (1 for WPA, 2 for WPA2, 3 for WPA + WPA2)[Default: 2]"
	read -n 1 wpa
	if [[ $wpa = "" ]]; then
		unset wpa
	fi

	rm -rf $hostapd
	touch $hostapd
	echo "interface=${wlan:-wlan0}
driver=nl80211
ssid=$ssid
hw_mode=${hwmode:-g}
channel=${channel:-6}
wmm_enabled=1
ieee80211n=1
ht_capab=[HT40-][SHORT-GI-20][SHORT-GI-40]
wpa=${wpa:-2}
wpa_passphrase=$pass
wpa_pairwise=TKIP CCMP" > $hostapd
	break
fi
}

#CREATE EXECUTABLE SCRIPT -> check if it exists, create new, show the few changeable variables...
#f_execute() {
#}

#DO YOU WANT TO START THE HOTSPOT ON SYSTEM STARTUP?
#f_startup() {
#}

###################################################################################
########################EXECUTE FUNCTIONS!!!#######################################
###################################################################################

#EXEC DNSMASQ
while :
do
	f_backup
done

#EXEC DNSMASQ
while :
do
	f_dnsmasq
done

#EXEC HOSTAPD
while :
do
	f_hostapd
done

#FINISH SETUP
echo
echo "Setup is completed, press any key to exit now!"
read -sn 1
echo
