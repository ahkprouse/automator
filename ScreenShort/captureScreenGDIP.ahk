/**
 * =========================================================================== *
 * @author      Xeo786                                                         *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-01-01                                                     *
 * @modified    2025-01-01                                                     *
 * @description                                                                *
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
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
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 
#Requires Autohotkey v2.0+
#SingleInstance

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

#include <Gdip>
captureScreenGDIP(1)
captureScreenGDIP(Screen:=0)
{
	token := GDIPlus.StartUp()
	filepath := A_Desktop '\image.png'
	pBitmap := GDIPlus.BitmapFromScreen(Screen, Raster:="")
	GDIPlus.SaveBitmapToFile(pBitmap, filepath)
	GDIPlus.ShutDown(token)
}