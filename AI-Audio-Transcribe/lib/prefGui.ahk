#Requires AutoHotkey v2.0
; here we are starting to put control on triggers UI before Adding hotkeys to triggers

scGui := triggers.UI
scGui.opt('AlwaysOnTop')
scGui.OnEvent('close',StopPrefMicBarUpdate)
MicMap := Map()
devMic := []
; BuildMicMap()
GetLanguagesMapNarray(&langsMap,&langsarray)

microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",0)
apikey := IniRead( triggers.ini, A_ComputerName, "APIKey",'')
language := IniRead( triggers.ini, A_ComputerName, "Language",'English')
scGui.AddText('y20 w160 right','Select Mic:')
micddl := scGui.AddDDL('x+m-5 w450 yp-3 section',devMic)
micddl.onevent('change',SelectDevice)

; scGui.AddText('xm w160 right','Input Level:')
prefMicBar := scGui.AddProgress('xs y+m-5 w450 h5 cblue section',70)

scGui.AddCheckbox('vShowMic xs -checked section','Show Microphone').onEvent('click',RebuldMicDropDown)

scGui.addText('x+m right','Vol:')
micvol := scGui.addText('x+m w80 ','')
if MicMap.Has(microphoneName)
	micvol.value := MicMap[microphoneName]

scGui.AddText('xm ym+100 w160 right','Spoken Language:')
Lang := scGui.AddDDL('x+m-5 r15 yp-3 w120',langsarray)
if language
	try Lang.text := language

TransClog := scGui.AddCheckBox('x+m+10 yp+3' ,'Transcribe Log')
if IniRead(triggers.ini, A_ComputerName, "Log",true)
	TransClog.value := true


scGui.addLink('xm yp+50 w160 right','Whisper <a href="https://platform.openai.com/api-keys" >API Key</a>:')
apiedit := scGui.AddEdit('x+m-5 yp-3 w420 -multi h27 section password',apikey)

apieditChk := scGui.AddCheckbox('xs','Show Password')
apieditChk.OnEvent('click',(*)=>showpassword(apieditChk, apiedit))

; scGui.addtext('xm yp+30 w500 +0x10',) ;;; just to pust space before trigger class add controls
scGui.Add("Progress", "xm yp+60 w600 h2 Backgroundgreen")
scGui.addtext('xm ')
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
	IniWrite(apiedit.value,  triggers.ini, A_ComputerName, "APIKey")
	IniWrite(Lang.Text,      triggers.ini, A_ComputerName, "Language")
	IniWrite(TransClog.value,triggers.ini, A_ComputerName, "Log")
	if !OpenAI.Authenticate(apiedit.value)
	{
		Notify.Show({BDText: "OpenAI Authentication failed", GenDuration:0, GenLoc:'Center',GenCallback:(*)=>(Run('https://platform.openai.com/api-keys'),triggers.show())})
		return
	}
	if startingHotkey := IniRead(triggers.ini, 'Hotkeys',StartRecording.name,'')
		Notify.Show({BDText:'Hold down  ' startingHotkey '  Key to start recording', GenDuration:5, GenLoc:'Center'} )
}


SelectDevice(ctrl,info)
{
	; scGui.Hide()
	; if !info
	; {
	; 	info := scLV.GetNext(0)
	; }
	DeviceName := micddl.text
	try micvol.value := MicMap[DeviceName]
	StartPrefMicBarUpdate()
	; Notify.Show("Mic set to " DeviceName "  #"  DeviceNum)
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
	loop
	{
		try
			devName := SoundGetName(, dev := A_Index)
		catch  ; No more devices.
			break	
		; Qualify names with ":index" where needed.
		cmpMap := Map()
		devName := Qualify(devName, cmpMap, dev)
		loop
		{
			try
				cmpName := SoundGetName(cmp := A_Index, dev)
			catch
				break
			; Retrieve this component's volume and mute setting, if possible.
			vol := mute := ""
			try vol := Round(SoundGetVolume(cmp, devName), 2)
			try mute := SoundGetMute(cmp, dev)
			; Display this component even if it does not support volume or mute,
			; since it likely supports other controls via SoundGetInterface().
			component := Qualify(cmpName, cmpMap, A_Index)
			if (scGui['ShowMic'].Value && !(devName ~= "i)Mic|Cap"))
				continue
			MicMap[devName] := vol
		}
	}
	Sleep 10
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

GetLanguagesMapNarray(&languageMap,&langsarray)
{
	langsarray := []
	languageMap :=Map(
		'(Autodetect)','',
		"Afrikaans", "af",
		"Arabic", "ar",
		"Armenian", "hy",
		"Azerbaijani", "az",
		"Belarusian", "be",
		"Bosnian", "bs",
		"Bulgarian", "bg",
		"Catalan", "ca",
		"Chinese", "zh",
		"Croatian", "hr",
		"Czech", "cs",
		"Danish", "da",
		"Dutch", "nl",
		"English", "en",
		"Estonian", "et",
		"Finnish", "fi",
		"French", "fr",
		"Galician", "gl",
		"German", "de",
		"Greek", "el",
		"Hebrew", "he",
		"Hindi", "hi",
		"Hungarian", "hu",
		"Icelandic", "is",
		"Indonesian", "id",
		"Italian", "it",
		"Japanese", "ja",
		"Kannada", "kn",
		"Kazakh", "kk",
		"Korean", "ko",
		"Latvian", "lv",
		"Lithuanian", "lt",
		"Macedonian", "mk",
		"Malay", "ms",
		"Marathi", "mr",
		"Maori", "mi",
		"Nepali", "ne",
		"Norwegian", "no",
		"Persian", "fa",
		"Polish", "pl",
		"Portuguese", "pt",
		"Romanian", "ro",
		"Russian", "ru",
		"Serbian", "sr",
		"Slovak", "sk",
		"Slovenian", "sl",
		"Spanish", "es",
		"Swahili", "sw",
		"Swedish", "sv",
		"Tagalog", "tl",
		"Tamil", "ta",
		"Thai", "th",
		"Turkish", "tr",
		"Ukrainian", "uk",
		"Urdu", "ur",
		"Vietnamese", "vi",
		"Welsh", "cy")
	for lng, abr in languageMap
		langsarray.push(lng)
}

; LVSelect(ctrl, Item,Select)
; {
; 	row := 0
; 	i := 0
; 	loop
; 	{
; 		row := scLV.GetNext(row)
; 		if !row
; 			break
; 		Dev := scLV.getText(row,1)
; 		++i
; 	}
; 	if i = 0
; 	{
; 		scGui['SelDev'].enabled := false
; 	}
; 	else
; 	{
; 		scGui['SelDev'].enabled := true
; 	}

; 	; if Dev
; 	; 	scGui['Mute'].text := "Unmute"
; 	; else
; 	; 	scGui['Mute'].text := "Mute"
; }

updatePrefMicBar()
{
	if micddl.text = ''
		return
	audioMeter := SoundGetInterface("{C02216F6-8C67-4B5B-9D00-D008E73E0064}",, micddl.text)
	
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