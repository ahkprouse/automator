;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover  *
;******************************************************************************
/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
 
 Original TextUnderMouse by "nepter" http://www.autohotkey.com/board/topic/94619-ahk-l-screen-reader-a-tool-to-get-text-anywhere/#entry596215
 UIA by Descolada https://github.com/Descolada/UIA-v2
*/

ResizableGUI(Data,w:=900,h:=600,x := 0,y := 0,FontTheme := 'Courier New',Color := "Blue",Size := '14')
{
	static EditWindow := 0

	main := Gui('+Resize')
	main.OnEvent('Escape', (*)=> main.Destroy())
	main.OnEvent('Size', (GuiObj, MinMax, Width, Height)=> main['Data'].Move(,, Width-30, Height-25))

	if (FontTheme = "0")
		main.SetFont('s12 cBlue q5', 'Courier New')
	else
		main.SetFont('s' Size ' c' Color ' q5', FontTheme)

	main.AddEdit('vData +Wrap', data)

	if (x = "0") and (y = "0")
		main.Show('w ' w ' h' h)
	else
		main.Show('w ' w ' h' h ' x' x  ' y' y )
	return
}