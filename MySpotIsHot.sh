#!/bin/bash

#GLOBAL VARS
dnsmasq=/etc/dnsmasq.conf
hostapd=/etc/hostapd.conf
start=/usr/sbin/myspotishot.sh
service=/etc/init/myspotishot.conf

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
	if ! dpkg-query -W hostapd; then sudo apt-get install hostapd; fi
	if ! dpkg-query -W dnsmasq; then sudo apt-get install dnsmasq; fi	
else
	echo
	echo "The required packages are installed!"
fi
echo

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
	elif  [[ $hwmode = "n" ]]; then
		unset hwmode
		nmode="n"
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
wpa=${wpa:-2}
wpa_passphrase=$pass
wpa_pairwise=TKIP CCMP" | sudo tee -a $hostapd
	if  [[ $nmode = "n" ]]; then
		unset nmode
		echo "wmm_enabled=1
ieee80211n=1
ht_capab=[HT40-][SHORT-GI-20][SHORT-GI-40]" | sudo tee -a $hostapd
	fi
	echo
	echo "Press any key to continue to the next step!"
	read -sn 1
	break
fi
}

#CREATE EXECUTABLE SCRIPT
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

sudo rm -rf $start
sudo touch $start
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
sudo service hostapd stop" | sudo tee -a $start &>/dev/null
sudo chmod u+x $start
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

#CREATE SERVICE
f_initd() {
sudo rm -rf $service
sudo touch $service
echo 'description "MySpotIsHot service!"
author "Matej Vrabec"

pre-start script
    echo "Starting MySpotIsHot"
end script

post-stop script
    echo "Stopping MySpotIsHot"
end script

exec sudo sh /usr/sbin/myspotishot.sh' | sudo tee -a $service &>/dev/null
}

#RUN AT SYSTEM START
#
# add: start on filesystem
# remove: line: start on filesystem
# option: respawn if down

#SERVICE RUN

f_serstart() {
clear
echo "6.) If you want to start the service right away press S or Enter to finish!"
read -n 1 sstart
echo
if [[ $sstart = "" ]]; then
	break
elif [[ $sstart = "s" || $sstart = "S" ]]; then
	sudo start myspotishot 
	echo "Your hotspot is up and running...probably xD"
	break
fi
}

#SERVICE SETUP
f_service() {
echo
clear
echo "5.) MySpotIsHot service setup"
echo
if [ ! -f $service ]; then
	echo "MySpotIsHot service not present, press C to create it or Enter if you want to start your hotspot manually!"
	read -n 1 servicecr
	echo
	if [[ $servicecr = "c" || $servicecr = "C" ]]; then
		f_initd
		echo "MySpotIsHot service created!"
		echo
		echo "Usage: sudo {start|stop|status} myspotishot"
		echo
		f_serstart
		break
	elif [[ $servicecr = "" || $servicecr = "" ]]; then
		break
	fi
else
	echo "MySpotIsHot service already installed. Usage: sudo {start|stop|status} myspotishot"
	echo
	echo "Press D to delete it or Enter to continue"
	read -n 1 servicedel
	echo
	if [[ $servicedel = "d" || $servicedel = "D" ]]; then
		sudo rm -rf $service
		echo "MySpotIsHot service deleted!"
	elif [[ $servicedel = "" || $servicedel = "" ]]; then
		f_serstart
		break
	fi
fi
}



###################################################################################
########################START SCRIPT!!!############################################
###################################################################################

#EXEC WELCOME
f_welcome

sudo service hostapd stop && sudo service dnsmasq stop
sudo update-rc.d hostapd disable && sudo update-rc.d dnsmasq disable

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

#EXEC CREATE START SCRIPT
while :
do
	f_execute
done

#EXEC CREATE SERVICE
while :
do
	f_service
done

#FINISH SETUP
echo
echo "You're all done, press any key to exit now!"
read -sn 1
echo
clear
