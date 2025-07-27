;~ #Include <default_Settings>
;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;the-Automator.com/Base64IMG
;*******************************************************
;*********Encode picture*****************************
FilePath:="B:\Progs\AutoHotkey_L\AHK Work\Base64-Images\proj\xmas.gif"
Base64Text:=Base64Enc(FilePath)
BreakForStoreAsVar(100,"xmas",Base64Text)
;~ DebugWindow(Base64Text,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
return

Base64Enc(File) { ; By SKAN / 18-Aug-2017 https://www.autohotkey.com/boards/viewtopic.php?t=35964
	Local Rqd := 0, B64, B := "", N := 0 - LineLength + 1  ; CRYPT_STRING_BASE64 := 0x1
	FileGetSize,nBytes,%File%
	FileRead,Bin,*c %File%
	DllCall("Crypt32.dll\CryptBinaryToString","Ptr",&Bin ,"UInt",nBytes,"UInt",0x1,"Ptr",0,   "UIntP",Rqd )
	VarSetCapacity( B64, Rqd * ( A_Isunicode ? 2 : 1 ), 0 )
	DllCall("Crypt32.dll\CryptBinaryToString","Ptr",&Bin, "UInt",nBytes,"UInt",0x1,"Str",B64, "UIntP",Rqd )
	B64:=StrReplace(B64,"`r`n")
	return RTrim(B64,"`n")
}

BreakForStoreAsVar(MaxChars="16000",VarName="img",img64=""){
	If(MaxChars>16000){
		MsgBox there is a maximum of 16,000 characters.  Please try again
		return
	}
	pos:=0	
	Loop % StrLen(img64) / MaxChars +1 {
		NewStr .= VarName ".=""" SubStr(img64,A_Index+Pos,MaxChars) """`n"
		Pos+=MaxChars-1
	}
	Clipboard:=NewStr ;Shove into clipboard as you'll need this in your script
	DebugWindow(NewStr,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
}




