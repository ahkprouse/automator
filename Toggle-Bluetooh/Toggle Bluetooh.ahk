/**
 * =========================================================================== *
 * @author      Xeo786                                                  *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-10-01                                                     *
 * @modified    2024-10-02                                                     *
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
;@Ahk2Exe-SetVersion     0.0.0
;@Ahk2Exe-SetMainIcon    res\bluetoothOn.ico
;@Ahk2Exe-SetProductName Toggle Bluetooth
;@Ahk2Exe-SetDescription Toggle Bluetooth
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

SendMode 'event'

icon := Map()
icon[1] := A_ScriptDir "\res\bluetoothOn.png"
icon[0] := A_ScriptDir "\res\bluetoothOff.png"

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
	homepagetext : "the-automator.com/ToggleBT",
	homepagelink : "the-automator.com/ToggleBT?src=app",
	donateLink   : "",
}
defaultHotkey := "!B"
triggers.AddHotkey(toggleDnd,'Toggle Bluetooth',defaultHotkey,,true)
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
	send '{ctrl up}{Alt up}{Shift up}'
	hotkeytrack := true
	if !UIelem := RunSettingsGetDNDElement(title)
	{
		Notify.Show({HDText:"Error",BDText:"Could not find the Bluetooth Device",BDFontcolor:"red"})
		WinClose(title)
		return
	}
	UIelem.Click()
	Sleep 500
	hotkeytrack := false
	state := UIelem.ToggleState
	if state == 1
		TraySetIcon(icon[1])
	else
		TraySetIcon(icon[0])
	WinClose(title)
	Notify.CloseLast()
	Notify.Show({HDText:"Bluetooth:",
				 BDText: (state == 1 ? "On" : "Off"),
				 BDFontcolor: (state == 1 ? "green":"red"),
				 GenIcon:icon[state]})

}

TraySetDNDIcon()
{
	global hotkeytrack
	static title := 'Settings ahk_exe ApplicationFrameHost.exe'
	hotkeytrack := true
	if !UIelem := RunSettingsGetDNDElement(title)
	{
		Notify.Show({HDText:"Error",BDText:"Could not find the Bluetooth Device",BDFontcolor:"red"})
		WinClose(title)
		return
	}
	hotkeytrack := false
	sleep 200
	state := UIelem.ToggleState
	if state == 1
		TraySetIcon(icon[1])
	else
		TraySetIcon(icon[0])
	WinClose(title)
	startingHotkey := IniRead(triggers.ini, 'Hotkeys',toggleDnd.name,defaultHotkey)
	Notify.Show({HDText:"Bluetooth:",
				BDText: "Press " triggers.HKToString(startingHotkey) " to toggle",
				GenIcon:icon[state],
				GenDuration:4})
}

RunSettingsGetDNDElement(title)
{
	run 'ms-settings:bluetooth'
	WinWait(title,,10)
	WinWaitActive(title)
	uiSetting := UIA.ElementFromHandle(title)
	return UIelem := uiSetting.WaitElement({AutomationId:"SystemSettings_Device_BluetoothRadioToggle_ToggleSwitch"},5000)
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