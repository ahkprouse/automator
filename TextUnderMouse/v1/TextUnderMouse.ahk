;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover  *
;******************************************************************************
;~ #Include <default_Settings>
#Include <UIA_Interface>
#Include <Resizable_GUI>
#SingleInstance,Force
^g::
uia := UIA_Interface()
	;~ if GetKeyState("LButton") {
Element := uia.ElementFromPoint()

for each, value in [30093,30092,30045] { ; lvalue,lname,value
	r := Element.GetCurrentPropertyValue(value)
}
until r != "" 

if (r = "")
	r := Element.CurrentName
clipboard:=4
Resizable_GUI(r,600,400,false)
return



for each, value in [30093,30092,30045] { ; lvalue,lname,value
			r := Element.GetCurrentPropertyValue(value)
		}
		until r != "" 

		if (r = "")
			r := Element.CurrentName

		Tooltip % r=""? "<No Text Found>" : "Copied: " clipboard:=r
		SetTimer, ToolTipOff, -1500
	;~ }
	;~ else
		;~ Send ^ 
	return

ToolTipOff:
	ToolTip
	return


; http://www.autohotkey.com/board/topic/94619-ahk-l-screen-reader-a-tool-to-get-text-anywhere/#entry596215