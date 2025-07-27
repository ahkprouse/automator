/**
 * ============================================================================ *
 * @Author   : Xeo786                                                          *
 * @Homepage : the-automator.com                                                                 *
 *                                                                              *
 * @Created  : March 14, 2024                                                   *
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
;@Ahk2Exe-SetVersion     0.0.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#SingleInstance
#Requires Autohotkey v2.0+
#include <ScriptObject>
#include <NotifyV2>

TraySetIcon('mmcndmgr.dll',15)
sGui := Gui('-DPIScale')
script := {
	        base : ScriptObj(),
	     version : "0.0.0",
	        hwnd : sGui.Hwnd,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	   resfolder : A_ScriptDir "\res",
		iconfile : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	         ini : A_ScriptDir "\settings.ini",
	homepagetext : "the-automator.com/stopwatch",
	homepagelink : "the-automator.com/stopwatch?src=app",
	;   donateLink : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6",
}
tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
tray.Add()
tray.AddStandard()

sGui.OnEvent('Close',(*) => ExitApp())
sGui.SetFont('s16 w500','Arial')
sGui.MarginX := 2
sGui.MarginY := 2
sGui.AddButton('','Start').OnEvent('Click', Start )
sGui.AddButton('x+m','Stop').OnEvent('Click', Stop )
sGui.AddButton('x+m','Reset').OnEvent('Click', Reset )
sGui.SetFont('s30 w700')
sGui.AddText('x+m center yp+1 vTime','00:00')
sGui.Show()
sGui.DisplayTime := a_yyyy A_MM a_DD
sGui.BalanceTime := 0
sGui.StartTickCount := A_TickCount

Start(*)
{
	sGui.StartTickCount := A_TickCount - sGui.BalanceTime 
	SetTimer(Watching,10)
}

Stop(*)
{
	sGui.BalanceTime := A_TickCount - sGui.StartTickCount 
	SetTimer(Watching,0)
	Coptime()
}

Reset(*)
{
	SetTimer(Watching,0)
	Coptime()
	sGui['Time'].value := '00:00'
	sGui.DisplayTime := a_yyyy A_MM a_DD
	sGui.BalanceTime := 0
	sGui.StartTickCount := A_TickCount
}


Watching(*)
{
	If ((A_TickCount - sGui.StartTickCount) >= 1000)       		; if current tickcount - StartTickCount >= 1000 (i.e. 1 second)
	{ 
		sGui.StartTickCount += (1000)
		sGui.DisplayTime := DateAdd(sGui.DisplayTime, 1, 'Seconds')
		sGui['Time'].value  := FormatTime(sGui.DisplayTime, 'mm:ss')  ;    format ElapsedTime to mm:ss
	}
}

Coptime(*)
{
	A_Clipboard := sGui['Time'].value
	Notify.Show({
		HDText: "Time copied to clipboard",
		BDText: sGui['Time'].value,
		BDFontSize: 24,
		GenIcon: script.iconfile ',15'
	})
}