#!/bin/bash
Encoding=UTF-8

f_default() {
    echo -e -n 'BROADCAST="false"\nUSECOUNTRY="false"\nAUTHED="false"\nAUTH="3600000"\nSSID="ssid"\nPASS="password"\nETH="eth0"\nWLAN="wlan0"\nDHCP="192.168.150.2,192.168.150.10"\nSTARTUP="false"\nSTARTUP0="true"\nSTARTUP1="false"\nSTARTUP2="false"\nVISIB="disabled"\nHWMODE1="false"\nHWMODE2="true"\nHWMODE3="false"\nCHANNEL="6"\nWPA="WPA+WPA2"\nservice=/etc/init/myspotishot.conf\ndnsmasq=/etc/dnsmasq.conf\nhostapd=/etc/hostapd.conf\nstartsc=/usr/sbin/myspotishot.sh' > ~/.myspot/.myspotrc
}
export -f f_default

###############STARTUP########################

mkdir -p $HOME/.myspot/
[ ! -s $HOME/.myspot/.myspotrc ] && f_default
. $HOME/.myspot/.myspotrc

URL="https://github.com/Krofek"
VERSION=v1.0
EXECFUNC="exec $SHELL -c"
SHOWDEV="iw dev wlan0 station dump | grep Station"

CHANNELS="<item>$CHANNEL</item>"
for I in 1 2 3 4 5 6 7 8 9 10 11 12; do CHANNELS=`echo "$CHANNELS<item>$I</item>"`; done

ETHI=`ifconfig -a | grep eth |sed "s/[ \t].*//;/^\(lo\|\)$/d"`
f_ethi="<item>$ETH</item>"
for eths in $ETHI; do f_ethi=`echo "$f_ethi<item>$eths</item>"`; done

WLANI=`iwconfig 2>&1 | grep wlan | sed "s/[ \t].*//;/^\(lo\|\)$/d"`
f_wlani="<item>$WLAN</item>"
for wlans in $WLANI; do f_wlani=`echo "$f_wlani<item>$wlans</item>"`; done

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
COUNTRIES=`cat "$HOME/.myspot/country-list-iso-codes.txt"`
f_countries="<item>$COUNTRY</item>"
for countries in $COUNTRIES; do f_countries=`echo "$f_countries<item>$countries</item>"`; done
IFS=$SAVEIFS


export service dnsmasq hostapd start EXECFUNC SHOWDEV

temp=$HOME/.myspot/temp
rm -rf "$temp"/
mkdir -p "$temp"/
touch "$temp"/ssid "$temp"/pass "$temp"/eth "$temp"/wlan "$temp"/dhcp "$temp"/visib "$temp"/hwmode "$temp"/statusbar "$temp"/startup "$temp"/service "$temp"/dnsmasq "$temp"/hostapd "$temp"/startsc

[ ! -f "${dnsmasq}.bak" ] && cp "$dnsmasq" "${dnsmasq}.bak"

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
    cp "${dnsmasq}.bak" "$dnsmasq"
}

f_startsc() {
    rm -rf $startsc
    touch $startsc
    echo -e -n "#!/bin/bash\nrfkill unblock wifi\nifconfig "$WLAN" 192.168.150.1\nservice dnsmasq restart\nsysctl net.ipv4.ip_forward=1\niptables -t nat -A POSTROUTING -o "$ETH" -j MASQUERADE\nhostapd "$hostapd"\niptables -D POSTROUTING -t nat -o "$ETH" -j MASQUERADE\nsysctl net.ipv4.ip_forward=0\nservice dnsmasq stop\nservice hostapd stop" | tee -a $startsc &>/dev/null
    chmod u+x $startsc
}

f_showdns() {
    egrep -xq "^interface=.*|^dhcp-range=.*" $dnsmasq
}

