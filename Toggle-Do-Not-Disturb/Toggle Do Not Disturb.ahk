/**
 * ============================================================================ *
 * @Author   : Xeo786                                                          *
 * @Homepage : the-automator.com                                                                 *
 *                                                                              *
 * @Created  : October 02, 2024                                                   *
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
;-
#Requires AutoHotkey v2.0+
#SingleInstance Force
#include <UIA>
#include <Triggers>
#include <NotifyV2>
#include <ScriptObject>
#include <WinHook>
#include <Win11Check>

if !Win11Check()
{
	Notify.Show({HDText:"Error",BDText:"This script is only for Windows 11",BDFontcolor:"red"})
	ExitApp
}



icon := Map()
icon[0] := "res\BellOn.ico"
icon[1] := "res\BellOff.ico"

; title := 'Settings ahk_exe ApplicationFrameHost.exe'
WinHook.Shell.Add(Settingup,,,'ApplicationFrameHost.exe',1) ; Notepad Window Created
hotkeytrack := false
script := {
	base         : ScriptObj(),
	version      : "0.0.0",
	hwnd         : '',
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "01 October 2024",
	moddate      : "02 October 2024",
	resfolder    : A_ScriptDir "\res",
	iconfile     : A_ScriptDir '\res\main.ico',
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "the-automator.com/DoNotDisturb",
	homepagelink : "the-automator.com/DoNotDisturb?src=app",
	donateLink   : "",
}
defaultHotkey := "!d"
triggers.AddHotkey(toggleDnd,'Toggle Do not Disturb',defaultHotkey,,true)
triggers.FinishMenu()
triggers.tray.Add('About',(*)=> Script.About())
triggers.tray.Add()
triggers.tray.AddStandard()
Notify.default.HDFontColor := "black"
Notify.default.BDFontSize := 20
Notify.default.GenIconSize := 70
Notify.default.BDFont := "Arial black"
TraySetDNDIcon()


toggleDnD(*)
{
	global hotkeytrack
	static title := 'Settings ahk_exe ApplicationFrameHost.exe'
	hotkeytrack := true
	UIelem := RunSettingsGetDNDElement(title)
	UIelem.Click()
	hotkeytrack := false
	state := UIelem.ToggleState
	if state == 1
		TraySetIcon(icon[1])
	else
		TraySetIcon(icon[0])
	WinClose(title)
	Notify.CloseLast()
	Notify.Show({HDText:"Do Not Disturb:",
				 BDText: (state == 1 ? "On" : "Off"),
				 BDFontcolor: (state == 1 ? "green":"red"),
				 GenIcon:icon[state]})
	
}

TraySetDNDIcon()
{
	global hotkeytrack
	static title := 'Settings ahk_exe ApplicationFrameHost.exe'
	hotkeytrack := true
	UIelem := RunSettingsGetDNDElement(title)
	hotkeytrack := false
	state := UIelem.ToggleState
	if state == 1
		TraySetIcon(icon[1])
	else
		TraySetIcon(icon[0])
	WinClose(title)
	startingHotkey := IniRead(triggers.ini, 'Hotkeys',toggleDnd.name,defaultHotkey)
	Notify.Show({HDText:"Do Not Disturb:",
				BDText: "Press " triggers.HKToString(startingHotkey) " to toggle",
				GenIcon:icon[state],
				GenDuration:4})
}

RunSettingsGetDNDElement(title)
{
	
	Run 'ms-settings:notifications' ; Notifications & actions
	WinWait(title)
	WinWaitActive(title)

	uiSetting := UIA.ElementFromHandle(title)
	return UIelem := uiSetting.WaitElement({AutomationId:"SystemSettings_Notifications_QuietHours_MuteNotification_Enabled_ToggleSwitch"})
}


Settingup(Win_Hwnd, Win_Title, Win_Class, Win_Exe, Win_Event)
{
	if !hotkeytrack
		return
	WinSetTransparent(0, Win_Title)
	; MsgBox "Created"
	; Pid := WinGetPID( 'ahk_id ' Win_Hwnd)
	; EH1 := WinHook.Event.Add(0x0016, 0x0016, Minimized, PID) 
	; EH2 := WinHook.Event.Add(0x0017, 0x0017, Restored, PID) 
	; EH3 := WinHook.Event.Add(0x000B, 0x000B, Resize, PID) 
}


/*
 toggleDnd(*)
{            
	static wintitle := "Notification Center"
	DetectHiddenWindows true
	send "#n"
	if !WinWaitActive(wintitle,,3)
	{
		Notify.Show({HDText:"Error",BDText:"Could not find Notification Center",BDFontcolor:"red"})
		return
	}
	ShellExp := UIA.ElementFromHandle(WinActive('a'))
	dndelem := ShellExp.ElementFromPath("R0")
	state := dndelem.ToggleState
	dndelem.Click()
	sleep 500
	send '{Esc}'  
	Notify.Show({HDText:"Do Not Disturb:",BDText: (state == 1 ? "On" : "Off"),BDFontcolor: (state == 1 ? "red" : "green")})
}
 */