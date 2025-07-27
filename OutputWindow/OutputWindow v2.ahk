#Requires Autohotkey v2.0+
;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************

; OutputWindow('This is just a nice test')
; return

OutputWindow(Text, clear:=true)
{
	ActiveWindow := WinGetTitle('A')
	if InStr(ActiveWindow, "AHK Studio")
		DebugWindow(Text, clear, LineBreak := 1, Sleep := 500, AutoHide := 0)
	else if InStr(ActiveWindow, "Visual Studio Code")
		OutputDebug Text
	else if InStr(ActiveWindow, "SciTE")
		SciTE_Output(Text, clear)
	else
		Resizable_GUI(Text)
}

Resizable_GUI(text, w := 600, h := 300)
{
	static EditCtrl

	OutWin := Gui('+Resize')
	OutWin.OnEvent('Size', OutWinResize)
	OutWin.OnEvent('Close', (*) => OutWin.Destroy())
	OutWin.OnEvent('Escape', (*) => OutWin.Destroy())

	OutWin.SetFont('s12 cBlue q5', 'Courier New')

	EditCtrl := OutWin.AddEdit('w' w ' h' h ' -Wrap HScroll', text)
	OutWin.Show()
	; GuiControl,,%EditWindow%,%text% ;Populate edit control after creating.  Had weird issue when loading it on edit line above
	return

	;********************Resizing***********************************
	OutWinResize(GuiObj, MinMax, Width, Height) => EditCtrl.Move(, , Width - GuiObj.MarginX * 2, Height - GuiObj.MarginY * 2)
}

SciTE_Output(Text, Clear:=true, LineBreak:=true, Exit:=false)
{
	SciObj := ComObjActive("SciTE4AHK.Application") ;get pointer to active SciTE window
	if Clear
		SciObj.Message(0x111, 420)
	Sleep 500
	if LineBreak
		Text := '`r`n' Text ; prepend text with `r`n
	
	SciObj.Output(Text) ;send text to SciTE output pane
	if Exit && MsgBox('Exit App?', 'Exit Application?', 'Y/N Icon?') = 'Yes'
		ExitApp()
}

DebugWindow(Text, Clear:=false, LineBreak:=false, Sleep:=false, AutoHide:=false, MsgBox:=false)
{
	x := ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
	x.DebugWindow(Text, Clear, LineBreak, Sleep, AutoHide, MsgBox)
}
