/**
 * =========================================================================== *
 * @author      The Automator                                                  *
 * @version     0.6.7                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-03-14                                                     *
 * @modified    2024-08-30                                                     *
 * @description                                                                *
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
;@Ahk2Exe-SetVersion     "0.6.7"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName AI Audio Transcribe
;@Ahk2Exe-SetDescription Easily Transcribe Audio to Text using OpenAI
#Requires Autohotkey v2.0+
#SingleInstance
#include <readWriteCheck>
if !RWCheck(A_ScriptDir)
{
	Notify.Show({
		HDText: "ReadWrite Error:",
		BDText: "Script has no rights to Read/Write for the following folder`n" A_ScriptDir,
		GenDuration:0,
		GenLoc:'Center'
		})
	return
}


BasicSetup()

#Include <Notify\NotifyV2>
#Include <Preferences\Triggers>
#Include <OpenAI\OpenAI>
#include <FFmpeg\FFmpeg>
#include <ScriptObject\ScriptObject>
#include <Livemic>
#include <prefGui>
#include <ffmpeg Record>
; #include <FileExPro>

; triggers.SetOwner(LiveMic.UI.Hwnd)
TranscribeErrorLogPath := A_ScriptDir '\Transcribe Error Logs.txt'
OnError(LogandThrowError)

Notify.Default.HDText := 'AI Audio Transcribe'
script := {
	        base : ScriptObj(),
	        hwnd : triggers.UI.Hwnd,
	     version : "0.6.7",
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "2024-03-14",
	     moddate : "2024-08-28",
	   resfolder : A_ScriptDir '\res',
	    iconfile : 'res\main.ico' ,
	homepagetext : "the-automator.com/AiTranscribe",
	homepagelink : "the-automator.com/AiTranscribe?src=app",
	VideoLink 	 : "https://www.youtube.com/watch?v=e3xZG50pqAs",
	  	 DevPath : "S:\AI\AI Audio Transcribe\AI Audio Transcribe.ahk",
	  donateLink : ""
}
if !A_IsCompiled
	TraySetIcon(script.iconfile)

record_out_path := 'last_recording.ogg'
triggers.tray.add('Upload to Transcribe',PickFile2Transcribe)
triggers.AddHotkey(StartRecording,'Capture Audio','``')
triggers.SetDDL(StartRecording,['Mouse','Keyboard','Disable'])
; triggers.DisableModiers(StartRecording)

triggers.AddHotkey(toggleHotkey,'Toggle Recording Hotkey','#+r')
triggers.FinishMenu(,true)
triggers.tray.Add("About",(*) => Script.About())
triggers.tray.add('Open Folder',(*)=>Run(A_ScriptDir))
triggers.tray.SetIcon("Open Folder","shell32.dll",4)
triggers.tray.Add("Intro Video",(*) => Run(script.VideoLink))
triggers.tray.Add()
triggers.tray.Add('Exit',(*) => ExitApp())
; triggers.tray.AddStandard

triggers.save.onevent('click',Savesettings) ; Pref Gui save settings
;triggers.show()
trymiccheck := 0
if microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",0)
	try trymiccheck := SoundGetVolume(, microphoneName ) + 20 ; checking sound device available

if trymiccheck
	micddl.text := microphoneName
else
{
	triggers.Show()
	Notify.Show('Please Select Microphone')
	return
}

ffmpegLiveAudio.command := '"'  FFMPEG.path '" -y -f dshow -i audio="{}" -af acompressor=threshold=-20dB:ratio=4:attack=200:release=1000,highpass=f=200,lowpass=f=3000,afftdn=nf=-25,adeclick,adeclick,volume=5dB -acodec libopus -b:a 24k -ac 1 -application voip -ar 16000 "{}"'

if !OpenAI.Authenticate(apikey := IniRead( triggers.ini, A_ComputerName, "APIKey",''), '')
{
    Notify.Show({BDText: "OpenAI Authentication failed`nclick to change settings", GenDuration:0, GenLoc:'Center',GenCallback:(*)=>(Run('https://platform.openai.com/api-keys'),triggers.show())})
	; triggers.show()
	return
}

ffmpegRecording := ffmpegLiveAudio(microphoneName, record_out_path)
ffmpegRecording.Pause() ;  suspend ffmpeg run it in back ground to avoid delay

if startingHotkey := IniRead(triggers.ini, 'Hotkeys',StartRecording.name,'')
	Notify.Show({BDText:'Hold down  ' triggers.HKToString(startingHotkey) '  Key to start recording', GenDuration:5, GenLoc:'Center'} )

if !ffmpegVersion := FFMPEG.GetVersion() ; need feature-SectionBranch utill it is merged with the main branch
	Notify.Show({BDText: "FFMpeg failed to configure`nClick here to exit", GenDuration:0, GenLoc:'Center',GenCallback:(*)=>exitapp()})
return

toggleHotkey(*)
{
	static hkstatus := true
	if !DefaultHotkey := IniRead(triggers.ini, 'Hotkeys',StartRecording.name,'')
		return
	traylabel := triggers.actions[StartRecording.name]['tray']
	if hkstatus
		triggers.tray.disable(traylabel)
	else
		triggers.tray.enable(traylabel)
	hkstatus := !hkstatus
	onoff := (hkstatus ? 'On': 'Off')
	Hotkey(DefaultHotkey,StartRecording,onoff)

	Notify.CloseLast()
	Notify.Show( {BDText:'Turnned ' onoff ' recording Hotkey "' DefaultHotkey '"' , GenDuration:5, GenLoc:'Center',HDFontcolor:(hkstatus?'Green':'red') } )
}

StartRecording(*)
{
	global ffmpegRecording
	static ffmpegPath := FFMPEG.path ; GetFFMPEGPath()
	static recording := false
	static command := '"{}" -y -f dshow -i audio="{}" -af acompressor=threshold=-20dB:ratio=4:attack=200:release=1000,highpass=f=200,lowpass=f=3000,afftdn=nf=-25,adeclick,adeclick,volume=5dB -acodec libopus -b:a 24k -ac 1 -application voip -ar 16000 "{}"'

	if recording
		return

	if !OpenAI.Authenticate(apiedit.value)
	{
		Notify.Show({BDText: "OpenAI Authentication failed", GenDuration:0, GenLoc:'Center',GenCallback:(*)=>(Run('https://platform.openai.com/api-keys'),triggers.show())})
		return
	}

	microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",0)
	BuildMicMap()
	if !micmap.has(microphoneName) ; make sure have correct/available device name
	{
		scGui.Show()
		Notify.CloseLast()
		Notify.Show('Please Select Microphone')
		return
	}
	LiveMic.SetMic(microphoneName)
	LiveMic.Note.Value := 'Release ' triggers.HKToString(A_ThisHotkey) ' to stop recording'

	if !IsSet(ffmpegRecording)
	|| !ffmpegRecording
	{
		ffmpegRecording := ffmpegLiveAudio(microphoneName, record_out_path)
		ffmpegRecording.Pause()
	}
	ffmpegRecording.continue()
	Notify.CloseLast()

	recording := true
	LiveMic.show()
	StartTime := A_TickCount
	KeyWait RegExReplace(A_ThisHotkey, '[#^+!]*') ; is using modifier we are facing issue
	ElapsedTime := A_TickCount - StartTime
	if ElapsedTime < 1000
	{
		Notify.Show({BDText: "Recording should be longer than 1 Second`nHold down Hotkey down to record audio", GenDuration:2,GenLoc:'c',GenBGColor:'f36a6a'})
		sleep 600
		LiveMic.hide()
		recording := false
		ffmpegRecording.Pause()
		return
	}
	recording := false
	LiveMic.hide()
	Notify.CloseLast()

	StopRecording()
}

StopRecording(*)
{
	try
	{
		DetectHiddenWindows true
		while ProcessExist('ffmpeg.exe')
		{
			WinClose('ffmpeg.exe')
			ProcessWaitClose('ffmpeg.exe',5)
		}
	}

	if !FileExist(record_out_path)
	{
		Notify.Show({BDText: "There was a problem with the recording with ffmpeg", GenDuration:2,GenLoc:'c'})
		return
	}

	if !ProcessExist('ffmpeg.exe')
	{
		ffmpegRecording.start() ; restart recoding for next time
		ffmpegRecording.Pause() ; and pausing
		Notify.Show({BDText: "Submitting to Whisper", GenDuration:2})
		if !sz := FileGetSize(record_out_path)
		{
			Notify.Show({BDText: "There was problem with recording,`ncheck if your microphone is connected ", GenDuration:2,GenLoc:'c'})
			return
		}

		; audio clip length check
		Length := getClipLength()
		if Length < 1.2
		{
			Notify.Show({BDText: "Audio Clip should be longer than 1 Second", GenDuration:2,GenLoc:'c'})
			return
		}
		(OpenAI.authenticated ? Transcribe(record_out_path) : '')

	}
	else
		Notify.Show({BDText: "There was a problem closing the Recorder", GenDuration:2,GenLoc:'c'})
}

Transcribe(file_path)
{
	language := IniRead( triggers.ini, A_ComputerName, "Language",'English')
	languageCode := Format('{:L}',langsMap[language])
	try transcription := OpenAI.Audio.Transcription.create(file_path, 'whisper-1', languageCode)
	catch error as e
	{
		if  InStr(e.message,'insufficient_quota')
			Notify.Show({BDText: "insufficient funds, Please add credits to your AI account", GenDuration:2,GenLoc:'c'})
		else
			Notify.Show({BDText: "There was a problem with the transcription", GenDuration:2,GenLoc:'c'})
		LogERROR(e)
		return
	}

	IF !transcription.text ; != 200
	{
		Notify.Show({BDText: "There was a problem with the transcription", GenDuration:2,GenLoc:'c'})
		LogERROR(transcription)
		return
	}

	if TransClog
		LogTranscribe(transcription)

	Notify.Show({
		HDText: "Transcription on clipboard",
		BDText: SubStr(A_Clipboard := transcription.text, 1, 200) '...',
		GenDuration:5,
		GenLoc:'c'
	})
}

LogERROR(transcription)
{
	static logpath := a_scriptdir '\Transcribe Error Logs.txt'
	time := FormatTime(A_Now,'yyyy-MM-dd hh:mm tt')
	logdata := time ':`n' JSON.stringify(transcription,1) '`n`n'
	FileAppend(logdata,logpath,'utf-8')
	; hFile := FileOpen('last_transcription.txt','w', 'UTF-8')
	; hFile.Write(transcription)
	; hFile.Close()
}

LogTranscribe(transcription)
{
	static logpath := a_scriptdir '\Transcribe Logs.txt'
	time := FormatTime(A_Now,'yyyy-MM-dd hh:mm tt')
	logdata := time ':`t' transcription.text '`n`n'
	FileAppend(logdata,logpath,'utf-8')
	; hFile := FileOpen('last_transcription.txt','w', 'UTF-8')
	; hFile.Write(transcription)
	; hFile.Close()
}

PickFile2Transcribe(*)
{
	filter := "Audio/Video Files (*.mp3; *.wav; *.ogg; *.flac; *.m4a; *.aac; *.wma; *.mp4; *.avi; *.mov; *.wmv; *.mkv; *.flv)"

	if !path := FileSelect('1',,'Select file to Transcribe',filter)
	{
		return
	}
	language := IniRead( triggers.ini, A_ComputerName, "Language",'English')
	languageCode := Format('{:L}',langsMap[language])

	if !file_path := GetOGG(path)
		return

	Transcribe(file_path)
}

GetOGG(path)
{
	SplitPath(path,,&dir,,&name)
	temp := A_ScriptDir '\temp'
	DirCreate(temp)
	return FFMPEG.VideoToAudio(path)
}

BasicSetup()
{
	DirCreate 'res'
	DirCreate 'lib\ext'

	switch A_PtrSize
	{
	case 4:
		try FileInstall 'lib\OpenAI\lib\JSON\lib\ahk-json\ahk-json32.dll', 'lib\ext\ahk-json.dll', true
	case 8:
		try FileInstall 'lib\OpenAI\lib\JSON\lib\ahk-json\ahk-json64.dll', 'lib\ext\ahk-json.dll', true
	}

	FileInstall 'res\main.ico', 'res\main.ico', true
	FileInstall 'res\crosshair.png', 'res\crosshair.png', true
	FileInstall 'res\crosshairbg.png', 'res\crosshairbg.png', true
}

getClipLength()
{
	; Length := Trim(FileExPro(A_ScriptDir '\' record_out_path,'Length'))
	Length := FFMPEG.Getinfo(A_ScriptDir '\' record_out_path)['Length']
	time := StrSplit(Length, ":")
	return seconds := (time[1]*3600) + (time[2]*60) + Floor(time[3])
}

LogandThrowError(exception, Mode)
{
	FileAppend( FormatTime(a_now,'yyyy-MM-dd hh:mm tt') ':`t'  exception.Line  "`n`t" exception.Message  "`n`n", TranscribeErrorLogPath)
	throw exception
}