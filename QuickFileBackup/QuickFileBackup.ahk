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
Persistent
#include <NotifyV2>
#include <ScriptObject>

Notify.Default.GenSound := 'tada'
Notify.Default.GenDuration := 5
Notify.Default.HDText := 'Quick File Backup'

;Todo
;~ • Create  a Gui
;~ • let people choose 1 or more folders and choose recursion/no recursion
;~ • let people list the extensions they want to backup.   Use tooltip to suggest: .exe, .ahk, .ini
; hIcon := LoadPicture("C:\Windows\system32\ieframe.dll", "Icon100", &imgType)
script := {
	        base : ScriptObj(),
	     version : '0.3.5',
	      author : 'Xeo786',
	       email : '',
	     crtdate : 'May 01, 2024',
	     moddate : 'May 01, 2024',
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'ieframe.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	      config : A_ScriptDir "\Preferences.ini",
	homepagetext : "the-automator.com/QuickFileBackup",
	homepagelink : "the-automator.com/QuickFileBackup?src=app",
	donateLink : '',
}

TraySetIcon(script.Iconfile,100)

ini := script.config ;A_ScriptDir "\Preferences.ini"
bGui := Gui()
tray := A_TrayMenu
tray.Delete()
tray.Add("Start Backup on launch", Backuponrun)
tray.Add("Exit when finish", Exitonfinish)
tray.Add()
tray.Add("Preferences",(*) => bGui.Show())
tray.Default := "Preferences"
tray.Add()
tray.Add("About",(*)=>Script.About())
tray.Add()
tray.AddStandard()
if bGui.Backuponrun  := IniRead(ini,'BackSettings','Backuponrun',0)
	tray.Check("Start Backup on launch")
if bGui.Exitonfinish := IniRead(ini,'BackSettings','Exitonfinish',0)
	tray.Check("Exit when finish")

Backup := IniRead(ini,'BackSettings','BackupFolder','<Please Select Back up Folder>')
if !FileExist(Backup)
&& Backup != "<Please Select Back up Folder>"
	DirCreate(Backup)

ExtList := IniRead(ini,'BackSettings','ExtList','ahk,txt')
AddBak := IniRead(ini,'BackSettings','AddBAK',0)? '+Checked' : '-Checked'

bGui.SetFont('s12')
bGui.AddText('vBackup y20 w300 h50 ',Backup)
bGui.AddButton('x+m vSelBackup h50 yp-15 ', 'Select Backup`n Folder').OnEvent('click', SelBackupFolder)
bGui.AddText('xm','Extension:') ;.GetPos()
bGui.AddEdit('x+m vExtList w340',ExtList)
bGui.Addcheckbox('xm+90 ' AddBak ' vAddBAK' ,'Add BAK to extension')
bGui.AddButton('xm vAddFolderLV', 'Add Folder').OnEvent('click',AddFolderLV)
bGui.AddButton('x+m-10','Delete').OnEvent('click',DeleteLV)
bGui.AddButton('x+m+80 vSave', 'Save && Run').OnEvent('click',SaveSettings)
bGui.AddButton('x+m-10 vCancel', 'Cancel')


pGui := Gui(,'Quick File Backup')
pGui.AddText('w400 center','Backingup Files...')
pGui.AddProgress('xm vprog w400 0x8') ; 0x8 pbs marque

LV := bGui.AddListView('xm w440 h200 Checked', ['Recursive | Folders'])
LV.OnEvent('ItemCheck', LVCheck)
try BackupList := IniRead(ini,'BackupList')
catch 
	BackupList := ''
for i, line in StrSplit(BackupList, "`n")
{
	;Folder := IniRead(ini,'BackSettings',line,0)
	if RegExMatch(line,"(?<name>.*)=(?<opt>.*)",&D)
		LV.Add(D['opt'],D['name'])
}
LV.ModifyCol(1,430)
bGui.AddButton('xm vRestoreExt', 'Restore original file extension')

if bGui.Backuponrun
&& Backup != "<Please Select Back up Folder>"
&& FileExist(Backup)
	init_Backup()
else
	bGui.Show()


Backuponrun(*)
{
	bGui.Backuponrun := !bGui.Backuponrun
	tray.ToggleCheck("Start Backup on launch")
	IniWrite(bGui.Backuponrun,ini,'BackSettings','Backuponrun')
}

Exitonfinish(*)
{
	bGui.Exitonfinish := !bGui.Exitonfinish
	tray.ToggleCheck("Exit when finish")
	IniWrite(bGui.Exitonfinish,ini,'BackSettings','Exitonfinish')
}

