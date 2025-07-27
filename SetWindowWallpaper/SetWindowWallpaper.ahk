/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
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
;@Ahk2Exe-SetVersion     "0.0.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <Scriptobject>

script := {
  base         : ScriptObj(),
  version      : "1.1.0",
  hwnd         : 0,
  author       : "the-Automator",
  email        : "joe@the-automator.com",
  crtdate      : "",
  moddate      : "",
  resfolder    : A_ScriptDir "\res",
  iconfile     : 'mmcndmgr.dll' , 
  config       : A_ScriptDir "\settings.ini",
  homepagetext : "SetWindowWallpaper",
  homepagelink : "the-automator.com/SetWindowWallpaper?src=app",
  donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

;**************************************
;~ WallPaper_Path:="A:\Marketing\AHK Images\the-Automator_Logo\AHKBooks.png"
WallPaper_Path:="A:\Marketing\AHK Images\the-Automator_Logo\the-Automator.com-YouTube_Channel_Art_3.png"

;~ DllCall("SystemParametersInfo", UInt, 0x14, UInt, 0, Str, WallPaper_Path, UInt, 1) ;v1 version
DllCall("SystemParametersInfo", "UInt", 0x14, "UInt", 0, "Str", WallPaper_Path, "UInt", 1) ;V2 version
return