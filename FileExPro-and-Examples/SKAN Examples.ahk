;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
; Get this script and all others shared in this video here:  https://the-Automator.com/FileExpro
;*******************************************************
#Include <default_Settings>
#Include C:\Users\Joe\DropBox\Progs\AutoHotkey_L\AHK Work\FileXPro\Filexpro.ahk
;********************Example 1***********************************
Obj := Filexpro( A_AhkPath,, "System.FileFRN" )
DriveGet, Serial, Serial, % SubStr(A_AhkPath,1,2)
MsgBox % Format( "{:08X}-{:016X}", Serial, obj["System.FileFRN"] ) ; File ID
return

;********************Example 2***********************************
Obj := Filexpro(A_WinDir . "\Media\chimes.wav",, "System.Audio.ChannelCount" 
                                               , "System.Audio.Compression"                  	
                                               , "System.Audio.EncodingBitrate"              	
                                               , "System.Audio.Format"                       	
                                               , "System.Audio.IsVariableBitRate"            	
                                               , "System.Audio.PeakValue"                    	
                                               , "System.Audio.SampleRate"                   	
                                               , "System.Audio.SampleSize"                   	
                                               , "System.Audio.StreamName"                   	
                                               , "System.Audio.StreamNumber" )                 	
MsgBox % obj.System.Audio.EncodingBitrate
DebugWindow(Obj2String(Obj),1,1,200,0)
MsgBox % obj["System.Audio.EncodingBitrate"]
MsgBox Pause

return
;********************Example 3***********************************
Props := ["Path","Copyright","File description","File version","Language","Product name","Product version" ] ;store in an array

Loop, Files, %A_AhkPath%\..\*.*
{
	Obj := Filexpro( A_LoopFileLongPath,"Program", Props* ) ;pass array in variadiac param
	
	If ( IsObject(Obj)= 0 )
		Continue
	
	L := ""
	For Key, Val in Obj
		L .= Key A_Tab Val "`n"
	
	MsgBox, 0, %A_LoopFileName%,  %L%        
}