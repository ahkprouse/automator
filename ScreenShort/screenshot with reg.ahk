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
    base : ScriptObj(),
    version : "1.1.0",
    hwnd : 0,
    author : "the-Automator",
    email : "joe@the-automator.com",
    crtdate : "",
    moddate : "",
    resfolder : A_ScriptDir "\res",
    iconfile : 'mmcndmgr.dll' ,
    config : A_ScriptDir "\settings.ini",
    homepagetext : "ScreenShort",
    homepagelink : "the-automator.com/SceenShort?src=app",
    donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

indx := RegRead('HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer', 'ScreenshotIndex', 1)
SCFOLDER    := A_MyDocuments '\..\Pictures\Screenshots'
screenshot := Format( SCFOLDER '\*({}).png', indx)

path := A_Desktop '\newimage.png'

Sleep 500
Send '#{PrintScreen}'
while !FileExist(screenshot)
  Sleep 10

; FileMove screenshot, Log.IMGPATH '\error-' indx '.png'
FileMove screenshot, path