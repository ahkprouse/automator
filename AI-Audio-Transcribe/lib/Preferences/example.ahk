#Requires AutoHotkey v2.0
#include Triggers.ahk

Protocol := ''
ClientNum := ''

try DirCreate('logs')

FileAppend("[" A_Now "] Completed Protocol " Protocol " on Client " ClientNum,   "logs\scheduled.log")



















/*
triggers.AddHotkey(openSettings,'Open Settings','f1')
triggers.AddHotkey(takescreenshot,'Take Screenshot')
triggers.AddHotstring(somename(*)=>Send('by the way'),'by the way','btw','ahk_exe Code.exe')
triggers.FinishMenu('Settings')
if !FileExist(Triggers.ini) ; if user running program first time which mean there is no ini file created yet so user will be asked to change the default hotkeys
	triggers.Show()
triggers.tray.AddStandard() ; to add standard menu

openSettings(*)
{
	msgbox A_ThisFunc ' is called by ' A_ThisHotkey
}

takescreenshot(*)
{
	msgbox A_ThisFunc ' is called by ' A_ThisHotkey
}

/*

*/