LVCheck(ctrl,item,check)
{
	opt := check ? '+Check' : '-Check'
	IniWrite(opt,ini,'BackupList',LV.GetText(item,1))
}

DeleteLV(*)
{
	row := 0
	loop
	{
		row := LV.GetNext(row)
		if !row
			break
		key := LV.GetText(row,1)
		IniDelete(ini,'BackupList',key)
		LV.Delete(row)
	}
}


AddFolderLV(*)
{
	Dir := FileSelect('D',,'Select Folder to Backup')
	if !FileExist(Dir)
	{
		return
	}
	LV.Add('+check',Dir)
	LV.ModifyCol(1,430)
	IniWrite('+check',ini,'BackupList',Dir)
}

SelBackupFolder(*)
{
	Dir := FileSelect('D',,'Select Backup Location')
	if !FileExist(Dir)
	{
		return
	}
	bGui['Backup'].Text := Dir
}

SaveSettings(*)
{
	Backup := bGui['Backup'].Text
	if Backup = "<Please Select Back up Folder>"
	{
		Notify.Show("Please Select Back folder")
		return
	}

	if !LV.GetCount()
	{
		Notify.Show("Please Add Folders to Back up")
		return
	}
		
	IniWrite(Backup,ini,'BackSettings','BackupFolder')
	if !ExtList := bGui['ExtList'].Text
	{
		Notify.Show("Please Profile Extension seperated by comma")
		bGui['ExtList'].Text := 'ahk,txt,ini'
		return
	}
	ExtList := RegExReplace(ExtList,"[^a-zA-Z0-9,]")
	IniWrite(ExtList,ini,'BackSettings','ExtList')
	AddBak := bGui['AddBAK'].value
	IniWrite(AddBak,ini,'BackSettings','AddBAK')
	bGui.Hide()
	init_Backup()
}

init_Backup()
{
	try BackupList := IniRead(ini,'BackupList')
	catch 
		BackupList := ''
	pGui.Show()
	pGui.FileCount := 0
	for i, line in StrSplit(BackupList, "`n")
	{
		;Folder := IniRead(ini,'BackSettings',line,0)
		if RegExMatch(line,"(?<name>.*)=(?<opt>.*)",&D)
		{
			if D['opt'] = "+Check"
				R := "R"
			else
				R := ""
			BackupFolder(D['name'],R)
		}
	}
	Notify.Show('Finished Backing up ' pGui.FileCount ' Files' )
	pGui.Hide()
	if bGui.Exitonfinish
	{
		Sleep 5000
		ExitApp()
	}
}

BackupFolder(Path,R:="")
{
	for i, ext in StrSplit(bGui['ExtList'].Text,",")
	{
		SplitPath(Path,&MainFolder)
		CopyFiles(Path, Backup,Ext, R, bGui['AddBAK'].value?"Bak":"")
	}
}


CopyFiles(source, destination,Ext, recursive := true, addSuffix := '')
{
	if !FileExist(destination)
		DirCreate destination

	SplitPath source, &parentFolder
	Loop files, source '\*.' Ext, recursive ? 'R' : ''
	{
		sleep 10
		pGui['prog'].value += 1
		pGui.FileCount += 1
		curr_dest := StrReplace(a_loopfilefullpath, source, destination '\' parentFolder)
		SplitPath(curr_dest,,&Dir)
		if !FileExist(Dir)
			DirCreate Dir
		FileCopy(a_loopfilefullpath, curr_dest addSuffix , true)
	}
}


		; Loop files, Path "\*." ext, R
		; {
			; SplitPath(A_LoopFileFullPath,&filename,&Dir)
			; SplitPath(dir,&StartingFolder)
			; Middlefolder := StrReplace(Dir,Path) ; gettnig middle folder from backup path so we can create folder structure
			; if Middlefolder
			; 	newFilePath := Backup "\" MainFolder Middlefolder "\" ; using  Main folder when looping files in root folder
			; else
			; 	newFilePath := Backup "\" StartingFolder  Middlefolder "\"  ; using starting folder when looping files in sub folder
			; if !FileExist(newFilePath)
			; {
			; 	try DirCreate(newFilePath)
			; 	catch
			; 	{
			; 		msgbox "Error Creating Folder`n" newFilePath
			; 		continue
			; 	}
			; }
			; newFilePath .= filename
			; if bGui['AddBAK'].value
			; 	newFilePath .= "bak"
			; FileCopy(A_LoopFileFullPath, newFilePath, 1)
		; }