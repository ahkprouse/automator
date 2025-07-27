;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Check out our GUIs are Easy course here:  https://the-Automator.com/GUIs
;Borrowed from here: https://www.autohotkey.com/boards/viewtopic.php?t=5841
;*******************************************************
#NoEnv
#SingleInstance force
RunWith(32) ;force to start in 32 bit mode
DLLPath:=A_ScriptDir "\USkin.dll" ;Location to the USkin.dll file
StylesPath:=A_ScriptDir "\styles\" ;location where you saved the .msstyles files
;*******************************************************

stylearray:=Object() ;create StyleArray to hold styles
Loop,% StylesPath "*.msstyles"
	stylearray.insert(A_LoopFilename)
total:= stylearray.MaxIndex() ;Get total number of styles
for key, value in stylearray {
	CurrentStyle:=value
	SkinForm(DLLPath,Apply, StylesPath . CurrentStyle)
	Gosub, Gui
	SkinForm(DLLPath,"0", StylesPath . CurrentStyle)	
}

SkinForm(DLLPath,Param1 = "Apply", SkinName = ""){
	if(Param1 = Apply){
		DllCall("LoadLibrary", str, DLLPath)
		DllCall(DLLPath . "\USkinInit", Int,0, Int,0, AStr, SkinName)
	}else if(Param1 = 0){
		DllCall(DLLPath . "\USkinExit")
	}
}

Gui:
Gui, add, button,xm w100 h40 gNext, Change Style
Gui, add, edit, xm y+20 w100 h20, Edit
Gui, add, listbox,xm y+20, ListBox
Gui, add, checkbox,xm y+20, checkbox
Gui, add, DDL, xm y+20, DropDownList||more1|more2
Gui, Show, w400, %CurrentStyle% - %key% of %total%
WinWaitClose,%CurrentStyle%
Return

Next:
Gui, Destroy
Return

OnExit, GetOut ;When exiting
;********************Close out***********************************
GetOut:
GuiClose:
Gui, Hide
SkinForm(0)
ExitApp
return

;****************https://the-Automator.com/RunWith*******************************
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