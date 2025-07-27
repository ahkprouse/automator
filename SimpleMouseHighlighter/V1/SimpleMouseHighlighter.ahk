;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************
;************Borrowed and tweaked from Juho Lee  https://youtu.be/hdoA8pH3yy4 
; We added a hotkey to toggle the circle.  Currently it is Control+M on line 22 below
CircleSize :=75 ;30 to 150 good range
CircleTransparency :=200 ;0-255
CircleColor :="green" ;"cFFFF00" ;names of 16 primary colors AHK Understands https://www.autohotkey.com/docs/commands/Progress.htm#colors
xCenterMouseAdj:=3
yCenterMouseAdj:=1

Menu, Tray, Icon , % A_ScriptDir "\res\YellowCircle.ico"
#SingleInstance, Force
SetWinDelay, -1
CoordMode,Mouse, Screen
Gui, -Caption +Hwndhwnd +AlwaysOnTop +ToolWindow +E0x20
Gui, Color, % CircleColor ; green ;hex code yellow
return 

^m:: ;Control+m will toggle the circle around the mouse
if (toggle:=!toggle){
	Gui, Show, x0 y-%CircleSize% w%CircleSize% h%CircleSize% NA, ahk_id %hwnd%
	WinSet, Transparent,%CircleTransparency%, ahk_id %hwnd%
	WinSet, Region, 0-0 w%CircleSize% h%CircleSize% E, ahk_id %hwnd%
	SetTimer, Circle, 10
}else {
	Gui, Hide
	SetTimer, Circle, OFF
}
return

Circle:
MouseGetpos, X, Y
X -= CircleSize / 2 - xCenterMouseAdj
Y -= CircleSize / 2 - yCenterMouseAdj
WinMove, ahk_id %hwnd% ,, %X%, %Y%
WinSet, AlwaysOnTop, On, ahk_id %hwnd%
return