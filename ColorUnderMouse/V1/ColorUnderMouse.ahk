;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover  *
;******************************************************************************
#SingleInstance, Force
#Requires Autohotkey v1.1.33+
;--
;@Ahk2Exe-SetVersion     0.2.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName ColorUnderMouse
;@Ahk2Exe-SetDescription Gets the current hex value of the pixel under the mouse
;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses. 
; They're structured in a way to make learning AHK EASY.
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover
;*******************************************************
;{#Includes
;#Include <ScriptObject\ScriptObject>

Menu, Tray, Icon, C:\WINDOWS\system32\shell32.dll,131 ;Set icon to colored butterfly
#Include, lib\m.ahk
 global script := {base          : script
                  ,name          : regexreplace(A_ScriptName, "\.\w+")
                  ,version       : "0.2.0"
                  ,author        : "Joe Glines"
                  ,email         : "joe.glines@the-automator.com"
                  ,crtdate       : "July 28, 2022"
                  ,moddate       : "July 28, 2022"
                  ,homepagetext  : ""
                  ,homepagelink  : ""
                  ,donateLink    : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
                  ,resfolder     : A_ScriptDir "\res"
                  ,iconfile      : A_ScriptDir "\res\main.ico"
                  ,configfile    : A_ScriptDir "\settings.ini"
                  ,VideoLink     : "https://www.youtube.com/watch?v=XUv6XUR_yg4"
                  ,DevPath       : "S:\ColorUnderMouse\V1\ColorUnderMouse.ahk"
                  ,configfolder  : A_ScriptDir ""}


try script.Update("https://raw.githubusercontent.com/RaptorX/ColorUnderMouse/devel/ver"
                 ,"https://github.com/RaptorX/ColorUnderMouse/releases/download/latest/ColorUnderMouse.zip")
Catch, err
	if err.code != 6 ; up to date
		MsgBox, % err.msg

;***********get color at position of mouse ; color under mouse*******************
#!c::  ; get color at current position of mouse
MouseGetPos,x,y
PixelGetColor,Color,%x%,%y%
Clipboard:=Format("#{:06X}",(color&255)<<16|color&65280|color>>16)
m("HTML:1","<span style='color:" Clipboard ";font-size:50'>" Clipboard "</span>","Y:"Y,"X:"X)
return
