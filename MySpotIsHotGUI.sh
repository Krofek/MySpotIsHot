#!/bin/bash

f_default() {
echo -e -n 'SSID="ssid"
PASS="password"
ETH="eth0"
WLAN="wlan0"
DHCP="192.168.150.2,192.168.150.10"
STARTUP="false"
VISIB="disabled"
HWMODE1="false"
HWMODE2="true"
HWMODE3="false"
CHANNEL="6"
WPA="WPA+WPA2"' > .myspotrc
}
export -f f_default

###############STARTUP########################

[ ! -s .myspotrc ] && f_default
. .myspotrc

mkdir temp
touch temp/ssid temp/pass temp/eth temp/wlan temp/dhcp temp/visib temp/hwmode temp/statusbar temp/startup

[ ! -f "${dnsmasq}.bak" ] && sudo cp "$dnsmasq" "${dnsmasq}.bak"

#######################VARS#########################

URL="https://github.com/Krofek"
VERSION=v0.5beta
EXECFUNC="exec $SHELL -c"
service=/etc/init/myspotishot.conf
dnsmasq=/etc/dnsmasq.conf
hostapd=/etc/hostapd.conf
start=/usr/sbin/myspotishot.sh

CHANNELS="<item>$CHANNEL</item>"
for I in 1 2 3 4 5 6 7 8 9 10 11 12; do CHANNELS=`echo "$CHANNELS<item>$I</item>"`; done

export service dnsmasq hostapd start EXECFUNC

##########################FONTS#####################

echo 'style "specialmono"
{
  	font_name="Mono 8"
}
widget "*mono" style "specialmono"
class "GtkText*" style "specialmono"' > /tmp/gtkrc_mono

export GTK2_RC_FILES=/tmp/gtkrc_mono:/root/.gtkrc-2.0 

####################FUNCTIONS#######################

f_restoredns() {
sudo cp "${dnsmasq}.bak" "$dnsmasq"
}

f_showdns() {
egrep -xq "^interface=.*|^dhcp-range=.*" $dnsmasq
}

f_dnsmasq() {
if f_showdns; then
		sudo sed -i "s/^interface=.*/interface=$WLAN/" $dnsmasq
		sudo sed -i "s/^dhcp-range=.*/dhcp-range=$DHCP/" $dnsmasq
else
		echo "bind-interfaces
interface=$WLAN
dhcp-range=$DHCP" | sudo tee -a $dnsmasq
fi
}

f_hwmode() {
if [[ $HWMODE1 = "true" ]]; then
		echo "hw_mode=b" | sudo tee -a $hostapd
elif [[ $HWMODE2 = "true" ]]; then
		echo "hw_mode=g" | sudo tee -a $hostapd
elif [[ $HWMODE3 = "true" ]]; then
		echo "hw_mode=g" | sudo tee -a $hostapd
fi
}

f_wpa() {
if [[ $WPA = "WPA+WPA2" ]]; then echo "wpa=3" | sudo tee -a $hostapd
elif [[ $WPA = "WPA2" ]]; then echo "wpa=2" | sudo tee -a $hostapd
elif [[ $WPA = "WPA" ]]; then echo "wpa=1" | sudo tee -a $hostapd; fi
}

f_hostapd() {
sudo rm -rf $hostapd
sudo touch $hostapd
echo "interface=$WLAN
driver=nl80211" | sudo tee -a $hostapd
f_hwmode
if  [[ $HWMODE3 = "true" ]]; then
		echo "ieee80211n=1
wmm_enabled=1" | sudo tee -a $hostapd
fi
echo "channel=$CHANNEL
ssid=KrofekSSID" | sudo tee -a $hostapd
f_wpa
echo "wpa_passphrase=$PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
macaddr_acl=0" | sudo tee -a $hostapd
if  [[ $HWMODE3 = "true" ]]; then
	echo "ht_capab=[HT20][SHORT-GI-20]]" | sudo tee -a $hostapd
fi
echo "eap_reauth_period=360000000
ignore_broadcast_ssid=0" | sudo tee -a $hostapd
}

f_restore() {
echo "ssid" > temp/ssid
echo "password" > temp/pass
echo "eth0" > temp/eth
echo "wlan0" > temp/wlan
echo "192.168.150.2,192.168.150.10" > temp/dhcp
echo "false" > temp/startup
echo "disabled" > temp/visib
echo "true" > temp/hwmode
}
export -f f_restore f_restoredns

f_visib() {
sed -i 's/^VISIB="disabled"$/VISIB="enabled"/' .myspotrc
}
f_invisib() {
sed -i 's/^VISIB="enabled"$/VISIB="disabled"/' .myspotrc
}
export -f f_visib f_invisib f_hwmode f_hostapd f_showdns f_dnsmasq f_wpa

