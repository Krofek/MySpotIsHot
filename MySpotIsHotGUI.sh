#! /bin/bash
Encoding=UTF-8


export MAIN_DIALOG='
<window window_position="1" title="MySpotIsHot">

<vbox>
	<frame>
	<hbox homogeneous="True">
  	<text use-markup="true"><label>"<span weight='"'bold'"' size='"'large'"'>MySpotIsHot v0.1alpha</span>"</label></text>
	</hbox>
	</frame>

	<frame>
	<hbox>
	<vbox>

		<hbox>
		<text><label>SSID name</label></text>
		<entry>
		  <default>ssidname</default>
		  <variable>SSID</variable>
		</entry>
		</hbox>

		<hbox>
		<text><label>Password</label></text>
		<entry>
		  <default>password</default>
		  <variable>PASS</variable>
		</entry>
		</hbox>

		<hbox>
		<text><label>Choose ethernet adapter</label></text>
		<entry>
		  <default>eth0</default>
		  <variable>ETH</variable>
		</entry>
		<button>
		  <input file stock="gtk-new"></input>
		  <action>ifconfig | grep -i ethernet | zenity --text-info  --width=700 --height=500 --title $"View ethernet adapters" &</action>
		</button>
		</hbox>

		<hbox>
		<text><label>Choose wlan adapter</label></text>
		<entry>
		  <default>wlan0</default>
		  <variable>WLAN</variable>
		</entry>
		<button>
		  <input file stock="gtk-new"></input>
          	  <action>iwconfig 2>&1 | grep wlan | zenity --text-info  --width=700 --height=500 --title $"View wlan adapters" &</action>
		</button>
		</hbox>

		<hbox>
		<text><label>DHCP range</label></text>
		<entry>
		  <default>192.168.150.2,192.168.150.10</default>
		  <variable>WLAN</variable>
		</entry>
		</hbox>
	<hbox homogeneous="true">
	<button>
          <label>Show hostapd.conf</label>
          <action>cat /etc/hostapd.conf | zenity --text-info  --width=700 --height=500 --title $"hostapd.conf" &</action>
        </button>
	<button>
          <label>Show dnsmasq.conf</label>
          <action>cat /etc/dnsmasq.conf | zenity --text-info  --width=700 --height=500 --title $"hostapd.conf" &</action>
        </button>
	</hbox>

	<frame>
	<hbox homogeneous="True">
		<button>
		  <label>START</label>
		  <input file stock="gtk-yes"></input>
		  <action>sudo start myspotishot > status &</action>
		  <action function="refresh">STATUS</action>
		</button>
		<button>
		  <label>STATUS</label>
		  <action>status myspotishot > status &</action>
		  <action function="refresh">STATUS</action>
		</button>
		<button>
		  <label>STOP</label>
		  <input file stock="gtk-stop"></input>
		  <action>sudo stop myspotishot > status &</action>
		  <action function="refresh">STATUS</action>
		</button>
	</hbox>
	</frame>

	</vbox>
	</hbox>
	</frame>
	<statusbar has-resize-grip="false" auto-refresh="true">
	<variable>STATUS</variable>
	<input file>status</input>
      </statusbar> 
</vbox>

</window>
'

gtkdialog --program=MAIN_DIALOG
