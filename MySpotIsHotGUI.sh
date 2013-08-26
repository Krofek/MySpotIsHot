#!/bin/bash

f_config() {
echo -e -n "SSID=\"$SSID\"\nPASS=\"$PASS\"\nETH=\"$ETH\"\nWLAN=\"$WLAN\"\nDHCP=\"$DHCP\"\nSTARTUP="$STARTUP"\nSTARTUP0="$STARTUP0"\nSTARTUP1="$STARTUP1"\nSTARTUP2="$STARTUP2"\nHWMODE1=\"$HWMODE1\"\nHWMODE2=\"$HWMODE2\"\nHWMODE3=\"$HWMODE3\"\n" > .myspotrc
}

if [ ! -s .myspotrc ]; then echo -e -n 'SSID="ssid"\nPASS="password"\nETH="eth0"\nWLAN="wlan0"\nDHCP="192.168.150.2,192.168.150.10"\nSTARTUP="false"\nHWMODE1="false"\nHWMODE2="true"\nHWMODE3="false"\n' > .myspotrc; fi
. .myspotrc

URL="https://github.com/Krofek"

VERSION=v0.2alpha

EXECFUNC="exec $SHELL -c"

service=/etc/init/myspotishot.conf
export service EXECFUNC

f_startup() {
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
}
export -f f_startup

f_init() {
sudo rm -rf $service
sudo touch $service
echo 'description "MySpotIsHot service!"
author "Matej Vrabec"' | sudo tee -a $service &>/dev/null

f_startup

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
export -f f_init

export main='
<window allow-grow="false" title="MySpotIsHot">

<vbox>

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

	<frame Settings>
	<hbox>
		<text><label>SSID name</label></text>
		<entry editable="true" allow-empty="false">
			<variable>SSID</variable>
			<default>'$SSID'</default>
			<input>echo '$SSID'</input>
		</entry>
	</hbox>

	<hbox>
		<text><label>Password</label></text>
		<entry visibility="false" caps-lock-warning="true" editable="true" allow-empty="false">
			<variable>PASS</variable>
			<default>'$PASS'</default>
			<input>echo '$PASS'</input>
		</entry>
	</hbox>

	<hbox>
		<text><label>Choose ethernet adapter</label></text>
		<entry>
			<variable>ETH</variable>
			<default>'$ETH'</default>
			<input>echo '$ETH'</input>
		</entry>
		<button>
			<input file stock="gtk-new"></input>
			<action>ifconfig | grep -i ethernet | zenity --text-info  --width=700 --height=500 --title "Ethernet adapters" &</action>
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
        <text><label>Choose 802.11x mode</label></text>
		<radiobutton label="b">
			<variable>HWMODE1</variable>
		 	<default>'$HWMODE1'</default>
		</radiobutton>
		<radiobutton label="g">
			<variable>HWMODE2</variable>
		 	<default>'$HWMODE2'</default>
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
            <action>if true enable:STARTUP0</action>
            <action>if true enable:STARTUP1</action>
            <action>if true enable:STARTUP2</action>
            <action>if false disable:STARTUP0</action>
            <action>if false disable:STARTUP1</action>
            <action>if false disable:STARTUP2</action>
        </checkbox>
        <radiobutton label="None">
			<variable>STARTUP0</variable>
            <visible>disabled</visible>
		</radiobutton>
        <radiobutton label="Filesystem">
			<variable>STARTUP1</variable>
            <visible>disabled</visible>
		</radiobutton>
		<radiobutton label="Internet up">
			<variable>STARTUP2</variable>
            <visible>disabled</visible>
		</radiobutton>

    </hbox>
	</frame>

	<frame Show configs>
	<hbox homogeneous="true">
		<button>
			<label>Show hostapd.conf</label>
			<action>cat /etc/hostapd.conf | zenity --text-info  --width=300 --height=500 --title "/etc/hostapd.conf" &</action>
		</button>
		<button>
			<label>Show dnsmasq.conf</label>
			<action>cat /etc/dnsmasq.conf | zenity --text-info  --width=600 --height=500 --title "/etc/hostapd.conf" &</action>
		</button>
	</hbox>
	</frame>

	<frame Manage service>
	<hbox homogeneous="True">
		<button>
		  <label>Start!</label>
		  <input file stock="gtk-yes"></input>
		  <action>sudo start myspotishot</action>
		  <action type="refresh">STATUS</action>
		</button>
		<button>
		  <label>Status</label>
		  <action>sudo tail -f /var/log/upstart/myspotishot.log | zenity --text-info  --width=500 --height=500 --title "myspotishot.log" &</action>
		</button>
		<button>
		  <label>Stop!</label>
		  <input file stock="gtk-stop"></input>
		  <action>sudo stop myspotishot</action>
		  <action type="refresh">STATUS</action>
		</button>
	</hbox>
	</frame>

  <hbox space-expand="false" space-fill="false">
  	<button width-request="85">
  		<input file stock="gtk-undo"></input>
  		<label>Restore Defaults</label>
  		<action>echo "SSID=\"ssid\"\nPASS=\"password\"\nETH=\"eth0\"\nWLAN=\"wlan0\"\nDHCP=\"192.168.150.2,192.168.150.10\"\nHWMODE1=\"false\"\nHWMODE2=\"true\"\nHWMODE3=\"false\"\n" > .myspotrc</action>
  		<variable>RESTORE</variable>
      <action type="refresh">SSID</action>
      <action>refresh:PASS</action>
      <action>refresh:ETH</action>
      <action>refresh:WLAN</action>
      <action>refresh:DHCP</action>
  	</button>
  	<hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
  	    <button>
            <label>Apply</label>
            <input file stock="gtk-apply"></input>
            <action>'$EXECFUNC' f_init</action>
        </button>
 		<button ok><input file stock="gtk-ok"></input></button>
        <button cancel></button>
	</hbox>
	
	<timer milliseconds="true" interval="5000" visible="false">
		<action type="refresh">STATUS</action>
	</timer>	
	<statusbar has-resize-grip="false" auto-refresh="true">
		<variable>STATUS</variable>
		<input>sudo status myspotishot</input>
	</statusbar>
	
	<variable>main</variable>
	
</vbox>
</window>'

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog --center --program main); do
  eval $STATEMENTS
done
IFS=$I

if [ ! "$EXIT" = "OK" ]; then
  exit 0
else
    f_config
fi
