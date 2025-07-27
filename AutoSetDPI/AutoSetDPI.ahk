/**
 * =========================================================================== *
 * @author      Xeo786                                                  *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-12-23                                                     *
 * @modified    2024-12-23                                                     *
 * @description AutoSetDPI                                                               *
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
;@Ahk2Exe-SetVersion     '0.0.0'
; ; @ Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName AutoSetDPI
;@Ahk2Exe-SetDescription Automatically Set DPI & reset it back to previous value
#Requires Autohotkey v2.0+
#SingleInstance
#include <ScriptObject>
#include <DPI>

script := {
	        base  : ScriptObj(),
	      author  : 'the-Automator',
	       email  : 'joe@the-automator.com',
	     crtdate  : '',
	     moddate  : '',
	   resfolder  : '',
	    iconfile  : '',
	      config  : '',
	homepagetext  : 'AutoSetDPI',
	homepagelink  : 'the-automator.com/AutoSetDPI?src=app',
	  donateLink  : '',
	  YoutubeLink : '',
	      DevPath :'C:\Users\AA\Dropbox\BioFeedback\DPIScaleReset\AutoSetDPI.ahk'
}

tray := A_TrayMenu
tray.Delete()
tray.Add('About',(*) => Script.About())
tray.Add('Youtube Intro Video',(*) => Run(script.donateLink))
tray.Add()
tray.Add('OpenFolder',(*) => Run(A_ScriptDir))
tray.Add()
tray.AddStandard()

RequiredDPI := 100
OldDPIenum := GetPrimaryDPIEnum()

^f1::SetDPIto(RequiredDPI) 
^f2::ResetDPI()


/**
 * 
 * @param {Integer} Value ; can be from 100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500
 */
SetDPIto(Value)
{
	global OldDPIenum
	if !AHKDPI2Enum.Has(Value)
	{
		msgbox 'Custom DPI Values are not accepted`nChoose from 100, 125, 150, 175, 200, 225, 250, 300, 350, 400, 450, 500'	
		return
	}

	DPIenum := GetPrimaryDPIEnum()
	if DPIenum = AHKDPI2Enum[Value]
		return
	OldDPIenum := DPIenum
	Display := GetEnumDisplays()[1]
	setDPI(Display.Path, AHKDPI2Enum[Value])
}


ResetDPI()
{
	global OldDPIenum
	if (OldDPIenum != GetPrimaryDPIEnum())
		return
	Display := GetEnumDisplays()[1]
	setDPI(Display.Path, OldDPIenum)
}