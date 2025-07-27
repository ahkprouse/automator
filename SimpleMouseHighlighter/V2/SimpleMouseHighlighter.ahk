/**
 * ============================================================================ *
 * @Author   : Rizwan                                                          *
 * @Homepage : the-automator.com                                               *
 *                                                                             *
 * @Created  : Dec 04, 2024                                                    *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/
;@Ahk2Exe-SetVersion     0.0.1
; @ Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Simple Mouse Highlighter
; @ Ahk2Exe-SetDescription Simple Mouse Highlighter
;--
#SingleInstance
#Requires Autohotkey v2.0+
Persistent
#include <ScriptObject>
TraySetIcon(A_ScriptDir "\res\YellowCircle.ico")
script := {
	        base : ScriptObj(),
	     version : "0.0.1",
	        hwnd : 0,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	   resfolder : A_ScriptDir "\res",
	    ; iconfile : 'res\ocr2.ico' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	         ini : A_ScriptDir "\settings.ini",
	homepagetext : "Power Plan Swapper",
	homepagelink : "the-Automator.com/Simple Mouse Highlighter?src=app",
    VideoLink    : "",
    DevPath      : "",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

MouseColour := ['Yellow','Green','Red','Blue','Black','White']
ini := script.ini
Num := IniRead(ini,'Colour','Num',1)
circleColor := MouseColour[Num] ; IniRead(ini,'Colour','Colr','green')
circleSize := iniRead(ini,'Size','w',50)
circleSize := IniRead(ini,'Size','h',50)
circleTransparency := IniRead(ini,'Transparent','Trasn',160)

; Set up tray menu
A_TrayMenu.Delete()  ; Clear the default menu
; A_TrayMenu.Add("Mouse Circle Tool", (*) => {})
; A_TrayMenu.Add()  ; Add separator

A_TrayMenu.Add()
A_TrayMenu.Add("Esc - Toggle Circle", (*) => ToggleCircle())
A_TrayMenu.Add()
A_TrayMenu.Add("Ctrl + Plus - Increase Size", (*) => IncreaseSize())
A_TrayMenu.Add("Ctrl + Minus - Decrease Size", (*) => DecreaseSize())
A_TrayMenu.Add()
A_TrayMenu.Add("Ctrl + Shift + Plus - Increase Transparency", (*) => Increase_Trasnpernt())
A_TrayMenu.Add("Ctrl + Shift + Minus - Decrease Transparency", (*) => Decrease_Trasnpernt())
A_TrayMenu.Add()
A_TrayMenu.Add("Ctrl + Shift + C - Change Colour", (*) => ChangeColour())
A_TrayMenu.Add()
A_TrayMenu.Add("Ctrl + Esc - Exit", (*) => ExitApp())
A_TrayMenu.Add()  ; Add separator
A_TrayMenu.add('Open Folder',(*)=>Run(A_ScriptDir))
A_TrayMenu.SetIcon("Open Folder","shell32.dll",4)
A_TrayMenu.Add("Intro Video",(*) => Run(script.VideoLink))
A_TrayMenu.SetIcon("Intro Video","imageres.dll", 19)
A_TrayMenu.Add("About",(*) => Script.About())
A_TrayMenu.Add("Exit", (*) => ExitApp())

; Global variables
/*
circleSize := 50  ; 30 to 150 good range
circleTransparency := 160  ; 0-255
circleColor := "green"  ; "cFFFF00" ; names of 16 primary colors AHK Understands
*/
xCenterMouseAdj := 3
yCenterMouseAdj := 1

; Coordinate settings
CoordMode("Mouse", "Screen")

; GUI Setup
myGui := Gui("-Caption +AlwaysOnTop +ToolWindow +E0x20")
myGui.BackColor := circleColor
hwnd := myGui.Hwnd

; Initialize toggle state
toggle := 1

Draw(toggle,circleTransparency := 160) {
    if (toggle) {
        try {
            myGui.Show(Format("x0 y-{1} w{1} h{1} NA", circleSize))
            WinSetTransparent(circleTransparency, "ahk_id " hwnd)
            WinSetRegion("0-0 w" circleSize " h" circleSize " E", "ahk_id " hwnd)
            ;===================ini write==========================
            IniWrite(circleSize,ini,'Size','w')
            IniWrite(circleSize,ini,'Size','h')
            IniWrite(circleTransparency,ini,'Transparent','Trasn')
            ;===================ini write==========================
            SetTimer(Circle, 5)
        }
    } else {
        SetTimer(Circle, false)  ; Stop the timer first
        try myGui.Hide()
    }
}

Circle() {
    static lastX := 0, lastY := 0  ; Store last known good coordinates
    
    try {
        if !WinExist("ahk_id " hwnd)
            return
        
        MouseGetPos(&X, &Y)
        X -= circleSize / 2 - xCenterMouseAdj
        Y -= circleSize / 2 - yCenterMouseAdj
        
        ; Only update if we have valid coordinates
        if (X != "" && Y != "") {
            lastX := X
            lastY := Y
            try {
                WinMove(X, Y, , , "ahk_id " hwnd)
                WinSetAlwaysOnTop(true, "ahk_id " hwnd)
            }
        }
    } catch as e {
        SetTimer(Circle, 0)  ; Stop the timer if we encounter an error
    }
}

; Initial draw
Draw(toggle,IniRead(ini,'Transparent','Trasn',160))

; Hotkeys

^NumpadAdd::IncreaseSize ; Added to use 10-key
^NumpadSub::DecreaseSize ; Added to use 10-key 

^=::IncreaseSize
^-::DecreaseSize
Escape::ToggleCircle
^Escape::ExitApp()

^+=::Increase_Trasnpernt
^+-::Decrease_Trasnpernt
^+c::ChangeColour

ChangeColour(*)
{   
    Static Num := IniRead(ini,'Colour','Num',1)
    Num++
    if Num > MouseColour.Length
        Num := 1

    Colours := MouseColour[Num]
    IniWrite(Num,ini,'Colour','Num')
    myGui.BackColor := Colours
}


Increase_Trasnpernt(*) {
    circleTransparency := IniRead(ini,'Transparent','Trasn',160)
    global circleTransparency += 10
    Draw(toggle,circleTransparency)
}

Decrease_Trasnpernt(*) {
    circleTransparency := IniRead(ini,'Transparent','Trasn',160)
    global circleTransparency -= 10
    Draw(toggle,circleTransparency)
}

IncreaseSize(*) {
    circleTransparency := IniRead(ini,'Transparent','Trasn',160)
    global circleSize += 10
    Draw(toggle,circleTransparency)
}

DecreaseSize(*) {
    circleTransparency := IniRead(ini,'Transparent','Trasn',160)
    global circleSize -= 10
    Draw(toggle,circleTransparency)
}

ToggleCircle(*) {
    circleTransparency := IniRead(ini,'Transparent','Trasn',160)
    global toggle := !toggle
    Sleep(100)
    Draw(toggle,circleTransparency)
}