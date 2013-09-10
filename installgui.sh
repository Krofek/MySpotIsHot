#!/bin/bash

potpol=/usr/share/polkit-1/actions/org.freedesktop.pkexec.myspotishot.policy

f_createpolicy() {
sudo rm $potpol
sudo touch $potpol
echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>

  <action id="org.freedesktop.pkexec.myspotishot">
    <message gettext-domain="gparted">Authentication is required to run MySpotIsHot</message>
    <defaults>
      <allow_any>auth_admin</allow_any>
      <allow_inactive>auth_admin</allow_inactive>
      <allow_active>auth_admin</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/usr/bin/myspotishot</annotate>
    <annotate key="org.freedesktop.policykit.exec.allow_gui">true</annotate>
  </action>

</policyconfig>' | sudo tee -a $potpol &>/dev/null
}

f_installer() {
echo "Welcome to the MySpotIsHot installer. Press Y to continue or N to abort!"
read -n 1 installer

if [[ $installer = "Y" || $installer = "y" ]]; then
	sudo apt-get update
	sudo apt-get install -y subversion autoconf libgtk2.0-dev bison flex dnsmasq hostapd iw
	
	if ! type gtkdialog >/dev/null 2>&1; then
		svn checkout http://gtkdialog.googlecode.com/svn/trunk/ gtkdialog
		cd gtkdialog
		./autogen.sh
		make
		sudo make install
		cd ..
		rm -rf gtkdialog/
	else
		echo "Gtkdialog already installed, continuing setup!"
	fi
	
	wget https://raw.github.com/Krofek/MySpotIsHot/master/MySpotIsHotGUI.sh && chmod +x MySpotIsHotGUI.sh
	wget https://raw.github.com/Krofek/MySpotIsHot/master/myspoticon.jpg
	sudo cp MySpotIsHotGUI.sh /usr/bin/myspotishot
	cp myspoticon.jpg $HOME/.myspot/myspoticon.jpg
	sudo rm -rf $HOME/.local/share/applications/myspotishot.desktop
	mkdir $HOME/.local/share/applications
	echo -e -n "[Desktop Entry]\nComment=Setup and create a WiFi AP\nTerminal=false\nName=MySpotIsHot\nExec=pkexec myspotishot\nType=Application\nIcon="$HOME"/.myspot/myspoticon.jpg\nCategories=Internet;" > $HOME/.local/share/applications/myspotishot.desktop
	f_createpolicy
    rm MySpotIsHotGUI.sh
    rm myspoticon.jpg
    echo "Installation finished! Usage: from menu or by typing in terminal: pkexec myspotihot"
    echo ""
    echo "Happy WiFi-ing! ;)"
	break
elif [[ $installer = "N" || $installer = "n" ]]; then
	exit
	break
fi
}

while :
do
	f_installer
done
