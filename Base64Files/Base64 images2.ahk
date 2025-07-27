;~ #Include <default_Settings>
;*******************************************************
;the-Automator.com/Base64IMG
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
;**************************************
text:=Base64Enc("B:\Progs\AutoHotkey_L\AHK Work\Base64-Images\proj\xmas.gif")
DebugWindow(Text,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
MsgBox % text

EncodeWriteRead("xmas.gif") ;calls the function with xmas.gif as the paramater
EncodeWriteRead(FileName){
	SplitPath,FileName,oName,,,oNameNoExt ;get the file name w/o extension
	; I cover iniRead/Write in the Intermediate AutoHotkey course https://the-Automator.com/IntermediateAHK 
	IniWrite,% Base64Enc(FileName),images.txt,Images,%oNameNoExt% ;write content to ini file
	IniRead,Base64,images.txt,Images,%oNameNoExt% ;Read content from ini file
	DebugWindow(Base64,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
}

return
Base64Enc(File) { ; By SKAN / 18-Aug-2017 https://www.autohotkey.com/boards/viewtopic.php?t=35964
	Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1
	FileGetSize,nBytes,%File%
	FileRead,Bin,*c %File%
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin ,"UInt",nBytes, "UInt",0x1, "Ptr",0,   "UIntP",Rqd )
	VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
	DllCall( "Crypt32.dll\CryptBinaryToString", "Ptr",&Bin, "UInt",nBytes, "UInt",0x1, "Str",B64, "UIntP",Rqd )
	B64:=StrReplace(B64,"`r`n")
	return RTrim(B64,"`n")
}



return


