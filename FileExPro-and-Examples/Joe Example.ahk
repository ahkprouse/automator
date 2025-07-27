;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
; Get this script and all others shared in this video here:  https://the-Automator.com/FileExpro
;*******************************************************
#Include B:\Progs\AutoHotkey_L\AHK Work\FileXPro\Filexpro.ahk
FileRead,Params,Properties.txt ;List of 1,317 properties provided by SKAN.
;~ DebugWindow(params,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
;~ m("pause")
Par:=[] ;Create array for storage
;*********Use For loop over Var going line by line*********************
for i, Param in Loopobj:=StrSplit(Params,"`n","`r`n") { ;Parse Var on each new line
	Par.push(Param) ;push each one into Params array
}

;~ DebugWindow(Obj2String(Par),1,1,200,0)
;~ MsgBox Show Array
;********************Now use the FileExppro function***********************************
Obj :=Filexpro(A_WinDir "\Media\chimes.wav",,Par* ) ;Call function and pas Par array shoving everyhting into Obj
;~ DebugWindow(Obj2String(Obj),1,1,200,0)
;DebugWindow(ExploreObj(Obj),1,1,200,0)
;dmp(obj)
;~ MsgBox Pause
HasValue:={}
for k, v in Obj{
	if v 
		HasValue[k]:=v
}
DebugWindow(ExploreObj(HasValue),1,1,200,0)
return
