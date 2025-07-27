#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <NotifyV2>
#include <ScriptObj\scriptobj>
Persistent
Notify.default.HDtext := 'AutoSave Incrementer'

script := {
	        base : ScriptObj(),
			hwnd : 0,
	     version : "0.0.0",
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	;    resfolder : A_ScriptDir "\res",
	     iconfile : "shell32.dll",
	      config : A_ScriptDir '\Config.ini',
	homepagetext : "the-automator.com/AutoIncrement",
	homepagelink : "the-automator.com/AutoIncrement?src=app",
	  donateLink : "",
}

TraySetIcon(script.iconfile, 259)

tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.Add('Open' , (*) => (mGui.show(), OnMessage(MsgNum, AutoChangeSaveLoc,0)))
tray.Default := 'Open'
tray.Add('Preferences' , (*) => (pGui.show(), mGui.Hide() ,hotkey(	pGui.oldHK, (*)=> mGui.Show(),'off')))
tray.Add('Reset Counter', resetCounter)
tray.Add("Exit",(*) => Exitapp())
tray.AddStandard()

#include <ConfigGui>
mGui := Gui()
script.hwnd := mGui.Hwnd
if iniread(Script.Config, "Settings", "ProgCheck", 1)
	ProgCheck := '+Checked', mGui.num := Map()
else
	ProgCheck := '-Checked', mGui.num := 0

if iniread(Script.Config, "Settings", "HitSave", 0)
	SaveCheck := '+Checked'
else
	SaveCheck := '-Checked'

; mGui.OnEvent("Close", (*) => Exitapp())
mGui.SetFont("s12", "Arial")
mGui.AddText('ym+10 w120 right','Base File Name:')
mGui.AddEdit('x+m yp-3 w210 vBaseName',iniread(Script.Config, "Settings", "BaseName", "Untitled"))
mGui.marginY := 25
; mGui.AddText('x+m yp+3','Ext:')
; mGui.AddEdit('x+m w75 yp-3  Limit5 vBaseExt',iniread(Script.Config, "Settings", "BaseExt", ".txt"))
mGui.AddText('xs y+m+3 w120 right','Increment#:')
mGui.AddEdit('x+m w75 yp-3')
mGui.AddUpDown('xp Range1-1000 vBaseNum',iniread(Script.Config, "Settings", "BaseNum", 1))
mGui.AddButton( "x+m yp-3", "Reset Counter").OnEvent("Click", resetCounter)
mGui.AddCheckbox('xm y+m+3 vHitSave ' SaveCheck,'Autosave')
mGui.AddCheckbox('x+m vProg ' ProgCheck,'Increment by Program Name')
mGui.AddButton( "xm w120", "Preferences").OnEvent("Click", (*) => (pGui.show(), mGui.Hide() ,hotkey(	pGui.oldHK, (*)=> mGui.Show(),'off')))
mGui.AddButton( "x+m+110 w100", "Apply").OnEvent("Click", applysettings)
mGui.Show()

DllCall 'RegisterShellHookWindow', 'UInt', mGui.hwnd
MsgNum := DllCall('RegisterWindowMessage', 'Str','SHELLHOOK')
OnMessage(MsgNum, AutoChangeSaveLoc,0)

; ~Lbutton::OnMessage(MsgNum, AutoChangeSaveLoc)

applysettings(*)
{
	BaseName := mGui["BaseName"].value
	BaseNum  := mGui["BaseNum"].value
	ProgCheck := mGui["Prog"].value
	HitSave := mGui["HitSave"].value
	if BaseName = "" 
	{
		Notify.show("Please enter a valid Base File Name and Extension")
		return
	}
	if !RegExMatch(BaseName, '^(?!.*(\.\.|--|__))[a-zA-Z0-9_. -]+(?<![. ])$')
		return Notify.show("Please enter a valid Base File Name")
	if ProgCheck
		mGui.num := Map()
	else
		mGui.num := 0
	IniWrite(BaseName,  Script.Config, "Settings", "BaseName")
	IniWrite(BaseNum,   Script.Config, "Settings", "BaseNum")
	IniWrite(ProgCheck, Script.Config, "Settings", "ProgCheck")
	IniWrite(HitSave,   Script.Config, "Settings", "HitSave")
	mGui.hide()
	OnMessage(MsgNum, AutoChangeSaveLoc)
}

AutoChangeSaveLoc(wParam, lParam, msg, hwnd)
{
	static HSHELL_MONITORCHANGED := 16
	if wParam != HSHELL_MONITORCHANGED
		return
	
	if !WinWaitActive('ahk_class #32770',,3) 
	|| !WinExist('ahk_class #32770',,3)
		return
	Diag := WinGetTitle('ahk_class #32770')
	if !InStr(Diag, "Save")
		return
	OnMessage(MsgNum, AutoChangeSaveLoc,0)
	pid := WinGetPID()
	parent_pid := ProcessGetParent(pid)
	ProcessName := ProcessGetName(pid)
	
	switch Type(mGui.num), false
	{
		Case 'map':
			mGui.num[ProcessName] := mGui.num.has(ProcessName) ? mGui.num[ProcessName] += 1 : mGui.num[ProcessName] := mGui["BaseNum"].value
			mGui["BaseNum"].value := mGui.num[ProcessName]
		Case 'integer':
			if mGui.num = 0
				mGui.num := mGui["BaseNum"].value
			else
				mGui["BaseNum"].value := (mGui.num += 1)
	}
	BaseName := mGui["BaseName"].value
	BaseNum  := Format('{:0' pGui['Zero'].value + 1 '}' ,mGui["BaseNum"].value)
	HitSave := mGui["HitSave"].value
	SendMode 'input'
	SetControlDelay 100
	send '{ctrl up}{shift up}{s up}'
	WinWaitActive(Diag ' ahk_pid ' pid)
	ControlSetText BaseName '_' BaseNum, 'Edit1',  Diag ' ahk_pid ' pid
	ControlSend '{End}', 'Edit1', Diag ' ahk_pid ' pid
	; sleep 200
	; Send('{space}')
	; Send('{backSpace}')
	if HitSave
	{
		text := 1
		ControlFocus('Edit1', Diag ' ahk_pid ' pid)
		ControlSend '{space}{backSpace}{enter}', 'Edit1', Diag ' ahk_pid ' pid
		if !WinWaitClose(Diag ' ahk_pid ' pid,,1500)
		{
			Notify.show("unable to Save Dialog did not close")
		}
		else
			Notify.show('File Saved as: ' BaseName '_' BaseNum)
		OnMessage(MsgNum, AutoChangeSaveLoc)
		Return
	}

	if !WinWaitClose(Diag ' ahk_pid ' pid,,)
	{
		throw "Save Dialog did not close"
	}
	OnMessage(MsgNum, AutoChangeSaveLoc)
}

resetCounter(*)
{
	switch Type(mGui.num), false
	{
		Case 'map':
			mGui.num := Map()
		Case 'integer':
			mGui.num := 0
	}
	mGui["BaseNum"].value := 1
}

Browser_Forward::Reload()