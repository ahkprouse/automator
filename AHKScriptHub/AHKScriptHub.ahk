;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

;********************TO DO ***********************************
;~ 1) fix RegEx to use AutoHotkey variables in a Traymenu icon path 
   ;  for insance  Menu, Tray, Icon, %A_WinDir%\system32\shell32.dll,74 ;Set custom Script icon
;~ 2) Don't list Quick Access Popup 
; QuickAccessPopup-64-bit.exe	 or  QuickAccessPopup-32-bit.exe	


#NoEnv
#Persistent
#SingleInstance
#Requires Autohotkey v1.1.36+
;--
;@Ahk2Exe-SetVersion     0.5.7
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
/**
 * ============================================================================ *
 * @Author   :                                                                  *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : May 13, 2023                                                  *
 * @Modified : May 13, 2023                                                  *
 * ============================================================================ *
 * License:                                                                     *
 * Copyright ©2023 <GPLv3>                                                      *
 *                                                                              *
 * This program is free software: you can redistribute it and/or modify         *
 * it under the terms of the **GNU General Public License** as published by     *
 * the Free Software Foundation, either version 3 of the License, or            *
 * (at your option) any later version.                                          *
 *                                                                              *
 * This program is distributed in the hope that it will be useful,              *
 * but **WITHOUT ANY WARRANTY**; without even the implied warranty of           *
 * **MERCHANTABILITY** or **FITNESS FOR A PARTICULAR PURPOSE**.  See the        *
 * **GNU General Public License** for more details.                             *
 *                                                                              *
 * You should have received a copy of the **GNU General Public License**        *
 * along with this program. If not, see:                                        *
 * <http://www.gnu.org/licenses/gpl-3.0.txt>                                    *
 * ============================================================================ *
 */
;Tweaks made by the-Automator on 4/29/2021

#Include <ScriptObject\ScriptObject>

global script := {base         : script
                 ,name         : regexreplace(A_ScriptName, "\.\w+")
                 ,version      : "0.5.7"
                 ,author       : "Joe Glines"
                 ,email        : "joe@the-automator.com"
                 ,homepagetext : "https://autohotkey.com/board/"
                 ,homepagelink : "http://www.autohotkey.com/forum/viewtopic.php?p=234276#234276"
                 ,donateLink   : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
                 ,resfolder    : A_ScriptDir "\res"
                 ,iconfile     : A_ScriptDir "\res\sct.ico"
                 ,configfile   : A_ScriptDir "\settings.ini"
                 ,configfolder : A_ScriptDir ""}

Menu, Tray, Icon, shell32.dll, 317 ;If this causes an error, comment it out.
CoordMode, ToolTip, Screen

CreateMenu()
ReloadTime := 15 ; in seconds
SetTimer, CreateMenu, % ReloadTime * 1000
Return

