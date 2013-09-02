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

Runs with gtkdialog!

Automagical install:
--------------------

For ubuntu users, haven't tried for other gnome users, to do everything automatically CTRL-ALT-T to open terminal and paste this in::

	curl https://raw.github.com/Krofek/MySpotIsHot/master/installgui.sh -L > installgui.sh && chmod +x installgui.sh && ./installgui.sh

This will download the application, create a menu item, make a policy for launching with pkexec. After the setup finishes,
you should be able to launch the application via the menu (MySpotIsHot - inculdes an ugly icon) or by typing in the console::

	pkexec myspotishot

This should be it.


Manual install:
---------------

Install required packages for compiling and installing gtkdialog::

	sudo apt-get install subversion autoconf libgtk2.0-dev bison hostapd dnsmasq

Need to install gtkdialog manually:

	svn checkout http://gtkdialog.googlecode.com/svn/trunk/ gtkdialog
	cd gtkdialog
	./autogen.sh
	make
	sudo make install
	
This way you should launch the GUI as root, since all sudo commands are removed from the script!!

Screenshot:

![alt tag](https://raw.github.com/Krofek/MySpotIsHot/master/myspotishotgui.png)

TO-DO:
______

* nicer and better button positions
* grey out wlan adapter combobox if wlan adapter doesnt support AP mode (also popup window shows with text saying it)
* if you have any suggestions about anything
* Advenced option: remain authenticated, locales, ht capabilities (HT20, HT40, etc), make invisible, more
* ban mac adress
