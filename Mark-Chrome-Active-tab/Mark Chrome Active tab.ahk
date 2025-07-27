
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
;@Ahk2Exe-SetVersion     1.0.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#Requires AutoHotkey v2.0
#include <UIA>
#include <UIA_Browser>
#include <NotifyV2>
#include <ScriptObject>
#SingleInstance

try Chromepath := RegRead('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe')
catch	
	Chromepath := ''
script := {
	        base : ScriptObj(),
	     version : '1.0.0',
	      author : 'Xeo786',
	       email : '',
	     crtdate : 'May 01, 2024',
	     moddate : 'May 21, 2024',
	   resfolder : A_ScriptDir "\res",
	    iconfile : Chromepath , 
	      config : A_ScriptDir "\Checklist.ini",
	homepagetext : "the-automator.com/ChromeActiveTab",
	homepagelink : "the-automator.com/ChromeActiveTab?src=app",
	 donateLink : ""
}
if Chromepath
	TraySetIcon(Script.iconfile, 5)
tray := A_TrayMenu
tray.Delete()
tray.Add('About', (*)=> script.About())
tray.Add()
tray.AddStandard()


;**************Hotkeys************************
Browser_Forward::Reload

Browser_Back::
^f1::
{
	try cUIA := UIA_Browser('a') 
	catch
		return Notify.show( 'Browser not found')
	try tabs := cUIA.GetAllTabs()
	catch
		return Notify.show( 'tabs not found')

	for k, tab in tabs
	{
		if tab.GetPattern(UIA.Pattern.SelectionItem).IsSelected
		{
			tab.Highlight()
			;sleep 3000
		}
	}
	else
		tab.ClearAllHighlights()
}
