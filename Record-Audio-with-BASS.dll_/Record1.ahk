;*******************************************************
; Get this file,and the BASS.DLL files here:  https://the-Automator.com/BASS
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
; https://www.autohotkey.com/boards/viewtopic.php?t=34352
; Official site for the library  https://www.un4seen.com/
#SingleInstance,Force
SetBatchLines,-1
FileName:="Joe1" . ".wav" ; mp3,wav,ogg,aiff
RunWith(32) ;force to start in 32 bit mode
BASSDLLPath:=A_ScriptDir "\bass.dll" ;"\x64\bass.dll"

Gui,Add,Button,x12 y9  w100 h30 gStartRecord,&Start
Gui,Add,Button,x12 y39 w100 h30 gStopRecord,S&top
Gui,Show,w230 h79,BASS.dll
return

StartRecord:
Control,Disable,,&Start
FileDelete,% FileName
RecordCallback := RegisterCallback("RecordFunction" )
;//// WRITE WAV HEADER /////
file := fileopen(FileName,"rw",CP1252)
file.write("RIFF    ") ; leave space for file size - 8
file.write("WAVEfmt ") ; Wave Container,'fmt ' chunk,this takes up 8 bytes.
file.WriteUInt(16)

numput(1,fmt_type:=0,"UShort") ; format,1 = PCM,linear aka non compressed
file.rawwrite(fmt_type,2)

numput(2,fmt_channels:=0,"UShort") ; 2 channels
file.rawwrite(fmt_channels,2)
file.WriteUInt(44100)  ; 44100 samples per second
file.WriteUInt(176400)  ; bytes per second,176400

numput(4,fmt_blockalign:=0,"UShort") ; NumChannels * BitsPerSample/8
file.rawwrite(fmt_blockalign,2)

numput(16,fmt_bitspersample:=0,"UShort") ; 16 bit resolution;
file.rawwrite(fmt_bitspersample,2)
file.write("data    ") ; this takes up 8 bytes. leave space to write in the size of data chunk.
datasize = 0

;////// WAV HEADER COMPLETE,MOSTLY ///////
;////// LOAD BASS AND START RECORDING  /////////
DllCall("LoadLibrary","str",BASSDLLPath) 
DllCall(BASSDLLPath "\BASS_RecordInit",Int,-1)
DllCall(BASSDLLPath "\BASS_ErrorGetCode")
hrecord := DllCall(BASSDLLPath "\BASS_RecordStart",UInt,44100,UInt,2,UInt,0,UInt,RecordCallback,UInt,0)
return

!t:: ;Alt+t to stop
StopRecord:
DllCall(BASSDLLPath "\BASS_ChannelStop",UInt,hrecord)
file.seek(40) ;///// BACK TO HEADER //////
data_datasize=0
numput(datasize,data_datasize,"UInt") ; little endian
file.rawwrite(data_datasize,4)
datasize+=36
file.seek(4)
riff_size=0
numput(datasize,riff_size,"UInt") ; little endian
file.rawwrite(riff_size,4)
run,% FileName
ExitApp ;///// DONE ///////
return

RecordFunction(handle,buffer,length,user){
	global file
	global datasize
	file.rawwrite(buffer+0,length)
	datasize += length	
	return true
}

GuiClose:
ExitApp
return


;********************Force the bitness with RunWith***********************************
;~ runWith(32) ;force to start in 32 bit mode
;~ MsgBox % A_PtrSize
runWith(version){	
	if (A_PtrSize=(version=32?4:8)) ;For 32 set to 4 otherwise 8 for 64 bit
		Return
	
	SplitPath,A_AhkPath,,ahkDir ;get directory of AutoHotkey executable
	if (!FileExist(correct := ahkDir "\AutoHotkeyU" version ".exe")){
		MsgBox,0x10,"Error",% "Couldn't find the " version " bit Unicode version of Autohotkey in:`n" correct
		ExitApp
	}
	Run,"%correct%" "%A_ScriptName%",%A_ScriptDir%
	ExitApp
}