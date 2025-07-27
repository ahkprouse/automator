#SingleInstance
#Requires AutoHotkey v2.0+ 32-Bit

#Include <ScreenClip>
#Include <SetCueBanner>

#Include <guis\Main>

rootFolder := 'res\imgs'
winTitle := 'Inventory.xlsx'

DirCreate rootFolder

if !WinExist(winTitle)
{
	MsgBox('Please open Inventory.xlsx', 'Error','IconX OK')
	ExitApp
}

xl := ComObjActive("Excel.Application")
#LButton::
{
	oldMode := A_CoordModeMouse
	CoordMode 'Mouse', 'Screen'

	sc_area := Gui('-Caption +AlwaysOnTop')
	sc_area.BackColor := '0x000088'
	WinSetTransparent 100, sc_area

	MouseGetPos &x1, &y1
	sc_area.Show('x' x1 ' y' y1 ' w1 h1 NoActivate')
	while GetKeyState('LButton', 'P')
	{
		MouseGetPos &x2, &y2
		sc_area.Move(,, x2-x1, y2-y1)
		Sleep 10
	}

	sc_area.Destroy()

	region := {x:x1, y:y1, w:x2-x1, h:y2-y1}
	img := ScreenShot.Capture(region)
	if !main.id
		main.Show()

	img.Save(rootFolder '\' main.id '-' lv.GetCount()+1 '.png')
	pic.value := img.Path
	lv.Add('', img.Path)
	CoordMode 'Mouse', oldMode
}