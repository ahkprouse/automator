/**
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-04-01                                                     *
 * @modified    2025-04-01                                                     *
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
  

OnError logerrors

Logerrors(err, mode)
{
    line := err.What '`t' err.extra '`t' err.Message '`t' err.Line '`t' err.File '`n'
    FileAppend line, 'error.log', 'utf-8'
    return -1
}

;@Ahk2Exe-SetVersion     "0.0.1"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 
#SingleInstance Force
#Requires Autohotkey v2.0+
#Include <Explorer Get Selection>
#Include <ScriptObject>
TraySetIcon "C:\WINDOWS\system32\shell32.dll", 16

script := {
	base         : ScriptObj(),
	version      : "0.0.1",
	hwnd         : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "",
	moddate      : "",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "Randomize List",
	homepagelink : "the-automator.com/Randomize Listsrc=app",
	VideoLink    : "",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
;tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

if !wFile := FileSelect('3',,'Select the file to split')
{
	MsgBox 'No file selected'
		, 'Operation Cancelled'
		, 'IconX'
	Exitapp
}
SplitPath wFile,,&wFileDir,&wFileExt,&wFileName
SetWorkingDir wFileDir

hFile := FileOpen(wFile, 'r-', 'UTF-8')
headers := hFile.ReadLine()
contents := hFile.Read()
hFile.Close()

sorted_contents := StrSplit(Sort(contents, 'Random'), '`n', '`r')

count := {value:0}
while count.value < 1
	count := InputBox('How many lists do you want to create?', 'Choose List Count', 'w250 h90', 2)

if count.result != 'OK'
	return

line_count := Round(sorted_contents.Length / count.value)

fileCnt := 0
for line in sorted_contents
{
	if !line
		continue

	data .= line '`n'
	if !Mod(A_Index, line_count)
	{
		fileCnt++
		FileAppend headers '`n' data, wFileName '-' fileCnt '.' wFileExt, 'UTF-8'
		data := ''
	}
}

if data
{
	fileCnt++
	FileAppend headers '`n' data, wFileName '-' fileCnt '.' wFileExt, 'UTF-8'
}

MsgBox fileCnt ' lists were created.'
ExitApp