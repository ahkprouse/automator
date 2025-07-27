;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover  *
;******************************************************************************
/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
 
 Original TextUnderMouse by "nepter" http://www.autohotkey.com/board/topic/94619-ahk-l-screen-reader-a-tool-to-get-text-anywhere/#entry596215
*/
#Requires AutoHotkey v2.0
#SingleInstance Force
#include <UIA>
#include <ResizableGUI>
#include <NotifyV2>
#Include <scriptobj>

script := {
		base : ScriptObj(),
		version : '0.0.0',
		author : '',
		email : '',
		crtdate : 'February 23, 2024',
		moddate : 'February 23, 2024',
		resfolder : A_ScriptDir "\res",
		iconfile : A_ScriptDir '\res\T.ico' ,
		config : A_ScriptDir "\settings.ini",
		homepagetext : "the-automator.com/TextUnderMouse",
		homepagelink : "the-automator.com/TextUnderMouse?src=app",
		donateLink : 'https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6',
}

ini := script.config
myGui := Gui()
myGui.BackColor := "White"

myGui.oldHK  := IniRead(ini,"Hotkeys" ,"HK",'^+c')

myGui.AddText("+0x200", "Set Hotkey")
myGui.AddHotkey("vHK ", StrReplace(myGui.oldHK,"#"))

myGui.AddCheckbox('x+m yp+3 vSet_Win','Win')
if InStr(myGui.oldHK,"#")
	myGui['Set_Win'].value := true
else
	myGui['Set_Win'].value := false

Hotkey(myGui.oldHK,TextUnderMouse,'on')
myGui.AddButton( "xm w100", "&Apply").OnEvent("Click",SetHotkey)
myGui.AddButton( "w100 x+m", "&Cancel").OnEvent("Click",(*) => myGui.Hide())

myGui.Title := "Preferences"
;myGui.Show()

tray := A_TrayMenu
tray.Delete()
tray.Add("Hotkey`t" HKToString(myGui.oldHK),(*) => mygui.Show())

tray.Add("About",(*) => Script.About())
tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()
TraySetIcon script.iconfile


SetHotkey(*)
{
	mygui.Hide()
	Hotkey(myGui.oldHK,TextUnderMouse,'off')
	
	Set_Win := myGui['Set_Win'].value
	if Set_Win
		IniWrite myGui.oldHK := "#" myGui['HK'].value, ini, "Hotkeys" ,"HK"
	else
		IniWrite myGui.oldHK := myGui['HK'].value, ini, "Hotkeys" ,"HK"
	Hotkey(myGui.oldHK,TextUnderMouse, 'on')
	
}

Notify.Default.HDText := 'Text Under Mouse'
GuiWidth := 400
GuiHeight := 400

;f1::
TextUnderMouse(*)
{
	CoordMode 'mouse','screen'
	MouseGetPos(&x,&y,&hwnd,&ctrlHwnd,1)
	elem := UIA.SmallestElementFromPoint(x,y)
	text := elem.value
	if (text = "")
		text := elem.Name
	if text != ''
		ResizableGUI(A_Clipboard := text,GuiWidth,GuiHeight), elem.Highlight()
	else
		Notify.show('Unable to Find Text')
}


HKToString(hk)
{
	; removed logging due to performance issues
	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'started', 'none')

	if !hk
		return

	temphk := []

	if InStr(hk, '#')
		temphk.Push('Win+')
	if InStr(hk, '^')
		temphk.Push('Ctrl+')
	if InStr(hk, '+')
		temphk.Push('Shift+')
	if InStr(hk, '!')
		temphk.Push('Alt+')

	hk := RegExReplace(hk, '[#^+!]')
	for mod in temphk
		fixedMods .= mod

	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'ended', 'none')
	return (fixedMods ?? '') StrUpper(hk)
}