MySpotIsHot
===========

WiFi hotspot setup script for Ubuntu 12.10+

Start the script::
	
	$ ./Myspotishot.sh

If for some chance it is not executable::

	$ chmod u+x Myspotishot.sh

The script will guide you through the setup.

After finishing with the setup you should have an Upstart job available.
You can start the hotspot the following way:
	
	$ sudo start myspotishot

or

	$ sudo sh /usr/sbin/myspotishot.sh

Stop the hotspot:

	$ sudo stop myspotishot

Check the status:

	$ sudo status myspotishot

TO-DO:
______

* adding the option to make the service run at system startup
* check for available wlan adapters and choose one
* check for ethernet adapter connecting to the internet
* tbd

MySpotIsHotGUI beta...
==========================
Ubuntu 13.04

For ubuntu users, haven't tried for other gnome users, to do everything automatically CTRL-ALT-T to open terminal and paste this in::

	curl https://raw.github.com/Krofek/MySpotIsHot/master/installgui.sh -L > installgui.sh && chmod +x installgui.sh && ./installgui.sh

Otherwise do everything manually:
Runs with gtkdialog::

	sudo apt-get install subversion autoconf libgtk2.0-dev bison

Need to install gtkdialog manually:

	svn checkout http://gtkdialog.googlecode.com/svn/trunk/ gtkdialog
	cd gtkdialog
	./autogen.sh
	make
	sudo make install
	
Hostapd and dnsmasq can be installed through the GUI


![alt tag](https://raw.github.com/Krofek/MySpotIsHot/master/myspotishotgui.png)

TO-DO:
______

* nicer and better button positions
* grey out wlan adapter combobox if wlan adapter doesnt support AP mode (also popup window shows with text saying it)
* check if packages are installed, if they are not, popup window saying Please install...
* popup windows instead of using zenity for showing configs and other stuff...
* if you have any suggestions about anything
* Advenced option: remain authenticated, locales, ht capabilities (HT20, HT40, etc), make invisible, more
* ban mac adress
* show connected devices