f_dnsmasq() {
    if f_showdns; then
        sed -i "s/^interface=.*/interface=$WLAN/" $dnsmasq
        sed -i "s/^dhcp-range=.*/dhcp-range=$DHCP/" $dnsmasq
    else
        echo -e -n "bind-interfaces\ninterface=$WLAN\ndhcp-range=$DHCP" | tee -a $dnsmasq
    fi
}

f_hwmode() {
    if [[ $HWMODE1 = "true" ]]; then
        echo "hw_mode=b" | tee -a $hostapd
    elif [[ $HWMODE2 = "true" ]]; then
        echo "hw_mode=g" | tee -a $hostapd
    elif [[ $HWMODE3 = "true" ]]; then
        echo "hw_mode=g" | tee -a $hostapd
    fi
}

f_wpa() {
    if [[ $WPA = "WPA+WPA2" ]]; then echo "wpa=3" | tee -a $hostapd
    elif [[ $WPA = "WPA2" ]]; then echo "wpa=2" | tee -a $hostapd
    elif [[ $WPA = "WPA" ]]; then echo "wpa=1" | tee -a $hostapd; fi
}

f_auth() {
    if [[ $AUTHED = "true" ]]; then echo "eap_reauth_period=$AUTH" | tee -a $hostapd; fi
}

f_country() {
    if [[ $USECOUNTRY = "true" ]];then
        COCODE=`echo $COUNTRY | cut -c 1-2`
        echo "country_code=$COCODE" | tee -a $hostapd
    fi
}

f_broadcast() {
    if [[ $BROADCAST = "true" ]]; then echo "ignore_broadcast_ssid=2" | tee -a $hostapd; fi
}

f_hostapd() {
    rm -rf $hostapd
    touch $hostapd
    echo -e -n "interface=$WLAN\ndriver=nl80211\n" | tee -a $hostapd
    f_hwmode
    if  [[ $HWMODE3 = "true" ]]; then
        echo -e -n "ieee80211n=1\nwmm_enabled=1" | tee -a $hostapd
    fi
    echo -e -n "\nchannel=$CHANNEL\nssid=$SSID\n" | tee -a $hostapd
    f_wpa
    echo -e -n "wpa_passphrase=$PASS\nwpa_key_mgmt=WPA-PSK\nwpa_pairwise=TKIP\nrsn_pairwise=CCMP\nmacaddr_acl=0\n" | tee -a $hostapd
    if  [[ $HWMODE3 = "true" ]]; then
        echo "ht_capab=[HT20][SHORT-GI-20]]" | tee -a $hostapd
    fi
    f_auth
    f_country
    f_broadcast
}

f_restore() {
    echo "ssid" > "$temp"/ssid
    echo "password" > "$temp"/pass
    echo "eth0" > "$temp"/eth
    echo "wlan0" > "$temp"/wlan
    echo "192.168.150.2,192.168.150.10" > "$temp"/dhcp
    echo "false" > "$temp"/startup
    echo "disabled" > "$temp"/visib
    echo "true" > "$temp"/hwmode
}
f_restoreco() {
    echo "/etc/init/myspotishot.conf" > "$temp"/service
    echo "/etc/dnsmasq.conf" > "$temp"/dnsmasq
    echo "/etc/hostapd.conf" > "$temp"/hostapd
    echo "/usr/sbin/myspotishot.sh" > "$temp"/startsc
}
export -f f_restore f_restoredns f_restoreco f_auth f_country f_broadcast

export -f f_hwmode f_hostapd f_showdns f_dnsmasq f_wpa f_startsc

