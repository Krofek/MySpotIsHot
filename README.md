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

MySpotIsHotGUI prealpha...
==========================

work in progress...pic or it didn't happen? :D

![alt tag](https://raw.github.com/Krofek/MySpotIsHot/master/MySpotIsHotGUI.png)
