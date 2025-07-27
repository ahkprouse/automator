#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, Force
RAlt::
Browser_Forward::Reload
~RControl::
Browser_Back::



;~ #Include TaskDialog.ahk

;~ HICON := LoadIcon("Shell32.dll", 12) ;change number here
;~ HICON := LoadIcon("B:\Progs\Icons\alpha\b.ico") ;change number here
;~ HICON := LoadIcon("B:\Progs\Icons\progs\spss.ico",1) ;change number here
HICON := LoadIcon("H:\Progs\SPSS 13\spsswin.exe",2) ;change number here
Main  := "This is the main instruction."
Extra := "This is the content text providing extra informations."
Title := "Custom Icon"
;~ TaskDialog(Main, Extra, Title,     , HICON)
TaskDialog(Main, Extra, Title,     , LoadIcon("H:\Progs\SPSS 13\spsswin.exe",1,0))
;~ TaskDialog(Main, Extra,      , 0x3F, , , HGUI)



LoadIcon(FullFilePath, IconNumber := 1, LargeIcon := 1) {
   HIL := IL_Create(1, 1, !!LargeIcon)
   IL_Add(HIL, FullFilePath, IconNumber)
   HICON := DllCall("Comctl32.dll\ImageList_GetIcon", "Ptr", HIL, "Int", 0, "UInt", 0, "UPtr")
   IL_Destroy(HIL)
   Return HICON
}