#Requires AutoHotkey v2.0
/**
 * ============================================================================ *
 * @Author   : Xeo786                                                           *
 * @Homepage : the-automator.com                                                *
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
;--
#SingleInstance
#Requires Autohotkey v2.0+
#include .\..\Scintilla_Interface.ahk

g := Gui('+resize')
sci := SCIahk(g)

sfile := A_ScriptFullPath
Sci.AddScintilla("vMyScintilla w1000 h500 DefaultOpt DefaultTheme",sfile) ; create control and apply all required settings to sfile if provided
; Sci.Open(sfile) ; if sfile is provided later it will apply required settings only for first sfile 
g.Show()
sci.SetCurPos() ; set position to start