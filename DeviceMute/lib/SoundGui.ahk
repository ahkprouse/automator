#Requires AutoHotkey v2.0
Iconpath := [
	IconMute := A_ScriptDir '\res\MicMute.ico',
	IconUnmute := A_ScriptDir '\res\MicUnmute.ico',
	IconSpMute := A_ScriptDir '\res\SpMute.ico',
	IconSpUnmute := A_ScriptDir '\res\SpUnmute.ico',
]
; IconUnmute := A_ScriptDir '\res\MicUnmute.ico'
TraySetIcon IconUnmute
ini := A_ScriptDir "\Settings.ini"
; Sound config Gui
scGui := Gui('+AlwaysOnTop', "Choose Sound Components")
scGui.onevent('Close',(*) => RemoveHighlight())
scGui.onevent('escape',(*) => RemoveHighlight())
scLV := scGui.Add('ListView', "w450 h200", ["Component", "#", "Device", "Volume", "Mute"])
scGui.AddButton('xm vMute w80 +disabled',"Mute").OnEvent('click',muteDevice)
scGui.AddButton('x+m vSelDev w80 +disabled',"Select").OnEvent('click',SelectDevice)
scGui.AddCheckbox('x+m yp+5 vMicFilter +Checked','Microphone Filter').OnEvent('click',BuildLV)
scGui.AddButton('x+m yp-5 vset w75',"Preferences").onevent('click',(*) => (scGui.Opt('-alwaysontop +disabled'),cGui.Opt('owner' scGui.hwnd),cGui.Show()))
scGui.AddButton('x+m vClose w75',"Close").onevent('click',(*) => RemoveHighlight())
scLV.OnEvent("DoubleClick", SelectDevice)
scLV.OnEvent('ItemSelect',LVSelect)

ImageListID := IL_Create(4)  ; Create an ImageList to hold 10 small icons.
IL_Add(ImageListID, IconMute)
IL_Add(ImageListID, IconUnmute)
IL_Add(ImageListID, IconSpMute)
IL_Add(ImageListID, IconSpUnmute)
scLV.SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.

BuildLV()
scGui.Show('hide')

RemoveHighlight()
{
	scGui.Hide()
	try UIA.ClearAllHighlights()
}

ChooseSoundDevice(*)
{
	global scGui
	run 'ms-settings:sound'
	
	; BuildLV()
	
	Notify.Show("Double-click a device to select it.")

	win_settings := UIA.ElementFromHandle("Settings ahk_exe ApplicationFrameHost.exe")
	micvol := win_settings.WaitElement({AutomationId:"SystemSettings_Audio_Input_VolumeValue_EntityItem"})
	win_settings.WaitElement({Type:"Group", Name:"Advanced"}).ScrollIntoView()
	loop 3
	{
		micvol.Highlight(500)
		Sleep 300
	}
	micvol.Highlight(0)
	scGui.Show()
}


; Qualifies full names with ":index" when needed.
Qualify(name, names, overallIndex)
{
	if name = ''
		return overallIndex
	key := StrLower(name)
	index := names.Has(key) ? ++names[key] : (names[key] := 1)
	return (index > 1 || InStr(name, ':') || IsInteger(name)) ? name ':' index : name
}

muteDevice(*)
{
	row := 0
	i := 0
	loop
	{
		row     := scLV.GetNext(row)
		if !row
			break
		devName := scLV.getText(row,1)
		devNum  := scLV.getText(row,2)
		Dev     := scLV.getText(row,3)
		iRow := row
		++i
	}

	mute := SoundGetMute(devName,devNum)
	if Dev ~= "i)Speaker"
		iconum := 3
	else 
		iconum := 1	

	If mute=1
	{
		SoundSetMute(0,devName,devNum)
		scLV.Modify(iRow,'Icon' iconum +1 ,,,,,0)
		Notify.show({BDText:Dev " set to unmute",GenIcon:Iconpath[iconum +1],HDFontColor:0x23B14D})
		scGui['Mute'].text := "Mute"
		TraySetIcon Iconpath[iconum +1]
	}
	Else
	{
		SoundSetMute(1,devName,devNum)
		scLV.Modify(iRow,"Icon" iconum ,,,,,1)
		Notify.show({BDtext:Dev " set to mute",GenIcon:Iconpath[iconum],HDFontColor:"Red"})
		scGui['Mute'].text := "Unmute"
		TraySetIcon Iconpath[iconum]
	}
}


BuildLV(*)
{
	scLV.delete()
	devMap := Map()
	loop
	{
		; For each loop iteration, try to get the corresponding device.
		try
			devName := SoundGetName(, dev := A_Index)
		catch  ; No more devices.
			break
		
		; Qualify names with ":index" where needed.
		devName := Qualify(devName, devMap, dev)
		
		; Retrieve master volume and mute setting, if possible.
		vol := mute := ""
		try vol := Round(SoundGetVolume( , dev), 2)
		try mute := SoundGetMute( , dev)
		
		; ; Display the master settings only if at least one was retrieved.
		; if vol != "" || mute != ""
		; if devName ~= "Microphone"
		; if scGui['MicFilter'].value = 0
		;          scLV.Add("Icon" (mute?1:2), "", dev, devName, vol, mute)
		
		; For each component, first query its name.
		cmpMap := Map()
		
		loop
		{
			try
				cmpName := SoundGetName(cmp := A_Index, dev)
			catch
				break
			; Retrieve this component's volume and mute setting, if possible.
			vol := mute := ""
			try vol := Round(SoundGetVolume(cmp, dev), 2)
			try mute := SoundGetMute(cmp, dev)
			; Display this component even if it does not support volume or mute,
			; since it likely supports other controls via SoundGetInterface().
			component := Qualify(cmpName, cmpMap, A_Index)
			if devName ~= "i)Speaker"
				iconum := 3
			else 
				iconum := 1

			if devName ~= "i)Mic"
			&& component ~= "i)Mic|Cap"
			&& scGui['MicFilter'].value
				scLV.Add("Icon" iconum + (mute?0:1) , component, dev, devName, vol, mute)
			else if scGui['MicFilter'].value = 0
				scLV.Add("Icon" iconum + (mute?0:1) , component, dev, devName, vol, mute) ; + (component ~= "i)Mic|Cap" ? 0:2) 
				
		}
	}

	loop 5
		scLV.ModifyCol(A_Index, 'AutoHdr Logical')
}

SelectDevice(ctrl,info)
{
	scGui.Hide()
	try UIA.ClearAllHighlights()
	if !info
	{
		info := scLV.GetNext(0)
	}
	DeviceName := scLV.getText(info,1)
	DeviceNum := scLV.getText(info,2)
	IniWrite(DeviceName, A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceName")
	IniWrite(DeviceNum, A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceNum")
	Notify.Show("Mic set to " DeviceName "  #"  DeviceNum)
	;Sleep 2000
	;exitapp
}

LVSelect(ctrl, Item,Select)
{
	row := 0
	i := 0
	loop
	{
		row := scLV.GetNext(row)
		if !row
			break
		Dev := scLV.getText(row,5)
		++i
	}
	if i = 0
	{
		scGui['SelDev'].enabled := false
		scGui['Mute'].enabled := false
		scGui['Mute'].text := "Mute"
	}
	else
	{
		scGui['SelDev'].enabled := true
		scGui['Mute'].enabled := true
	}

	if Dev
		scGui['Mute'].text := "Unmute"
	else
		scGui['Mute'].text := "Mute"
}