#write config
f_config() {
    echo -e -n "BROADCAST=\"$BROADCAST\"\nUSECOUNTRY=\"$USECOUNTRY\"\nCOUNTRY=\"$COUNTRY\"\nAUTH=\"$AUTH\"\nAUTHED=\"$AUTHED\"\nSSID=\"$SSID\"\nPASS=\"$PASS\"\nETH=\"$ETH\"\nWLAN=\"$WLAN\"\nDHCP=\"$DHCP\"\nVISIB=\"$VISIB\"\nSTARTUP=\"$STARTUP\"\nSTARTUP0=\"$STARTUP0\"\nSTARTUP1=\"$STARTUP1\"\nSTARTUP2=\"$STARTUP2\"\nHWMODE1=\"$HWMODE1\"\nHWMODE2=\"$HWMODE2\"\nHWMODE3=\"$HWMODE3\"\nCHANNEL=\"$CHANNEL\"\nWPA=\"$WPA\"\nservice="$service"\ndnsmasq="$dnsmasq"\nhostapd="$hostapd"\nstartsc="$startsc"" > ~/.myspot/.myspotrc
}

#write upstart script

f_init() {
    rm -rf $service
    touch $service
    echo -e -n 'description "MySpotIsHot service!"\nauthor "Matej Vrabec"\n\n' | tee -a $service &>/dev/null

    if [[ $STARTUP = "true" && $STARTUP1 = "true" ]]; then
        echo ""
        echo -e -n "start on local-filesystems\nrespawn\n" | tee -a $service &>/dev/null

    elif [[ $STARTUP = "true" && $STARTUP2 = "true" ]]; then
        echo ""
        echo -e -n "start on net-device-up IFACE=$ETH\nrespawn\n" | tee -a $service &>/dev/null
    fi

    echo ""
    echo -e -n 'stop on runlevel [!12345]\n\npre-start script\n	echo "Starting MySpotIsHot"\nend script\n\npost-stop script\n	echo "Stopping MySpotIsHot"\nend script\n\nexec sh '$startsc'' | tee -a $service &>/dev/null
}
export -f f_init f_config

f_checkap() {
    if [[ $(iw list | grep modes: -A 10) =~ "AP" ]]; then
        echo '<text><label>Choose wlan adapter</label></text>
         <combobox width-request="100">
         <variable>WLAN</variable>
         '$f_wlani'
         </combobox>'
    else
       echo '<text><label>AP mode not available!</label></text>'
    fi
}
export -f f_checkap

