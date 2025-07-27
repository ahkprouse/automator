#Requires Autohotkey v1.1.36+
;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They"re structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

LaunchEditor(winTitle, scriptLine)
{
	static WM_COMMAND:=0x111
	static EDITSCRIPT:=65401
	clipboard := winTitle
	SendMessage, WM_COMMAND, EDITSCRIPT, 0,, % winTitle,,,, 1
	
	WinWaitActive, %A_ScriptName%,, 3
	if ErrorLevel
	{
		MsgBox 0x10, % "Error", % "Could not open the script file"
		return 
	}

	/*
	The sleep below is important because
	some editors perform some actions on starup.

	AHKStudio for example remembers your last caret position.
	We have to wait until it sends the caret pos message
	before we do our own because if not the caret will be reset
	and one would think that the message failed.
	*/
	sleep 2000

	if WinActive("Notepad++")
		SendMessage 2024, scriptLine-1,, % "Scintilla1", % "Notepad++"
	else if WinActive("AHK Studio")
		SendMessage 2024, scriptLine-1,, % "Scintilla2", % "AHK Studio"
	else if WinActive("Notepad")
		SendMessage 0x00B6, 0, scriptLine-1, % "Edit1", % "Notepad"
	else
		SendInput % "^g" scriptLine "{enter}"
	
	/* 
	Sending the select command below in notepad 
	would scroll back up giving the impression that
	the sendmessage above was not successful
	*/
	if !WinActive("Notepad")
		SendInput % "+{End}"
}