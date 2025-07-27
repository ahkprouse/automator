#SingleInstance
#Requires Autohotkey v2.0+
#Include <ScriptObject>
;--
;@Ahk2Exe-SetVersion     	0.0.1
; @Ahk2Exe-SetMainIcon    	res\main.ico
;@Ahk2Exe-SetProductName 	WebcamReminder
;@Ahk2Exe-SetDescription 	WebcamReminder
/**
 * ============================================================================ *
 * @Author   : the-automator                                                    *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : JAN 07, 2025                                                     *
 * @Modified : JAN 07, 2025 	                                                *
 * ============================================================================ *
  * Want a clear path for learning AutoHotkey?                                  *
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

TraySetIcon("C:\WINDOWS\system32\imageres.dll", 106)
script := {
	base	     : ScriptObj(),
	version      : "0.0.1",
	hwnd    	 : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "01-07-2025",
	moddate      : "01-07-2025",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\WebcamReminder.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "WebcamReminder",
	homepagelink : "the-automator.com/WebcamReminder?src=app",
	DevPath 	 : "S:\WebcamReminder\v2\WebcamReminder.ahk",
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

OnMessage(0x200, Notify)
OnMessage(0x02A3, Notify)

main := Gui('+toolwindow +alwaysontop')
main.OnEvent('Close', (*)=>ExitApp())
main.BackColor := 'Yellow'
main.MarginX := main.MarginY := 0
main.AddEdit('backgroundYellow -VScroll w565 h275').SetFont('s18', 'Consolas')
main.Show()

Notify(wParam, lParam, msg, hwnd)
{
	static WM_MOUSEMOVE := 0x0200
	static WM_MOUSELEAVE := 0x02A3

	switch msg
	{
	case WM_MOUSEMOVE:
		Tooltip 'Warning!!`nThis wont show in the video'
	case WM_MOUSELEAVE:
		Settimer Tooltip, -1000
	}
}

^esc::exitapp()