#SingleInstance, force
;******************************************************************************
; Want a clear path for learning AutoHotkey GUIs                              *
; Take a look at our AutoHotkey Udemy GUI course at                           *
; https://the-automator.com/GUIs.                                             *
;******************************************************************************

gui, Add, Text, w100, % "Wage:"
gui, Add, Edit, w50 vWage gCalculate, 0
gui, Add, Text, w100, % "Hours Wasted:"
gui, Add, Edit, w50 vhWasted gCalculate, 0

gui, Add, Text, w200 vwpd, % "Wasted per Day:`t$0"
gui, Add, Text, w200 vwpw, % "Wasted per Week:`t$0"
gui, Add, Text, w200 vwpm, % "Wasted per Month:`t$0"
gui, Add, Text, w200 vwpy, % "Wasted per Year:`t$0"
gui show
return

Calculate(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	GuiControlGet, wage
	GuiControlGet, hWasted

	GuiControl,, wpd, % "Wasted per Day:`t$" mwDay := wage * hWasted
	GuiControl,, wpw, % "Wasted per Week:`t$" mwWeek := mwDay * 5
	GuiControl,, wpm, % "Wasted per Month:`t$" mwMonth := mwWeek * 4
	GuiControl,, wpy, % "Wasted per Year:`t$" mwYear := mwMonth * 12
	
}