#write config
f_config() {
echo -e -n "SSID=\"$SSID\"\nPASS=\"$PASS\"\nETH=\"$ETH\"\nWLAN=\"$WLAN\"\nDHCP=\"$DHCP\"\nVISIB=\"$VISIB\"\nSTARTUP=\"$STARTUP\"\nSTARTUP0="$STARTUP0"\nSTARTUP1="$STARTUP1"\nSTARTUP2="$STARTUP2"\nHWMODE1=\"$HWMODE1\"\nHWMODE2=\"$HWMODE2\"\nHWMODE3=\"$HWMODE3\"\nCHANNEL=\"$CHANNEL\"\nWPA=\"$WPA\"" > .myspotrc
}

#write upstart script

f_init() {
sudo rm -rf $service
sudo touch $service
echo 'description "MySpotIsHot service!"
author "Matej Vrabec"' | sudo tee -a $service &>/dev/null

if [[ $STARTUP1 = "true" ]]; then
    echo "
start on local-filesystems
respawn" | sudo tee -a $service &>/dev/null

elif [[ $STARTUP2 = "true" ]]; then
    echo "
start on net-device-up IFACE=$ETH
respawn" | sudo tee -a $service &>/dev/null
else
    echo ""
fi

echo '
stop on runlevel [!12345]

pre-start script
    echo "Starting MySpotIsHot"
end script

post-stop script
    echo "Stopping MySpotIsHot"
end script

exec sudo sh /usr/sbin/myspotishot.sh' | sudo tee -a $service &>/dev/null
}
export -f f_init f_config

f_prereq() {
sudo apt-get update && echo "APT updated!" && sleep 2
if ! dpkg-query -W hostapd; then sudo apt-get install -y hostapd && echo hostapd installed; fi
if ! dpkg-query -W dnsmasq; then sudo apt-get install -y dnsmasq && echo dnsmasq installed; fi
echo "Done! Please close the window!" 
}
export -f f_prereq

#############################
#########WINDOWS#############
#############################

export prereq='
<variable>prereq</variable>
<vbox>
	<frame Progress>
		<text>
			<label>Installing needed packages.</label>
		</text>
		<progressbar>
			<label>Some Text</label>
			<input>'$EXECFUNC' f_prereq</input>
		</progressbar>
	</frame>
</vbox>
'

export about='
<window allow-grow="false" title="About">
	<frame>
		<vbox homogeneous="true">
			<text use-markup="true">
				<label>"<span weight='"'bold'"' size='"'large'"'>MySpotIsHot '$VERSION'</span>"</label>
			</text>
			<text use-markup="true">
				<label>"<span><a href='"'...'"'>Krofek@GitHub</a></span>"</label>
				<action signal="button-press-event">if which xdg-open > /dev/null; then xdg-open '"$URL"'; elif which gnome-open > /dev/null; then gnome-open '"$URL"'; fi</action>
			</text>
		</vbox>
	</frame>
<variable>about</variable>
</window>
'

export main='
<window allow-grow="false" title="MySpotIsHot">

