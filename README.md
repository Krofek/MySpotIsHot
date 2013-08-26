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
