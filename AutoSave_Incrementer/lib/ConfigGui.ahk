#Requires AutoHotkey v2.0
; mGui := Gui()
; mGui.Addtext(,'here it is main')
; script := {}
; Script.Config := A_ScriptDir '\Config.ini'
win := IniRead(Script.Config, "Hotkey", "Win", false)
HK := IniRead(Script.Config, "Hotkey", "HK", '^Home')
check := win? '+checked': '-checked'
pGui := Gui(,'Preferences')
pGui.MarginY := 25

pGui.SetFont("s12", "Arial")
pGui.AddText('ym+10','Open:')
if win
	pGui.oldHK := '#' HK
else
	pGui.oldHK := HK
tray.Rename('Open',pGui.trayname := 'Open        ' HKToString(pGui.oldHK))

pGui.AddCheckbox('x+m yp+3 vWin ' check,'Win')
pGui.AddHotkey('x+m yp-3 w180 vHK',HK)

pGui.AddText('xm','Pad name with Zeros: ')
pGui.AddEdit('x+m yp-3 w75')
pGui.AddUpDown('xp yp-3 Range0-3 vZero',IniRead(Script.Config, "Format", "Zero", 1))

pGui.AddButton( "xs", "Save").OnEvent("Click",applyPrefernces)
hotkey(	pGui.oldHK, (*)=> mGui.Show(),'on')
; pGui.Show()
applyPrefernces(*)
{
	hotkey(pGui.oldHK , (*)=> mGui.Show(),'off')
	win := pGui['win'].value
	HK := pGui['HK'].value
	if win
		pGui.oldHK := '#' HK
	else
		pGui.oldHK := HK
	hotkey(pGui.oldHK , (*)=> mGui.Show(),'on')
	IniWrite(win, Script.Config, "Hotkey", "Win")
	IniWrite(HK, Script.Config, "Hotkey", "HK")
	tray.Rename(pGui.trayname,pGui.trayname := 'Open        ' HKToString(pGui.oldHK))
	IniWrite(pGui['Zero'].value, Script.Config, "Format", "Zero")
	pGui.Hide()
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






