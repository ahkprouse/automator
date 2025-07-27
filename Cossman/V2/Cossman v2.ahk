/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-automator                                                  *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
 * @description                                                                *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
;@Ahk2Exe-SetVersion     "0.0.1"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 
#Requires Autohotkey v2.0+
#SingleInstance
#include <NotifyV2>
#Include <ScriptObject>

script := {
	base 	     : ScriptObj(),
	version      : "0.0.1",
	hwnd     	 : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "",
	moddate      : "",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\Cossman.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "Cossman",
	homepagelink : "the-automator.com/CossmanSpy?src=app",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

FilePath := A_ScriptDir "\Cossman Billboards.txt" ; You can make it relative to the script path
tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

quotes := StrSplit(FileRead(FilePath, 'utf-8'), '`n') ;Create an array of quotes based on line break
AppsKey & b::
Browser_Back::
{
	rnd_line := Random(1, quotes.Length) ;Select a random line
	BDT := A_Clipboard := quotes[rnd_line]
	
	Notify.Show({BDText:BDT,BDFontSize:'15',HDText:'Cossman Quote:',HDFontSize:'18',GenIcon:'Exclamation',GenDuration:5}) ; Notify with Icon, Body Text and Header
}