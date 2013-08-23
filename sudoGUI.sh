#!/bin/sh

export SU_CMD=./MySpotIsHotGUI.sh

export SU_DIALOG='
<window>
  <vbox>
    <text wrap="true" width-chars="48">
      <label>"
Please enter root password to continue :"
      </label>
    </text>
    
    <hbox>
      <text use-markup="true">
        <label>"<b>Root password :</b>"</label>
      </text>
      <entry visibility="false">
        <default>root</default>
        <variable>PASSWD</variable>
      </entry>
    </hbox>

    <hbox>
      <button ok>
				<action>echo $PASSWD | sudo -S -b "$SU_CMD" >&2</action>
<action type="closewindow">SU_DIALOG</action>
      </button>
      <button cancel></button>
    </hbox>
		<variable>SU_DIALOG</variable>
  </vbox>
</window>
'

gtkdialog --center --program=SU_DIALOG > /dev/null

exit 0
