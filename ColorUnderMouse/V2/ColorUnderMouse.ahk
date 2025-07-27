;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover  *
;******************************************************************************
#SingleInstance Force
#Requires Autohotkey v2.0+
;--
;@Ahk2Exe-SetVersion     0.2.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName ColorUnderMouse
;@Ahk2Exe-SetDescription Gets the current hex value of the pixel under the mouse
;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses. 
; They're structured in a way to make learning AHK EASY.
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover
;*******************************************************
;{#Includes
 ;#Include <ScriptObject\ScriptObject>
 
script := {  name           : regexreplace(A_ScriptName, "\.\w+")
            ,version        : "0.2.0"
            ,author         : "Joe Glines"
            ,email          : "joe.glines@the-automator.com"
            ,crtdate        : "July 28, 2022"
            ,moddate        : "July 28, 2022"
            ,homepagetext   : ""
            ,homepagelink   : ""
            ,donateLink     : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
            ,resfolder      : A_ScriptDir "\res"
            ,iconfile       : A_ScriptDir "\res\main.ico"
            ,configfile     : A_ScriptDir "\settings.ini"
            ,configfolder   : A_ScriptDir ""
            ,VideoLink      : ""
            ,DevPath        : "S:\ColorUnderMouse\V2\ColorUnderMouse V2.ahk"
            ,baase          : 'script'}
;}
;{#Directives
;}--
;{#Settings
TraySetIcon("shell32.dll","131")
#Include <NotifyV2>

main := Gui(,'Assign Hotkey')
ini := 'Settings.ini'

CreateTryMenu()
CreateTryMenu(*)
{
	global tray := A_TrayMenu
	tray.Delete()
	tray.Add("Preferences`t",(*) =>  main.Show())
	hk := IniRead(ini,'HOTKEY','HK',"NotAssign")
	tray.Add("Color Under Mouse`t" HKToString(hk),(*) => false)
	tray.Add()
	tray.add('Open Folder',(*)=>Run(A_ScriptDir))
	tray.SetIcon("Open Folder","shell32.dll",4)
	tray.Add("About",(*) => Script.About())
	tray.Add("Exit`t",(*) => Exitapp())
}

move_active := false
ListViewfontsize := 13
main.SetFont('S' ListViewfontsize)
main.AddText('w250 center h25 ','ColorUnderMouse').SetFont('S' ListViewfontsize+2)
SetWin := main.AddCheckbox('yp+40','Win')
SetHK := main.AddHotkey('x+m yp-3', '')
main.AddButton('w115 xm','Apply').OnEvent('Click',Apply)
main.AddButton('w115 x+m','Cancel').OnEvent('Click',(*) => ExitApp())
Showkey
Showkey(*)
{
	AssignedHK := IniRead(ini,'HOTKEY','HK', false)
	if InStr(AssignedHK,"#")
	{
		AssignedHK := StrReplace(AssignedHK,"#")
		SetHK.value := AssignedHK
		SetWin.value := true
	}
	else
	{
		if (AssignedHK = false)
		{
			main.Show()
		}
		else
		{
			SetHK.value := AssignedHK
			Hotkey(AssignedHK, GetColourandpixel,'on')
		}
	}
}

Apply(*)
{	
	oldHK := IniRead(ini,'HOTKEY','HK','NotAssign')
    if (oldHK != "NotAssign")
        Hotkey(oldHK,GetColourandpixel,'off')

	IF SetWin.value
	{
		IniWrite('#' SetHK.value,ini,'HOTKEY','HK')
		Hotkey('#' SetHK.value,GetColourandpixel,'on')
	}
	else
	{
		IniWrite(SetHK.value,ini,'HOTKEY','HK')
		Hotkey(SetHK.value,GetColourandpixel,'on')
	}
	CreateTryMenu
	Showkey
    main.Hide()
}

;**************************************
;#c::  ;Windows+C hotkey will get color at current position of mouse.  Change the hotkey to your preference
GetColourandpixel(*)
{
    MouseGetPos &x , &y
    Color := PixelGetColor(x,y,'RGB')
    A_Clipboard := color

    Notify.Show({
        HDText      : "You Copied in Clipboard",
        HDFontColor : 'Black', 
        BDText      : Color ,
        BDFontColor : 'Black',
        GenBGcolor  : Color, 
        BDFontSize  : "15"
    })
}
return



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