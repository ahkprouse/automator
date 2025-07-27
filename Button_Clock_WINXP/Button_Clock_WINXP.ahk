#Persistent
;~  #NoTrayIcon
#SingleInstance, Force
/*  * * * * * * * * * * * * * * * * * * * * * * * * * * * *
Download    : http://file.autohotkey.net/goyyah/Tips-N-Tricks/TaskBar/Button_Clock_WINXP.ahk
Description :  A "Button Clock" in lieu of "Windows Start Button" This script hides the "Start Button" and adds a new Button and keeps updating the "Button Caption" with a Time String - periodically - effectively making it a clock.
Author      : A.N.Suresh Kumar aka "Goyyah"
Email       : arian.suresh@gmail.com
*/
Control, Hide, , Button1, ahk_class Shell_TrayWnd
OnExit, Exitt  ; and restore the Start Button

cTime := A_Now
FormatTime,Time,,H:mm:ss

Gui, +ToolWindow -Caption
Gui, +Lastfound
GUI_ID := WinExist()
WinGet, TaskBar_ID, ID, ahk_class Shell_TrayWnd
DllCall("SetParent", "uint", GUI_ID, "uint", Taskbar_ID)

Gui, Margin,-28,1
Gui, Font, S13 bold , Arial Narrow ;change to make fit
Gui, Add,Button, w130 h20 gStartM vTime, % Time
;backup Gui, Add,Button, w113 h30 gStartM vTime, % Time
Gui, Show,x0 y0 AutoSize, Start Button Clock - By Goyyah

SetTimer, UpdateButtonTime, 10
Return
; ----------------------------------------------------------------------------------------
UpdateButtonTime:
  If cTime = %A_Now%
     exit
  else
     cTime := A_Now
  SetTimer, UpdateButtonTime, OFF
  ;FormatTime,Time,,h:mm  MMM-dd ;adusted to show 12 hour time
  FormatTime,Time,,h:mm M/d ;adusted to show 12 hour time
    ; backup FormatTime,Time,,h:mm  MMM-dd ;adusted to show 12 hour time
  GuiControl,,Time , %Time%
  SetTimer, UpdateButtonTime, 10
Return
StartM:
  Send ^{ESCAPE}
return
Exitt:
  Gui,Destroy
  Control, Show, ,Button1, ahk_class Shell_TrayWnd
  ExitApp
Return