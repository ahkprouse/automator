#Requires Autohotkey v1.1.36+
;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

;~ OutputWindow("test`nme",1)
OutputWindow(Text,clear:=1){
	WinGetTitle, ActiveWindow, A
	If InStr(ActiveWindow,"AHK Studio")
		DebugWindow(Text,Clear,LineBreak:=1,Sleep:=500,AutoHide:=0)
	Else if InStr(ActiveWindow,"Visual Studio Code")
		OutputDebug, % Text
	Else if InStr(ActiveWindow,"SciTE")
		SciTE_Output(text,clear)
	Else
		Resizable_GUI(Text,600,300,1)
}

DebugWindow(Text,Clear:=0,LineBreak:=0,Sleep:=0,AutoHide:=0,MsgBox:=0){
	x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}"),x.DebugWindow(Text,Clear,LineBreak,Sleep,AutoHide,MsgBox)
}

SciTE_Output(Text,Clear=1,LineBreak=1,Exit=0){
	SciObj := ComObjActive("SciTE4AHK.Application") ;get pointer to active SciTE window
	IfEqual,Clear,1,SciObj.Message(0x111,420) ;If clear=1 Clear output window
	Sleep, 500
	IfEqual, LineBreak,1,SetEnv,Text,`r`n%text% ;If LineBreak=1 prepend text with `r`n
	SciObj.Output(Text) ;send text to SciTE output pane
	IfEqual, Exit,1,MsgBox, 36, Exit App?, Exit Application? ;If Exit=1 ask if want to exit application
	IfMsgBox,Yes, ExitApp ;If Msgbox=yes then Exit the appliciation
}

Resizable_GUI(text,x:=600,y:=300,eta:=false){
	static EditWindow ;Set this as static so it is "sticky" 
	static exitTheApp ;Needs to be declared on its own because it runs before variables have values
	
	exitTheApp := eta ;make sure this is done after you've declared it above as a static variable
	Gui,12:Destroy
	Gui,12:Default
	Gui,+Resize
	Gui,Font,s12 cBlue q5, Courier New
	Gui,Add,Edit,w%x% h%y% -Wrap HScroll hwndEditWindow ;,%text%	 ;I used to use this approach however ran into random errror loading the control
	Gui,Show
	GuiControl,,%EditWindow%,%text% ;Populate edit control after creating.  Had weird issue when loading it on edit line above
	return
	
	;********************Resizing***********************************
	12GuiSize:
	GuiControl,12:Move,%EditWindow%,% "w" A_GuiWidth-30 " h" A_GuiHeight-25
	return
	;********************Exit /Escape and closing the app***********************************
	12GuiEscape:
	12GuiClose:
	Gui,12:Destroy
	if exitTheApp
		ExitApp
	return
}