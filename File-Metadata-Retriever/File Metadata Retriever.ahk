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
;@Ahk2Exe-SetVersion     0.1.0
;@Ahk2Exe-SetProductName FileExProUI
;@Ahk2Exe-SetDescription FileExProUI by the-Automator
;--
#SingleInstance
#Requires Autohotkey v2.0+
#SingleInstance Force
TraySetIcon("C:\Windows\system32\ieframe.dll", 22)

#Include <FileExproV2>
#include <Guis>
#include <ScriptObject>

script := {
	base         : ScriptObj(),
	version      : '0.1.0',
	author       : 'the-Automator',
	email        : 'joe@the-automator.com',
	crtdate      : 'July 24, 2024',
	moddate      : 'August 02, 2024',
	homepagetext : 'the-automator.com/GetMetadata',
	homepagelink : 'the-automator.com/GetMetadata?src=app',
	donateLink   : 'https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6',
}
tray := A_TrayMenu
tray.Delete()
tray.Add('About',(*)=>script.About())
tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard

GenCode(*)
{
	row := LV.GetNext(0)
	if !row
		return
	A_Clipboard := ''
	Prop := LV.GetText(row)
	cmd :=  StrReplace(prop,A_Space,'_') " := FileExPro('{}','{}')"
	; if CB.value
	; {
	; 	A_Clipboard := '#include ' A_ScriptDir '\lib\FileExProV2.ahk`n`n'
	; }
	A_Clipboard .= Format(cmd,pathCtrl.Value,Prop)
	ToolTip('copied: ' A_Clipboard)
	settimer tooltip, -1500
}