f_prereq() {
    if ! type hostapd >/dev/null 2>&1 || ! type hostapd >/dev/null 2>&1 || ! type iw >/dev/null 2>&1; then
        apt-get update && echo "APT updated!" && sleep 1
        if ! type iw >/dev/null 2>&1; then
            sudo apt-get install -y iw >/dev/null 2>&1
            echo "iw installed"
            sleep 1
        fi
        if ! type dnsmasq >/dev/null 2>&1; then
            sudo apt-get install -y dnsmasq >/dev/null 2>&1
            echo "dnsmasq installed"
            sleep 1
        fi
        if ! type hostapd >/dev/null 2>&1; then
            sudo apt-get install -y hostapd >/dev/null 2>&1
            echo "hostapd installed"
            sleep 1
        fi
        echo "Done! Please close the window!"
    else
        echo "All in order, please close the window!"
        sleep 3
    fi
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
            <label>Checking for installed packages!</label>
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
                
                <notebook labels="Settings|Config files|Connected devices">
                    <vbox>
                        <vbox space-expand="true" space-fill="true"><text><label>""</label></text></vbox>
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
                            <combobox width-request="100">
                                <variable>ETH</variable>
                                '$f_ethi'
                            </combobox>
                            <button>
                                <input file stock="gtk-index"></input>
                                <action>ifconfig | grep eth | zenity --text-info  --width=700 --height=500 --title "Ethernet adapters" &</action>
                            </button>
                        </hbox>

                        <hbox>
                            <text><label>Choose wlan adapter</label></text>
                            <combobox width-request="100">
                                <variable>WLAN</variable>
                                '$f_wlani'
                            </combobox>
                            <button>
                                <input file stock="gtk-index"></input>
                                <action>iw list | grep modes: -A 10 | zenity --text-info  --width=700 --height=500 --title "Wlan adapters" &</action>
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
                            <text><label>Channel:</label></text>
                            <combobox width-request="65">
                                <variable>CHANNEL</variable>
                                '$CHANNELS'
                            </combobox>
                            <text><label>Encryption:</label></text>
                            <combobox width-request="140">
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
                                <input>echo '$HWMODE1'</input>
                            </radiobutton>
                            <radiobutton label="g">
                                <variable>HWMODE2</variable>
                                <input>echo '$HWMODE2'</input>
                                <input file>'$temp'/hwmode</input>
                            </radiobutton>
                            <radiobutton label="n">
                                <variable>HWMODE3</variable>
                                <input>echo '$HWMODE3'</input>
                            </radiobutton>
                        </hbox>

                        <hbox>
                            <text><label>Startup options</label></text>
                            <checkbox>
                                <label>""</label>
                                <variable>STARTUP</variable>
                                <input>echo '$STARTUP'</input>
                                <action>if true enable:STARTUP1</action>
                                <action>if true enable:STARTUP2</action>
                                <action>if false disable:STARTUP1</action>
                                <action>if false disable:STARTUP2</action>
                                <action>refresh:STARTUP1</action>
                                <action>refresh:STARTUP2</action>
                            </checkbox>
                            <radiobutton label="Filesystem">
                                <variable>STARTUP1</variable>
                                <input>echo '$STARTUP1'</input>
                                <sensitive>'$STARTUP'</sensitive>
                            </radiobutton>
                            <radiobutton label="Internet up">
                                <variable>STARTUP2</variable>
                                <input>echo '$STARTUP2'</input>
                                <sensitive>'$STARTUP'</sensitive>
                            </radiobutton>

                        </hbox>

                    </vbox>
                    <vbox>
 <hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>

                    <hbox>
                    <checkbox>
                            <input>echo '$AUTHED'</input>
                            <variable>AUTHED</variable>
                             <label>Remain auth [ms]</label>
                            <action>if true enable:AUTH</action>
                            <action>if false disable:AUTH</action>
                            <action>refresh:AUTH</action>
                            </checkbox>
                            <entry>
                                <variable>AUTH</variable>
                                <input>echo '$AUTH'</input>
                            <sensitive>'$AUTHED'</sensitive>
                            </entry>
                            </hbox>
                            <hbox>
                           <checkbox>
                           <input>echo '$USECOUNTRY'</input>
                           <label>Use country code</label>
                           <variable>USECOUNTRY</variable>
                            <action>if true enable:COUNTRY</action>
                            <action>if false disable:COUNTRY</action>
                            <action>refresh:COUNTRY</action>
                            </checkbox>
                            <combobox>
                                <variable>COUNTRY</variable>
                                '$f_countries'
                            <sensitive>'$USECOUNTRY'</sensitive>
                            </combobox>
                            </hbox>
                            <hbox>
                            <checkbox>
                            <label>Make AP invisible</label>
                            <variable>BROADCAST</variable>
                            <input>echo '$BROADCAST'</input>
                            </checkbox>
                            <hbox space-expand="true" space-fill="true"><text><label>""</label></text>
                            </hbox>
                            </hbox>

                        <hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
                        <hbox>
                            <text width-request="100"><label>Start script</label></text>
                            <entry width-request="200">
                                <variable>startsc</variable>
                                <input>echo '$startsc'</input>
                                <input file>'$temp'/startsc</input>
                            </entry>
                        </hbox>
                        <hbox>
                            <text width-request="100"><label>dnsmasq.conf</label></text>
                            <entry width-request="200">
                                <variable>dnsmasq</variable>
                                <default>'$dnsmasq'</default>
                                <input file>'$temp'/dnsmasq</input>
                            </entry>
                        </hbox>
                        <hbox>
                            <text width-request="100"><label>hostapd.conf</label></text>
                            <entry width-request="200">
                                <variable>hostapd</variable>
                                <default>'$hostapd'</default>
                                <input file>'$temp'/hostapd</input>
                            </entry>
                        </hbox>
                        <hbox>
                            <text width-request="100"><label>Upstart Job</label></text>
                            <entry width-request="200">
                                <variable>service</variable>
                                <default>'$service'</default>
                                <input file>'$temp'/service</input>
                            </entry>
                        </hbox>
                        <hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
                    </vbox>

                    <vbox>
                        <timer milliseconds="true" interval="200" visible="false">
                            <action type="refresh">CONNECTED</action>
                        </timer>
                        <text><label>""</label></text>
                        <text name="mono">
                            <variable>CONNECTED</variable>
                            <input>'$SHOWDEV'</input>
                        </text>
                    </vbox>

                </notebook>


                <frame Show configs>
                    <hbox homogeneous="true">
                        <button>
                            <label>hostapd.conf</label>
                            <action>cat '$hostapd' | zenity --text-info  --width=300 --height=500 --title "hostapd.conf" &</action>
                        </button>
                        <button>
                            <label>Upstart</label>
                            <action>cat '$service' | zenity --text-info  --width=400 --height=500 --title "myspotishot.conf" &</action>
                        </button>
                        <button>
                            <label>dnsmasq.conf</label>
                            <action>cat '$dnsmasq' | zenity --text-info  --width=600 --height=500 --title "dnsmasq.conf" &</action>
                        </button>
                    </hbox>
                </frame>

                <frame Manage service>
                    <hbox homogeneous="True">
                        <button>
                            <label>Start!</label>
                            <input file stock="gtk-yes"></input>
                            <action>start myspotishot > '$temp'/statusbar</action>
                            <action type="refresh">STATUS</action>
                        </button>
                        <button>
                            <label>Status</label>
                            <action>status myspotishot > '$temp'/statusbar</action>
                            <action type="refresh">STATUS</action>
                        </button>
                        <button>
                            <label>Stop!</label>
                            <input file stock="gtk-stop"></input>
                            <action>stop myspotishot > '$temp'/statusbar</action>
                            <action type="refresh">STATUS</action>
                        </button>
                    </hbox>
                </frame>

                <hbox space-expand="false" space-fill="false">
                    <button>
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
                        <action>'$EXECFUNC' f_restoreco</action>
                        <action>refresh:startsc</action>
                        <action>refresh:dnsmasq</action>
                        <action>refresh:hostapd</action>
                        <action>refresh:service</action>
                    </button>
                    <hbox space-expand="true" space-fill="true"><text><label>""</label></text></hbox>
                    <button>
                        <label>Apply</label>
                        <input file stock="gtk-apply"></input>
                        <action>'$EXECFUNC' f_init</action>
                        <action>'$EXECFUNC' f_hostapd</action>
                        <action>'$EXECFUNC' f_dnsmasq</action>
                        <action>'$EXECFUNC' f_startsc</action>
                        <action>echo "Settings applied, check configs to be sure!" > '$temp'/statusbar</action>
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
                        <input>if [ -f /var/log/upstart/myspotishot.log ];then tail /var/log/upstart/myspotishot.log; fi</input>
                    </text>
                </frame>

                <hbox>
                    <button>
                        <label>Restore dnsmasq!</label>
                        <action>'$EXECFUNC' f_restoredns</action>
                        <action>echo "dnsmasq.conf successfully restored" > '$temp'/statusbar</action>
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
            <input file>'$temp'/statusbar</input>
        </statusbar>

    </vbox>
    <variable>main</variable>
</window>'

########################################################
###########################ENDING#######################
########################################################

I=$IFS; IFS=""
for STATEMENTS in  $(gtkdialog --center --program main); do
    eval $STATEMENTS
done
IFS=$I


if [ ! "$EXIT" = "OK" ]; then
    rm -rf '$temp'/
    exit 0
else
    rm -rf '$temp'/
    f_config
fi

