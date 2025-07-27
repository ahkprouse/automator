SetBatchLines,-1
#SingleInstance,Force
#Requires Autohotkey v1.1.33+
;;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
;~ FolderNameToDelete:="AHK-Studio Backup"  ;This is the default name of AHK Studio backup folder
FolderNameToDelete:="Test"  ;update if your folder is named something else

FileSelectFolder, fName, *%A_ScriptDir% ;Select the folder where to delete from (and below)
if !fName
	Return
;********************progress bar showing it is working***********************************
Gui Progress:new, -Caption
Gui Font, s15 cblue
Gui Add, Progress, vwProgress -Smooth 0x8 w350 h15 ; PBS_MARQUEE = 0x8
Gui Add, Text, w350 Center, Working
Gui Show

SetTimer, UpdateProgress, 100 ;Call timer to update
Count := 0
;********************Loop over files***********************************
Loop, Files, %fName%\*.*, DR
{
	try	{
		if (A_LoopFileName != FolderNameToDelete)
			Continue
		
		FileRecycle, %A_LoopFileFullPath% ;move it to the recylce bin
		FoldersDeleted.=A_LoopFileFullPath "`n"
		count++ ;Increment counter
	}Catch
		FoldersNotDeleted.=A_LoopFileFullPath "`n"
}
Clipboard:="Deleted:`n" FoldersDeleted "`n`nFolders Couldn't Delete`n" FoldersNotDeleted
Gui, Destroy
MsgBox, % Count " items deleted"
Exitapp
return

UpdateProgress:
Gui Progress:Default
GuiControl,, wProgress, 1 ;update progress bar
return