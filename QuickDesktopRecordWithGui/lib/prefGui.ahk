#Requires AutoHotkey v2.0
; here we are starting to put control on triggers UI before Adding hotkeys to triggers

scGui := triggers.UI
scGui.opt('AlwaysOnTop')
scGui.OnEvent('close',StopPrefMicBarUpdate)
MicMap := Map()
devMic := []

microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",0)
settingsFps  := IniRead(triggers.ini, "Settings", "fps_cap", "30" )  ; 20,30,40,50,60
settingsType := IniRead(triggers.ini, "Settings", "type"   , "mp4")  ; mp4,mkv
scGui.AddText('y20 w140 right','Select Mic:')
micddl := scGui.AddDDL('x+m-5 w450 yp-3 section',devMic)
micddl.onevent('change',SelectDevice)

prefMicBar := scGui.AddProgress('xs y+m-5 w450 h5 cblue section',70)

scGui.AddCheckbox('vShowMic xs -checked section','Show Microphone').onEvent('click',RebuldMicDropDown)

scGui.addText('x+m right','Vol:')
micvol := scGui.addText('x+m w80 ','')
if MicMap.Has(microphoneName)
	micvol.value := MicMap[microphoneName]

scGui.AddText('xm y+m+15 w140 right','Format:')
typeddl := scGui.AddDDL('x+m-5 w80 yp-3 section',["mp4","mkv"])
typeddl.Choose(settingsType)
scGui.AddText('x+m+5 right yp+3','Frames per second:')
fpsddl := scGui.AddDDL('x+m-5 w80 yp-3 section',["20","30","40","50","60"])
fpsddl.Choose(settingsFps) 

RebuldMicDropDown()

showpassword(chkbox,edit)
{
	if chkbox.value
		edit.Opt('-password')
	else
		edit.Opt('+password')
}

Savesettings(*)
{
	DeviceName := micddl.text
	IniWrite(DeviceName,     triggers.ini, A_ComputerName, "DeviceName")
	IniWrite(fpsddl.text,   triggers.ini, "Settings", "fps_cap")
	IniWrite(typeddl.text,  triggers.ini, "Settings", "type")
	StopPrefMicBarUpdate()
	UpdateRecordingSettings()
	sGui.show()
}

UpdateRecordingSettings()
{
	Global hotkeyRecord, hotkeyStop, settingsFps, settingsType, winPositionX, winPositionY, settingsFps, microphoneName
	; Read settings from INI file
	; hotkeyRecord := IniRead(A_ScriptDir "\settings.ini", "Main", "Record", "^+r")
	; hotkeyStop := IniRead(A_ScriptDir "\settings.ini", "Main", "Stop", "^+s")
	settingsFps := IniRead(A_ScriptDir "\settings.ini", "Settings", "fps_cap", "30") ; 20,30,40,50,60
	settingsType := IniRead(A_ScriptDir "\settings.ini", "Settings", "type", "mp4")  ; mp4,mkv
	microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",false)
	; microphoneNumber := IniRead(A_ScriptDir "\settings.ini", "Settings", "microphone_number", "1")
	; winPositionX := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_x", winPositionX)
	; winPositionY := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_y", winPositionY)

	; Convert settings to appropriate types
	settingsFps := Integer(settingsFps)
	GetWindowPosition()
}


SelectDevice(ctrl,info)
{
	DeviceName := micddl.text
	try micvol.value := MicMap[DeviceName]
	StartPrefMicBarUpdate()
}

RebuldMicDropDown(*)
{
	global MicMap, devMic
	BuildMicMap()
	devMic := []
	for devName, vol in MicMap
			devMic.push(devName)
	micddl.delete()
	micddl.Add(devMic)
}

BuildMicMap(*)
{
	global MicMap, devMic
	MicMap := Map()
	devMic := []
	for i, device in FFMPEG.GetDevices()
	{
		vol := 0
		try vol := Round(SoundGetVolume(, device), 2)
		MicMap[device] := vol
	}
	Sleep 10
}

updatePrefMicBar()
{
	if micddl.text = ''
		return
	try audioMeter := SoundGetInterface("{C02216F6-8C67-4B5B-9D00-D008E73E0064}",, micddl.text)
	catch
		return
	
	if audioMeter
	{
		; audioMeter->GetPeakValue(&peak)
		ComCall 3, audioMeter, "float*", &peak:=0
		if  peak > 0
			prefMicBar.value := peak * 1000
		else
			prefMicBar.value := 0
		Sleep 15
		; ObjRelease audioMeter
	}
	; else
	; {
	; 	this.hide()
	; 	MsgBox "Unable to get audio Device"
	; }
}

StartPrefMicBarUpdate(*)
{
	settimer updatePrefMicBar, 100
}

StopPrefMicBarUpdate(*)
{
	settimer updatePrefMicBar, 0
}