#Requires Autohotkey v2.0+
;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

LaunchEditor(hwnd, scriptLine)
{
	static WM_COMMAND:=0x111
	static EDITSCRIPT:=65401
	SendMessage WM_COMMAND, EDITSCRIPT, 0,, hwnd
	if !WinWaitActive(A_ScriptName,,3)
		return MsgBox("Could not open the script file", "Error", 'IconX')

	/*
	The sleep below is important because
	some editors perform some actions on starup.

	AHKStudio for example remembers your last caret position.
	We have to wait until it sends the caret pos message
	before we do our own because if not the caret will be reset
	and one would think that the message failed.
	*/
	sleep 1000

	if WinActive("Notepad++")
		SendMessage 2024, scriptLine-1,, 'Scintilla1', 'Notepad++'
	else if WinActive("AHK Studio")
		SendMessage 2024, scriptLine-1,, 'Scintilla2', 'AHK Studio'
	else if WinActive("Notepad")
		SendMessage 0x00B6, 0, scriptLine-1, 'Edit1', 'Notepad'
	else
		Send '^g' scriptLine '{enter}'
	
	/* 
	Sending the select command below in notepad 
	would scroll back up giving the impression that
	the sendmessage above was not successful
	*/
	if !WinActive("Notepad")
		Send '+{End}'
}