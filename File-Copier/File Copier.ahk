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
   ;@Ahk2Exe-SetProductName 
   ;@Ahk2Exe-SetDescription 
   #Requires Autohotkey v2.0+
   #SingleInstance
   #Include <scriptobject>

   script := {
	base 		 : ScriptObj(),
	version      : "0.0.1",
	hwnd    	 : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "",
	moddate      : "",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , 
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "File Copier",
	homepagelink : "the-automator.com/FileCopier?src=app",
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

src_folder := 'B:\Guests\Chad_Archive'
trg_folder := 'A:\Lifes_Work\Maestrith\Archive' ; no trailing back slash
extensions := ['ahk'] ; this is an array

try DirCreate trg_folder

cnt := 0
for ext in extensions
{
	ext := trim(ext, '.')
	loop files src_folder '\*' ext, 'FR'
		cnt++
}

wth        := 300
tProgress  := Gui('+AlwaysOnTop +ToolWindow')
pgTitle    := tProgress.Add('Text', 'Center w' wth, 'Copying files')
pgCtrl     := tProgress.Add('Progress', 'Range1-' cnt ' w' wth ' h3')
pgSubTitle := tProgress.Add('Text', 'Center w' wth, '0/' cnt)
tProgress.Show()

SplitPath(trg_folder,,,,,&new_drive)
err_count := 0
for ext in extensions
{
	; let me comment on this
	ext := trim(ext, '.')
	loop files src_folder '\*' ext, 'FR'
	{
		SplitPath(A_LoopFileFullPath, &fName, &fDir, &fExt)

		pgCtrl.value     := A_Index
		pgSubTitle.value := A_Index '/' cnt

		try
		{
			trg_folder := Trim(trg_folder, '\')
			new_dir := trg_folder '\' RegExReplace(fDir, '\w:\\')
			DirCreate new_dir
			FileCopy A_LoopFileFullPath, new_dir
		}
		catch Error as e
		{
			err_count++
			FileAppend e.What '`t' e.What '`n', 'error.log'
		}
	}
}
tProgress.Destroy()

if FileExist('error.log')
	Run 'notepad.exe error.log'
return	