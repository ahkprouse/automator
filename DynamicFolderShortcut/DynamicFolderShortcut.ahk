/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-18-Feb                                                    *
 * @modified    2025-18-Feb                                                    *
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
   ;@Ahk2Exe-SetVersion     "0.0.1"
   ;@Ahk2Exe-SetMainIcon    res\main.ico
   ;@Ahk2Exe-SetProductName 
   ;@Ahk2Exe-SetDescription 
   #SingleInstance
   #Requires Autohotkey v2.0+
   #Include <ScriptObject>

   script := {
	base         : ScriptObj(),
	version      : "0.0.1",
	hwnd         : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "2025-18-Feb",
	moddate      : "2025-18-Feb",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\DynamicFolderShorcutbg512.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "DynamicFolderShortcut",
	homepagelink : "the-automator.com/DynamicFolderShorcut?src=app",
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


;********************v2 function version***********************************
DynamicFolderShortcut(Name:="Newsletter.lnk",baseFolder:="S:\Newsletter\Creative", DestPath:="C:\Users\Joe\Dropbox\Custom\Win\Menus\Shared Toolbar", Icon:="B:\Progs\AutoHotKey_L\Icons\alpha\Ninv.ico")

DynamicFolderShortcut(Name:="Newsletter.lnk",baseFolder:="S:\Newsletter\Creative", DestPath:="C:\Users\Joe\Dropbox\Custom\Win\Menus\Shared Toolbar", Icon:="B:\Progs\AutoHotKey_L\Icons\alpha\Ninv.ico")
{
	; Year_Month := FormatTime(A_Now, 'yyyy\MM') ;old which was just MM
	Year_Month := FormatTime(A_Now, 'yyyy\MM-MMM')
	folderPath := baseFolder "\" Year_Month "\" ; Create the full folder path
	try FileDelete DestPath '\' Name
	FileCreateShortcut FolderPath, DestPath "\" Name, DestPath,,Year_Month,Icon,1
}
