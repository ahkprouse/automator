#Requires AutoHotkey v2.0
; config / prefernces gui
cGui := Gui(,'Mic Mute Settings')
cGui.BackColor := "White"

; hotkey for select Mic Mute
cGui.oldHK  := IniRead(ini,"Hotkeys-" A_UserName ,'HK','^+m')
cGui.AddText("+0x200", "Toggle Microphone")
cGui.AddHotkey("vHK ", StrReplace(cGui.oldHK,"#"))
cGui.AddCheckbox('x+m yp+3 vSet_Win','Win')
if InStr(cGui.oldHK,"#")
    cGui['Set_Win'].value := true
else
    cGui['Set_Win'].value := false
if cGui.oldHK ; in case user doesn't want hotkey for this function
	Hotkey(cGui.oldHK,MuteMicDevice,'on')

; hotkey for Default Speaker mute
cGui.oldSPHK  := IniRead(ini,"Hotkeys-" A_UserName,'SPHK','^+#m')
cGui.AddText("xm +0x200", "Toggle Default Speaker ")
cGui.AddHotkey("vSPHK ", StrReplace(cGui.oldSPHK,"#"))
cGui.AddCheckbox('x+m yp+3 vSP_Win','Win')
if InStr(cGui.oldSPHK,"#")
    cGui['SP_Win'].value := true
else
    cGui['SP_Win'].value := false
if cGui.oldSPHK ; in case user doesn't want hotkey for this function
	Hotkey(cGui.oldSPHK,DefaultSpeakerMute,'on')

; Hotkey for Both Devices Mute (default speaker and selected mic)
cGui.oldBHK  := IniRead(ini,"Hotkeys-" A_UserName ,'BHK','!m')
cGui.AddText("xm +0x200", "Toggle Both Mic && Speaker")
cGui.AddHotkey("vBHK ", StrReplace(cGui.oldBHK,"#"))
cGui.AddCheckbox('x+m yp+3 vBWin','Win')
if InStr(cGui.oldBHK,"#")
    cGui['BWin'].value := true
else
    cGui['BWin'].value := false
if cGui.oldBHK ; in case user doesn't want hotkey for this function
	Hotkey(cGui.oldBHK,MuteUnmuteinout,'on')

cGui.AddText('xm','Mute Message Position')
cGui.AddDropDownList('xm vMuteNotePos',['TopLeft','TopRight','BottomLeft','BottomRight','Center']).OnEvent("Change",MuteNote)
cGui['MuteNotePos'].Text := IniRead(ini, "Settings-" A_UserName ,"MuteNotePos","BottomRight")

;cGui.AddCheckbox('xm','Start with Windows').OnEvent("Click",(*) => IniWrite(cGui['Start with Windows'].value, ini, "Settings" ,"Start with Windows")

if IniRead(ini, "Settings-" A_UserName,"MuteNote",0)
	check := "+"
else
	check := "-"
cGui.AddCheckbox('xm vMuteNote ' check 'Checked' ,'Message Stays On for Mute Reminder').OnEvent("Click",(*) => IniWrite(cGui['MuteNote'].value, ini, "Settings-" A_UserName,"MuteNote"))

cGui.AddButton( "xm w100", "&Apply").OnEvent("Click",SetHotkey)
cGui.AddButton( "w100 x+m", "&Cancel").OnEvent("Click",(*) => (cGui.Hide(),scGui.Opt('+alwaysontop -disabled')))

cGui.Title := "Set Hotkey"
;cGui.Show()
MuteNote(*) => IniWrite(Notify.Default.GenLoc := cGui['MuteNotePos'].text, ini, "Settings-" A_UserName,"MuteNotePos")

DisableallHotkeys()
{
	if cGui.oldHK
		Hotkey(oldHK   := cGui.oldHK  ,MuteMicDevice     ,'off')
	if cGui.oldSPHK
	Hotkey(oldSPHK := cGui.oldSPHK,DefaultSpeakerMute,'off')
	if cGui.oldBHK
		Hotkey(oldBHK  := cGui.oldBHK ,MuteUnmuteinout   ,'off')
}

SetHotkey(*)
{
	global scGui
	if cGui['HK'].value
	&& cGui['Set_Win'].value '|' cGui['HK'].value   = cGui['SP_Win'].value '|' cGui['SPHK'].value
	|| cGui['SPHK'].value
	&& cGui['Set_Win'].value '|' cGui['HK'].value   = cGui['BWin'].value   '|' cGui['BHK'].value 
	|| cGui['BHK'].value 
	&& cGui['SP_Win'].value  '|' cGui['SPHK'].value = cGui['BWin'].value   '|' cGui['BHK'].value 
	{
		Notify.Show('Duplicate Hotkeys are not allowed')
		return 
	}

	; for crr_control in cGui
	; {
	; 	if ctrl.type != 'Hotkey'
	; 		continue

	; 		for ctrl in cGui
	; 		{
	; 			if ctrl.type != 'Hotkey'
	; 				continue

	; 			if ctrl.value
	; 			&& cGui[ctrl.name '_Win'].value '|' ctrl.value == cGui[crr_control.name '_Win'].value '|' crr_control.value
	; 			{
	; 				Notify.Show('Duplicate Hotkeys are not allowed')
	; 				return 
	; 			}
	; 		}
	; }

	DisableallHotkeys()
	oldHK   := cGui.oldHK
	oldSPHK := cGui.oldSPHK
	oldBHK  := cGui.oldBHK
    cGui.Hide()
    
    if Set_Win := cGui['Set_Win'].value && cGui['HK'].value
        IniWrite cGui.oldHK := "#" cGui['HK'].value, ini, "Hotkeys-" A_UserName ,"HK"
    else
        IniWrite cGui.oldHK := cGui['HK'].value, ini, "Hotkeys-" A_UserName,"HK"
	if cGui.oldHK ; in case user doesn't want hotkey for this function
    	Hotkey(cGui.oldHK,MuteMicDevice, 'on')
    Tray.Rename("Mic Mute/Unmute`t" HKToString( oldHK),"Mic Mute/Unmute`t" HKToString(cGui.oldHK))

	
    if SP_Win := cGui['SP_Win'].value && cGui['SPHK'].value
        IniWrite cGui.oldSPHK := "#" cGui['SPHK'].value, ini, "Hotkeys-" A_UserName,"SPHK"
    else
        IniWrite cGui.oldSPHK := cGui['SPHK'].value, ini, "Hotkeys-" A_UserName,"SPHK"
	if cGui.oldSPHK ; in case user doesn't want hotkey for this function
	    Hotkey(cGui.oldSPHK,DefaultSpeakerMute, 'on')
    Tray.Rename("Default Speaker Mute/Unmute`t" HKToString( oldSPHK),"Default Speaker Mute/Unmute`t" HKToString(cGui.oldSPHK))

	if BWin := cGui['BWin'].value && cGui['BHK'].value
        IniWrite cGui.oldBHK := "#" cGui['BHK'].value, ini, "Hotkeys-" A_UserName,"BHK"
    else
        IniWrite cGui.oldBHK := cGui['BHK'].value, ini, "Hotkeys-" A_UserName,"BHK"
	if cGui.oldBHK ; in case user doesn't want hotkey for this function
    	Hotkey(cGui.oldBHK,MuteUnmuteinout, 'on')
    Tray.Rename("Mute Both`t" HKToString( oldBHK),"Mute Both`t" HKToString(cGui.oldBHK))
	scGui.Opt('+alwaysontop -disabled')
}

HKToString(hk)
{
	; removed logging due to performance issues
	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'started', 'none')

	if !hk
		return 'None'

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