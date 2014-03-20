@ECHO OFF
cls
ECHO You're running MySpotIsHot v1.1beta
timeout /t 1 > NUL
cls
echo.
ECHO Current status:
netsh wlan show hostednetwork | findstr /r "^....SSID"
netsh wlan show hostednetwork | findstr /r "^....Status"
echo.
PAUSE

echo.
GOTO Menu

	:Menu
	echo.
	ECHO Press the desired number:
	ECHO 1.) Start hotspot with current setting
	ECHO 2.) Setup hotspot
	ECHO 3.) Stop the hotspot
	ECHO 4.) Show the hostednetwork settings and stuff...
	ECHO 5.) Create or delete StartUp entry for the AP
	ECHO Q.) Cloooooooseeeeee meeeeeeaaaaaaaah!!!

	CHOICE /C:12345q /N
	IF Errorlevel 6 Exit
	IF Errorlevel 5 GOTO 5
	IF Errorlevel 4 GOTO 4
	IF Errorlevel 3 GOTO 3
	IF Errorlevel 2 GOTO 2
	IF Errorlevel 1 GOTO 1
	
	Goto End
	
	:1
	cls
	ECHO Starting hotspot with last settings
	netsh wlan start hostednetwork
	::ECHO That's it press the ANY key if you can find it and the window will close...maybe :P
	::PAUSE >nul
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu
	
	:2
	cls
	ECHO Setup yer hotspot man:
	echo.
	SET /P SSIDVAR=Ze hotspot name yooooo yaaaaaa!^


	echo.
	SET /P PASSVAR=Tell me yer password mate!^


	netsh wlan set hostednetwork mode=allow ssid=%SSIDVAR% key=%PASSVAR% >nul
	netsh wlan start hostednetwork >nul

	echo.
	PAUSE
	echo.
	ECHO Ze parameters ye chose yo-man:
	echo.
	ECHO Name=%SSIDVAR%
	ECHO Password=%PASSVAR%
	echo.
	PAUSE
	echo.
	ECHO Now some seriousness...so to speak muhehehe...after pressing the ANY key...
	ECHO find it yourself you lazy piece of...Network Connections setup window will open.
	ECHO Just right click on the adapter that connects to the internet, select Properties.
	ECHO Go to the sharing tab, tick "Allow other users to connect..."
	ECHO Select the newly created Wireless Connection.
	PAUSE >nul
	CALL C:\windows\system32\ncpa.cpl
	echo.
	ECHO Press the damn ANY key again!
	PAUSE >nul
	ECHO Waaaaaaaa...it should be working now...woooooohoooooooooo!
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu
		
	:3
	cls
	ECHO You chose to stop your hotspot...bastard!
	netsh wlan stop hostednetwork
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu
	
	:4
	cls
	ECHO There was a wise man once...well he's no more!
	netsh wlan show hostednetwork
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu
	
	:5
	cls
	echo.
	echo Choose your destiny...or whatever.
	ECHO 1.) Create StartUp entry.
	ECHO 2.) Remove StartUp entry.
	ECHO r.) Return to main menu.
	echo q.) Quit
	CHOICE /C:12rq /N 
	IF Errorlevel 4 Exit
	IF Errorlevel 3 cls & GOTO Menu
	IF Errorlevel 2 GOTO 7
	IF Errorlevel 1 GOTO 6
	
	:6
	cls
	echo @echo off >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\myspot.bat"
	echo netsh wlan start hostednetwork >> "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\myspot.bat"
	ECHO Your AP should be running on windows startup now :).
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu	

	:7
	cls
	del "%UserProfile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\myspot.bat"
	ECHO Startup entry for the current user is now gone in the wind.
	echo.
	ECHO Press R to return to menu or Q to Exit the program
	CHOICE /C:rq /N 
	IF Errorlevel 2 Exit
	IF Errorlevel 1 cls & GOTO Menu	
