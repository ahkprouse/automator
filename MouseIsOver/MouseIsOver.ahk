;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses.  
; They make learning AHK EASY:  https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
#If MouseIsOver("ahk_class Shell_TrayWnd") or MouseIsOver("ahk_class Shell_SecondaryTrayWnd")
XButton1::MsgBox button 1: Mouse is over Taskbar

#If MouseIsOver("ahk_class AutoHotkeyGUI") 
XButton1::MsgBox button 1: Mouse is over Studio

#If MouseIsOver("ahk_exe Notepad.exe") 
XButton1::MsgBox button 1: Mouse is over Notepad

#If	;turn off context sensitivity
XButton1::MsgBox button 1: Mouse is not over any of these

;https://www.autohotkey.com/docs/commands/_If.htm#ExVolume
MouseIsOver(WinTitle){
	MouseGetPos,,, Win
	return WinExist(WinTitle " ahk_id " Win)
}
