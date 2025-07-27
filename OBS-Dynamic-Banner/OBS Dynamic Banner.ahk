/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-15-May                                                    *
 * @modified    2025-15-May                                                    *
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
;@Ahk2Exe-SetVersion     "0.0.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0 ; Prefer 64-Bit
#SingleInstance Force
#Include <\Scintilla\SciAHK>
#Include <ScriptObject>


script := {
	        base : ScriptObj(),
	     version : "0.0.1",
	        hwnd : 0,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "May 05 2025",
	     moddate : "May 05 2025",
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	      config : A_ScriptDir "\settings.ini",
	homepagetext : "OBS Dynamic Banner",
	homepagelink : "the-automator.com/OBSDynamicBanner?src=app",
		DevPath	 : "S:\OBS Dynamic Banner\V2\OBS Dynamic Banner.ahk",
	  donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

TraySetIcon('C:\Windows\system32\shell32.dll',39)
fPath := "ObsTEXTBanner.txt" ;Path to file.  Remember to add it in OBS

SetInitialBannerValue() ;Set initial Greeting
WinTitle:="Hit enter to set text"
main := Gui("+LastFound", WinTitle) ;Set title
main.Add("Button", "vResetButton y+7 w80", "Reset Day").OnEvent("Click", (*) => SetInitialBannerValue())
sci := Scintilla.AddScintilla(main, 'x+m y1 w600  r2 DefaultOpt DefaultTheme')
sci.zoom := 8 ;Make text larger

;***********Hotkeys*******************
Browser_Home::setMainText()
#HotIf WinActive(main)
Enter::
NumpadEnter::SetFile()
#HotIf

;***********Write to file*******************
SetFile() {
	main.Submit()
	hFile := FileOpen(fPath, "w-")
	hFile.Write(" " sci.GetTextRange(0, sci.length) " ") ;Added spaces to front/back for padding
	hFile.Close()
	return
}

;***********Set the text*******************
setMainText() {
	main.Show()
	sci.Text := FileRead(fPath, 'UTF-8')
	ControlSend "{Ctrl down}a{Ctrl up}", "Scintilla1", WinTitle
	ControlFocus "Scintilla1", WinTitle
}

;***********Set Initial Greeting *******************
SetInitialBannerValue(){
Current_Day := FormatTime(, 'dddd')
hFile := FileOpen(fPath, "w-", 'UTF-8')
hFile.Write('Happy ' Current_Day)
hFile.Close()
}