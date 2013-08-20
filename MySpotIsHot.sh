#!/bin/bash

#GLOBAL VARS
dnsmasq=/etc/dnsmasq.conf
hostapd=/etc/hostapd.conf
start=~/start.sh

###################################################################################
################################FUNCTIONS!!!#######################################
###################################################################################

#WELCOME
f_welcome() {
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

#sudo service hostapd stop && sudo service dnsmasq stop
#sudo update-rc.d hostapd disable && sudo update-rc.d dnsmasq disable
}

#BACKUP DNSMASQ
f_backup() {
echo
echo "1.) Backup or restore $dnsmasq!"
echo
if [ ! -f ${dnsmasq}.bak ]; then
	echo "$dnsmasq isn't backed up yet, please press any key to backup now!"
	read -sn 1
	sudo cp $dnsmasq ${dnsmasq}.bak
	echo "$dnsmasq backup created!"
	echo
	break
else
	echo "Backup already created, press Enter to continue setup or R to restore $dnsmasq"
	read -sn 1 restore
	if [[ $restore = "" ]]; then
		break
	elif [[ $restore = "r" || $restore = "R" ]]; then
		sudo cp ${dnsmasq}.bak $dnsmasq
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
echo
clear
echo "2.) Setting up /etc/dnsmasq.conf!"
echo
if f_showdns; then
	echo "Current settings:"
	echo
	cat $dnsmasq | egrep "^bind-interfaces|^interface=.*|^dhcp-range=.*"
else
    	echo "/etc/dnsmasq.conf not yet configured"
	echo
fi

#Dnsmasq config
echo
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
		sudo sed -i "s/^interface=.*/interface=${wlan:-wlan0}/" $dnsmasq
		sudo sed -i "s/^dhcp-range=.*/dhcp-range=${dhcp:-192.168.150.2,192.168.150.10}/" $dnsmasq
	else
		echo "bind-interfaces
interface=$wlan
dhcp-range=${dhcp:-192.168.150.2,192.168.150.10}" | sudo tee -a $dnsmasq
	break
	fi
fi
}

#HOSTAPD FUNC
f_hostapd() {
echo
clear
echo "3.) Setting up /etc/hostapd.conf!"
echo

if [ ! -f $hostapd ]; then
	echo "File $hostapd does not exist"
	echo
else
	echo "Current settings:"
	echo
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
	echo
	if [[ $hwmode = "" ]]; then
		unset hwmode
	fi

	#WPA type
	echo "Enable WPA2 only (1 for WPA, 2 for WPA2, 3 for WPA + WPA2)[Default: 2]"
	read -n 1 wpa
	echo
	if [[ $wpa = "" ]]; then
		unset wpa
	fi

	sudo rm -rf $hostapd
	sudo touch $hostapd
	clear
	echo "New $hostapd created! Your settings:"
	echo
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
wpa_pairwise=TKIP CCMP" | sudo tee -a $hostapd
	echo
	echo "Press any key to continue to the next step!"
	read -sn 1
	break
fi
}

#CREATE EXECUTABLE SCRIPT -> check if it exists, create new, show the few changeable variables...
f_crstart() {
#Chose wlan adapter
echo
iwconfig 2>&1 | grep wlan
echo
echo "Choose the wlan interface adapter from the ones above [Default: wlan0]"
read wlan
if [[ $wlan = "" ]]; then
	unset wlan
fi

#Chose eth adapter
echo
ifconfig | grep -i ethernet
echo
echo "Choose the ethernet adapter connected to the internet from the ones above [Default: eth0]"
read eth
if [[ $eth = "" ]]; then
	unset eth
fi

touch $start
echo "#!/bin/bash
rfkill unblock wifi
sudo ifconfig ${wlan:-wlan0} 192.168.150.1
sudo service dnsmasq restart
sudo sysctl net.ipv4.ip_forward=1
sudo iptables -t nat -A POSTROUTING -o ${eth:-eth0} -j MASQUERADE
sudo hostapd /etc/hostapd.conf
sudo iptables -D POSTROUTING -t nat -o ${eth:-eth0} -j MASQUERADE
sudo sysctl net.ipv4.ip_forward=0
sudo service dnsmasq stop
sudo service hostapd stop" > $start
chmod u+x $start
}

#CHECK IF START SCRIPT EXISTS
f_execute() {
echo
clear
echo "4.) Startup script setup!"
echo
if [ ! -f $start ]; then
	echo "$start script isn't created yet, please press any key to create it now!"
	read -sn 1
	echo
	f_crstart
	echo "$start script created!"
	break
else
	echo "Start script already created!" 
	echo
	echo "Press Enter to continue setup, V to view the existing one or N to create a new one!"
	read -sn 1 crstart
	if [[ $crstart = "" ]]; then
		break
	elif [[ $crstart = "n" || $crstart = "N" ]]; then
		f_crstart
		echo "$start script created!"
	elif [[ $crstart = "v" || $crstart = "V" ]]; then
		clear
		echo "Your $start script settings:"
		echo
		cat $start
		echo
		echo "Press any key to continue!"
		read -sn 1
	fi
fi
}

#DO YOU WANT TO START THE HOTSPOT ON SYSTEM STARTUP?
#f_startup() {
#
#}

###################################################################################
########################START SCRIPT!!!############################################
###################################################################################

#EXEC WELCOME
f_welcome

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

#EXEC START SCRIPT
while :
do
	f_execute
done

#FINISH SETUP
echo
echo "You're all done, press any key to exit now!"
read -sn 1
echo
clear