<vbox>
<hbox>
<vbox>

	<frame Settings>
	<hbox>
		<text><label>SSID name</label></text>
		<entry editable="true" allow-empty="false">
			<variable>SSID</variable>
			<input>echo '$SSID'</input>
		</entry>
	</hbox>

	<hbox>
		<text><label>Password</label></text>
		<entry visibility="false" caps-lock-warning="true" editable="true" allow-empty="false">
			<variable>PASS</variable>
			<input>echo '$PASS'</input>
		</entry>
	</hbox>

	<hbox>
		<text><label>Choose ethernet adapter</label></text>
		<entry>
			<variable>ETH</variable>
			<input>echo '$ETH'</input>
			<input file>temp/eth</input>
		</entry>
		<button>
			<input file stock="gtk-new"></input>
			<action>ifconfig | grep eth | zenity --text-info  --width=700 --height=500 --title "Ethernet adapters" &</action>
		</button>
	</hbox>

	<hbox>
		<text><label>Choose wlan adapter</label></text>
		<entry>
			<variable>WLAN</variable>
			<default>'$WLAN'</default>
			<input>echo '$WLAN'</input>
		</entry>
		<button>
			<input file stock="gtk-new"></input>
		  <action>iwconfig 2>&1 | grep wlan | zenity --text-info  --width=700 --height=500 --title "Wlan adapters" &</action>
		</button>
	</hbox>

	<hbox>
		<text><label>DHCP range</label></text>
		<entry>
			<variable>DHCP</variable>
			<default>'$DHCP'</default>
			<input>echo '$DHCP'</input>
		</entry>
	</hbox>

	<hbox>
		<combobox>
		<variable>CHANNEL</variable>
		'$CHANNELS'
		</combobox>
		<combobox editable="false">
			<variable>WPA</variable>
			<item>WPA+WPA2</item>
			<item>WPA2</item>
			<item>WPA</item>
		</combobox>
	</hbox>

	<hbox>
        <text><label>Choose 802.11x mode</label></text>
		<radiobutton label="b">
			<variable>HWMODE1</variable>
		 	<default>'$HWMODE1'</default>
		</radiobutton>
		<radiobutton label="g">
			<variable>HWMODE2</variable>
		 	<default>'$HWMODE2'</default>
		 	<input file>temp/hwmode</input>
		</radiobutton>
		<radiobutton label="n">
			<variable>HWMODE3</variable>
		 	<default>'$HWMODE3'</default>
		</radiobutton>
	</hbox>

    <hbox>
        <text><label>Startup options</label></text>
        <checkbox>
            <label>""</label>
            <variable>STARTUP</variable>
            <default>'$STARTUP'</default>
            <action>if true enable:STARTUP1</action>
            <action>if true enable:STARTUP2</action>
            <action>if false disable:STARTUP1</action>
            <action>if false disable:STARTUP2</action>
            <action>if false echo "true" > temp/startup</action>
			<action>refresh:STARTUP0</action>
			<action>refresh:STARTUP1</action>
			<action>refresh:STARTUP2</action>
       </checkbox>
        <radiobutton label="None" visible="false">
            <variable>STARTUP0</variable>
            <input>echo '$STARTUP0'</input>
            <input file>temp/startup</input>
		</radiobutton>
        <radiobutton label="Filesystem">
			<variable>STARTUP1</variable>
            <visible>'$VISIB'</visible>
		</radiobutton>
		<radiobutton label="Internet up">
			<variable>STARTUP2</variable>
            <visible>'$VISIB'</visible>
		</radiobutton>

    </hbox>
	</frame>

	<frame Show configs>
	<hbox homogeneous="true">
		<button>
			<label>hostapd.conf</label>
			<action>cat /etc/hostapd.conf | zenity --text-info  --width=300 --height=500 --title "/etc/hostapd.conf" &</action>
		</button>
		<button>
			<label>dnsmasq.conf</label>
			<action>cat /etc/dnsmasq.conf | zenity --text-info  --width=600 --height=500 --title "/etc/dnsmasq.conf" &</action>
		</button>
	</hbox>
	</frame>

	<frame Manage service>
		<hbox homogeneous="True">
			<button>
				  <label>Start!</label>
				  <input file stock="gtk-yes"></input>
				  <action>sudo start myspotishot > temp/statusbar</action>
				  <action type="refresh">STATUS</action>
			</button>
			<button>
				  <label>Status</label>
				  <action>sudo status myspotishot > temp/statusbar</action>
  				  <action type="refresh">STATUS</action>
			</button>
			<button>
				  <label>Stop!</label>
				  <input file stock="gtk-stop"></input>
				  <action>sudo stop myspotishot > temp/statusbar</action>
				  <action type="refresh">STATUS</action>
			</button>
		</hbox>
	</frame>

  	<hbox space-expand="false" space-fill="false">
	  	<button width-request="85">
  			<input file stock="gtk-undo"></input>
  			<label>Restore Defaults</label>
  			<variable>RESTORE</variable>
  			<action>'$EXECFUNC' f_restore</action>
		    <action>refresh:SSID</action>
		    <action>refresh:PASS</action>
		    <action>refresh:ETH</action>
		    <action>refresh:WLAN</action>
		    <action>refresh:DHCP</action>
		    <action>refresh:HWMODE2</action>
		    <action>refresh:STARTUP1</action>
  		</button>
  	<hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
  	    <button>
            <label>Apply</label>
            <input file stock="gtk-apply"></input>
            <action>'$EXECFUNC' f_init</action>
            <action>'$EXECFUNC' f_hostapd</action>
            <action>'$EXECFUNC' f_dnsmasq</action>
    		<action>echo "Settings applied, check configs to be sure!" > temp/statusbar</action>
		    <action>refresh:STATUS</action>
        </button>
 		<button ok>
	 		<input file stock="gtk-ok"></input>
 		</button>
 		<button cancel>
 		</button>
	</hbox>

	
</vbox>
<vbox>
	<frame Terminal>
		<timer milliseconds="true" interval="100" visible="false">
			<action type="refresh">MYTERM</action>
		</timer>	

		<text name="mono">
			<variable>MYTERM</variable>
			<input>sudo tail /var/log/upstart/myspotishot.log</input>
		</text>
	</frame>

<hbox>
	<button>
		<label>Restore dnsmasq!</label>
		<action>'$EXECFUNC' f_restoredns</action>
		<action>echo "dnsmasq.conf successfully restored" > temp/statusbar</action>
	    <action>refresh:STATUS</action>
	</button>
	<hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
	<button>
		<label>Install packages</label>
		<action type="launch">prereq</action>
	</button>
	<button>
		<label>About</label>
		<action type="launch">about</action>
	</button>
</hbox>

</vbox>
</hbox>
	
	<statusbar has-resize-grip="false" auto-refresh="true">
		<variable>STATUS</variable>
		<input file>temp/statusbar</input>
	</statusbar>

</vbox>
<variable>main</variable>
</window>'

########################################################
###########################ENDING#######################
########################################################

#if ! dpkg-query -W hostapd || ! dpkg-query -W dnsmasq; then
#	gtkdialog --center --program prereq
#else
#	gtkdialog --center --program main
#fi

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog --center --program main); do
  eval $STATEMENTS
done
IFS=$I


if [ ! "$EXIT" = "OK" ]; then
	rm -rf temp/
  	exit 0
else
	rm -rf temp/
    f_config
    if [[ $STARTUP = "true" ]]; then f_visib; else f_invisib; fi
fi
