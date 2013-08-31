#!/bin/bash

f_installer() {
echo "Welcome to the MySpotIsHot installer. Press Y to continue or N to abort!"
read -n 1 installer

if [[ $installer = "Y" || $installer = "y" ]]; then
	sudo apt-get update
	sudo apt-get install -y subversion autoconf libgtk2.0-dev bison dnsmasq hostapd iw
	
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
	
	curl https://raw.github.com/Krofek/MySpotIsHot/master/MySpotIsHotGUI.sh -L > MySpotIsHotGUI.sh && chmod +x MySpotIsHotGUI.sh
	wget https://raw.github.com/Krofek/MySpotIsHot/master/myspoticon.jpg
	sudo cp MySpotIsHotGUI.sh /usr/bin/myspotishot
	cp myspoticon.jpg $HOME/.myspot/myspoticon.jpg
	sudo rm -rf $HOME/.local/share/applications/myspotishot.desktop
	echo -e -n "[Desktop Entry]\nComment=Setup and create a WiFi AP\nTerminal=false\nName=MySpotIsHot\nExec=gksu myspotishot\nType=Application\nIcon=/home/krofek/.myspot/myspoticon.jpg\nCategories=Internet;" > $HOME/.local/share/applications/myspotishot.desktop
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

