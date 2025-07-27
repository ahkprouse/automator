;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************

;~ https://autohotkey.com/boards/viewtopic.php?f=6&t=62&p=26346&hilit=run+selected#p26346
; SelectRun.ahk - Plugin for SciTE4AHK by joedf
;##########################################################
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetBatchLines,-1
#SingleInstance, Off
#NoTrayIcon
;##########################################################

oSciTE := ComObjActive("SciTE4AHK.Application")

platform:=oSciTE.ActivePlatform
ahk:=A_ahkpath
SplitPath,A_ahkpath,,ahk_dir
if ahk_dir is not Space
{
	If (platform="ANSI")
		ahk:=ahk_dir "\AutoHotkeyA32.exe"
	else If (platform="Unicode")
		ahk:=ahk_dir "\AutoHotkeyU32.exe"
	else If (platform="x64")
		ahk:=ahk_dir "\AutoHotkeyU64.exe"
	else ;If (platform="Default")
		ahk:=A_ahkpath
}
file := oSciTE.CurrentFile
SplitPath,file,,dir
SetWorkingDir, "%dir%"

file:=get_TempFile()
FileAppend, % oSciTE.Selection , %file%
if ErrorLevel
{
	MsgBox, 16, %A_ScriptName% - ERROR, Could not write file!
	ExitApp
}

oSciTE.Output("`nRunning Selected : " "" ahk "" " " "" file "")
QPC( True )        ; Reset counter
RunWait, "%ahk%" "%file%", %dir%, UseErrorLevel
RunTime:=QPC( False )
oSciTE.Output("`nExit code: " ErrorLevel " `t Time: " RunTime " seconds`n")
FileDelete,%file%
ExitApp

QPC( R := 0 ) {    ; By SKAN,  http://goo.gl/nf7O4G,  CD:01/Sep/2014 | MD:01/Sep/2014
  Static P := 0,  F := 0,     Q := DllCall( "QueryPerformanceFrequency", "Int64P",F )
Return ! DllCall( "QueryPerformanceCounter","Int64P",Q ) + ( R ? (P:=Q)/F : (Q-P)/F )
}
get_TempFile(d:="") {
	if ( !StrLen(d) || !FileExist(d) )
		d:=A_Temp
	Loop
		tempName := d "\~temp" A_TickCount ".tmp"
	until !FileExist(tempName)
	return tempName
}