CreateMenu()
{
	global menuHandles
	
	; Menu, Tray, Click, 1                                                    ; single click to reload
	Menu, Tray, DeleteAll                                                   ; Clear menu for updating when exiting scripts
	Menu, Tray, NoStandard                                                  ; disable standard menu
	
	DetectHiddenWindows, On
	WinGet, AList, List, ahk_class AutoHotkey                               ; get list of all AutoHotkey scripts
	
	menuHandles := {}
	Loop %AList%
	{
		HWND := AList%A_Index%
		WinGetTitle, scriptTitle, % "ahk_id " HWND
		
		scriptPath := RegExReplace(scriptTitle, "\s-.*")
		SplitPath, scriptPath, scriptName, scriptDir
		
		if (!scriptName)
			Continue
		
		FileRead, readScript, % scriptPath
		
		; remove comments
		readScript := regexreplace(readScript, "(^\s*|\b\s+);.*$")
		; readScript := RegExReplace(readScript, "`amS)((?:^(?:\s+)?\/\*)(?:.|\s)*?(?:^(?:\s+)?\*\/)|(^(?:\s+)?)?(^|\s+);.*$)")
		;check if icon is hidden
		iconHidden := RegExMatch(readScript, "`amiOS)^\s?+#notrayicon\b|(?<=menu).*?\bnoicon\b")
		
		; get current icon
		hasIcon := RegExMatch(readScript, "`amiOS)Tray(\s+)?,(\s+)?Icon(\s+)?,(\s+)?(?<icon>.*(\d+)?)(\s;.*)?", match)
		scriptName := Format("{:U}", Trim(scriptName))
		menuHandles[scriptName] := {}
		menuHandles[scriptName].hwnd := HWND
		menuHandles[scriptName].path := Trim(scriptDir)
		menuHandles[scriptName].iconFile := (iconHidden && !hasIcon) ? A_AhkPath : Trim(StrSplit(match.icon,",", A_Space).1)
		menuHandles[scriptName].iconNumber := (iconHidden && !hasIcon) ? 2 : Trim(StrSplit(match.icon,",", A_Space).2)
	}
	
	for scriptName,scriptObj in menuHandles
	{
		if (scriptName = "AHKScriptHub.ahk")
			continue
		
		Menu,%scriptName%, Add, % "Open Script Folder", MenuChoice
		Menu,%scriptName%, Add, % "Reload" , MenuChoice
		
		if !(scriptName ~= "i)\.exe$")
			Menu,%scriptName%, Add, % "Edit"   , MenuChoice
		
		if (scriptName != A_ScriptName)
			Menu,%scriptName%, Add, % "Pause", MenuChoice
		
		Menu,%scriptName%, Add, % "Suspend", MenuChoice
		Menu,%scriptName%, Add, % "Exit"   , MenuChoice
		
		try
		{
			Menu,%scriptName%, Icon, % "Open Script Folder", shell32.dll ,4
			Menu,%scriptName%, Icon, % "Reload" , shell32.dll ,239
			;~ Menu,%scriptName%, Icon, % "Edit"   , shell32.dll,239 ;imageres.dll,290
			
			if !(scriptName ~= "i)\.exe$")
				Menu,%scriptName%, Icon, % "Edit"   , shell32.dll,270 ;trying a different icon
			
			if (scriptName != A_ScriptName)
				Menu,%scriptName%, Icon, % "Pause", % A_AhkPath ,4
			
			Menu,%scriptName%, Icon, % "Suspend", % A_AhkPath ,3
			Menu,%scriptName%, Icon, % "Exit"   , shell32.dll ,132
		}
		Catch, error
		{
			FileAppend, % a_now "`t" A_ComputerName "`t" scriptName "`t" error.what "`t" error.message "`n", error.log
			Throw, error
		}
		
		Menu, Tray, Add, %scriptName%,  :%scriptName%
		
		switch
		{
			case (InStr(scriptObj.iconFile, "A_ScriptFullPath")):
			scriptObj.iconFile := RegExReplace(scriptObj.iconFile, "i)(%\s?)?A_ScriptFullPath%?\\?")
			GoTo, main
			case (!scriptObj.iconFile || InStr(scriptObj.iconFile, "% ") || RegExMatch(scriptObj.iconFile, "%.*%")):
			icon := A_AhkPath, scriptObj.iconNumber := 1
			case (RegExMatch(scriptObj.iconFile, "^[a-zA-Z]:(\\|\/)") || InStr(scriptObj.iconFile, ".dll")):
			icon := scriptObj.iconFile
			default:
			main:
			icon := scriptObj.path "\" scriptObj.iconFile
			if !FileExist(icon)
				icon := A_AhkPath, scriptObj.iconNumber := 1
		}
		
		Menu, Tray, Icon, %scriptName%, % icon, % (scriptObj.iconNumber == 2 && icon == A_AhkPath) ? 2 : scriptObj.iconNumber
	}
	
	Menu, Tray, Add
	; Menu, Tray, Add, % "Check for Updates", % "Update"
	Menu, Tray, Add, % "About"
	Menu, Tray, Icon, % "About", % "C:\WINDOWS\system32\shell32.dll", 278 ;information
	Menu, Tray, Add
	Menu, Tray, Add, % "Close All Scripts", % "CloseAll"
	Menu, Tray, Icon, % "Close All Scripts", % "C:\WINDOWS\system32\shell32.dll", 110 ;close all scripts
	Menu, Tray, Add, % "Reload"
	Menu, Tray, Icon, % "Reload", % "C:\WINDOWS\system32\shell32.dll", 239 ;Reload all scripts
	; Menu, Tray, Default, % "Reload"                                         ;set it so reload is the default if clicking
	Menu, Tray, Add, % "Exit"
	Menu, Tray, Icon, % "Exit", % "C:\WINDOWS\system32\shell32.dll",132 ;exit   imageres.dll", 260
	;~ Catch, error
	;~ {
		;~ FileAppend, % a_now "`t" A_ComputerName "`t" A_ScriptName "`t" error.what "`t" error.message "`n", error.log
		;~ Throw, error
	;~ }
	
	; Menu, Tray, Standard ;add standard options to menu ;Joe Glines changed this.
	; If you want the other options in your menu uncomment this line
}

CloseAll(ItemName, ItemPos, MenuName)
{
	global menuHandles

	for scriptName,scriptObj in menuHandles
	{
		if (InStr(scriptName, "AHKScriptHub"))
			continue

		SendMessage, 0x111, 0xFF7D, 0,, % "ahk_id " scriptObj.hwnd
	}

	Exit(0,0,0)
}

MenuChoice(ItemName, ItemPos, MenuName)
{
	global menuHandles
	static menuMessages := {Reload:65400,Edit:65401,Pause:65403,Suspend:65404,Exit:65405}

	if (ItemName == "Open Script Folder")
		Run, % menuHandles[MenuName].path
	else
	{

		; try a few times to send the message
		Loop, 5
		{
			SendMessage, 0x111, menuMessages[ItemName], 0,, % "ahk_id " menuHandles[MenuName].hwnd,,,, 500

			if (ErrorLevel != "FAIL")
				break

			tooltip % "could not send message to edit the script, please try again: " ErrorLevel " " A_LastError, 100, 100
			sleep 1000
			tooltip
		}

		SetTitleMatchMode, RegEx
		WinWait, % MenuName,, 3

		if (!WinExist("i)" MenuName))
			msgbox % "The window doesnt exist"

		SetTitleMatchMode, 1
		CreateMenu()
	}
	Return
}

Reload(ItemName, ItemPos, MenuName)
{
	Reload
}

Exit(ItemName, ItemPos, MenuName)
{
	ExitApp, 0
}

About(ItemName, ItemPos, MenuName)
{
	script.about()
	return
}

Update(ItemName, ItemPos, MenuName)
{
	try
		script.update(false, false)
	catch err
		msgbox % err.code ": " err.msg

	return
}
