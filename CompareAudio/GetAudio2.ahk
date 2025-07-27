;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#SingleInstance,Force
#Include C:\Users\Joe\DropBox\Progs\AutoHotkey_L\AHK Work\Audio Levels\VA.ahk
;~ https://www.autohotkey.com/board/topic/21984-vista-audio-control-functions
;~ https://www.autohotkey.com/board/topic/32434-microphone-peak-value-vista-audio-lexikos/
;********************You must be "capturing" the audio (Open Zoom, OBS,Voice Recorder,etc. )***********************************
LoopCount :=300 ;how many samples do you want to take?
One:=GetAudio(LoopCount) ;Perform first test
Two:=GetAudio(LoopCount) ;Perform second test
MsgBox % "Test 1: " One "`nTest 2: " Two

GetAudio(LoopCount){
	static Counter ;Keep track of how many times run test
	Counter++
	MsgBox % "Begin Test: " Counter
	peakMeter :=VA_GetAudioMeter("capture")
	Loop,% LoopCount {
		VA_IAudioMeterInformation_GetPeakValue(peakMeter,Peak)
		ToolTip % "Test: " Counter  "`nat " A_index " of " LoopCount "`nthe value was: " Round(Peak * 100,1)
		Sleep, 10 ;this is fast, but fine if not watching
		sum+=Peak ;Add each one to sum
	}
	;~ MsgBox % "For test: " Counter "`n`nThe average value was: " avg := (sum/LoopCount)*100
	return Avg:= round((sum/LoopCount)*100,1)	 ;calculate average *100 so more intuitive
}


;~ MsgBox % VA_GetVolume("Speakers")
;~ MsgBox % VA_GetMasterVolume(1)