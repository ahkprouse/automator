;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;  Get the original code and examples here:  https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4635
;*******************************************************
#SingleInstance, Force
#NoEnv

;~ RAlt::
;~ Browser_Forward::Reload
;~ RControl::
;~ Browser_Back::

;~  TaskDialog(hParent = 0, sText = "", sButtons = "", iFlags = 0, sIcons = "", sRadios = "", sCallback = "", iWidth = 0, hNavigate = 0)
;~  TaskDialog("This is my window title|This is my main instruction", "Extra" ,"Title"    ,"Yes,No",,,400,Time_Out)

Time_Out:=3  ;set to zero for none
gosub Adjust_Widths
gosub Various_Buttons
gosub Builtin_Icons
gosub Backgrounds
gosub Custom_Icons
return
;*******************************************************
Adjust_Widths:
;**********************adjusting width*********************************
loop, 5{
Width:=350+(A_Index*100)
TaskDialog("Main: A_Index="A_Index, "Extra: Width=" Width,"Title: Ajusting Width",  , ,Width,,Time_Out)
}
return

;*******************************************************
Various_Buttons:
;**********************buttons*********************************
TaskDialog("Main: Words for buttons", "Extra: Showing all buttons possible"        ,"Title: Buttons-using text"    ,"Yes,No,Cancel,Retry,Close",,,400,Time_Out)
TaskDialog("Main: Yes=1, No=4, Cancel=8, Retry=16, Close=32", "Extra: 1+4=5"       ,"Title: Buttons-using addition",                          5,,,400,Time_Out)
TaskDialog("Main: Yes=1, No=4, Cancel=8, Retry=16, Close=32", "Extra: 1+4+8=13"    ,"Title: Buttons-using addition",                         13,,,400,Time_Out)
TaskDialog("Main: Yes=1, No=4, Cancel=8, Retry=16, Close=32", "Extra: 1+4+8+32=45" ,"Title: Buttons-using addition",                         45,,,400,Time_Out)
return

;*******************************************************
Builtin_Icons:
;**********************Icons*********************************
Loop, 4
	TaskDialog("Main: WARN=1, ERROR=2, INFO=3, ", "Extra: A_Index=" A_Index      ,"Title: Main Icons",1,A_Index,,400,Time_Out)

TaskDialog("Main: Question needs the string with quotes ", "Extra: ""Question""" ,"Title: Main Icons",1,"Question",,400,Time_Out)
return

;*******************************************************
Backgrounds:
;*******************************************************
Main :="Main from "  A_ThisLabel , Title:="Title from " A_ThisLabel , Extra:="Extra from " A_ThisLabel
TaskDialog(Main,Extra,Title ,, "Blue"  ,400,HGUI,Time_Out)
TaskDialog(Main,Extra,Title ,, "Yellow",450,HGUI,Time_Out)
TaskDialog(Main,Extra,Title ,, "Red"   ,500,HGUI,Time_Out)
TaskDialog(Main,Extra,Title ,, "Green" ,550,HGUI,Time_Out)
TaskDialog(Main,Extra,Title ,, "Gray"  ,600,HGUI,Time_Out)
return

Custom_Icons:
Main :="Main from "  A_ThisLabel , Title:="Title from " A_ThisLabel , Extra:="Extra from " A_ThisLabel
;~  LoadIcon("H:\Progs\SPSS13\spsswin.exe",1,0)

;~TaskDialog(Main, Extra, Title,, LoadIcon(A_WinDir "\explorer.exe",1,0)) ; first icon, small icon
TaskDialog(Main, Extra, Title,, LoadIcon(A_WinDir "\explorer.exe",1,1),,,Time_Out) ; first icon, large icon
TaskDialog(Main, Extra, Title,, LoadIcon(A_WinDir "\explorer.exe",2,0),,,Time_Out) ; Second icon, small icon
TaskDialog(Main, Extra, Title,, LoadIcon(A_WinDir "\explorer.exe",3,1),,,Time_Out) ; Third icon, large icon
TaskDialog(Main, Extra, Title,, LoadIcon("C:\Program Files (x86)\DVD Flick\dvdflick.exe",1,1), 1,,Time_Out) ;you can put in your own programs too...
TaskDialog(Main, Extra, Title,, LoadIcon("C:\Program Files (x86)\Dropbox\Client\Dropbox.exe",1,1),1,,Time_Out) ;you can put in your own programs too...

LoadIcon(FullFilePath, IconNumber := 1, LargeIcon := 1) {
	;~ --Proived by "just me"  http://ahkscript.org/boards/viewtopic.php?f=6&t=4635&start=40#p32968  ;
   HIL := IL_Create(1, 1, !!LargeIcon)
   IL_Add(HIL, FullFilePath, IconNumber)
   HICON := DllCall("Comctl32.dll\ImageList_GetIcon", "Ptr", HIL, "Int", 0, "UInt", 0, "UPtr")
   IL_Destroy(HIL)
   Return HICON
}

