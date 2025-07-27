#SingleInstance,Force
Browser_Forward::Reload ;RControl::
Browser_Back::
;**************************************
Folder_Path:="B:\the-automator\Webinar\Scripts\2017-12-Files and Folders\Files_to_manipulate"
;~Gosub, Loop_Files
;~Gosub, Folder_Size
;~Gosub, Loop_Folders
Gosub, Delete_Files
Gosub, Special_Vars
return

;********************Loop Files***********************************
Loop_Files:
Loop, Files, %folder_Path%\*.txt , R  ;Recursively loop over folders and sub-folders
	Filenames .= A_LoopFileFullPath "`n"
DebugWindow(FileNames,1,,200,0)

;********************Size of folder***********************************
Folder_Size:
Loop, Files, C:\temp\*.*, R
	FolderSizeMB += %A_LoopFileSizeMB%
MsgBox Size of C:\temp is %FolderSizeMB% megabytes.
return

;********************Loop Folders***********************************
Loop_Folders:
Loop, Files, C:\*.* , D  ;Non-recursive loop over folders
	Folders.=A_LoopFileName "`n"
DebugWindow(folders,1,0,300)
return

;********************Delete files***********************************
Delete_Files:
exx=bak,xls,tmp,zip,7z,pdf,png,TMP,cvr.txt
Loop, C:\temp\*.*, 0, 1 ;loop over all files/folders rcursively
{
	If A_LoopFileExt in %exx% ;check to see if file extension is one I want to delete
		FileDelete, %A_LoopFileFullPath% ;if it is, delete it
	IfMsgBox, No
		break ;Stops look from keeping running
}
return

;********************Special Variables***********************************
Special_Vars:
gui, font, s11,Arial
Gui, Add, ListView, r40 w1600 , FileName|Ext|Full Path|Long Path|Short Path|ShortName|Dir|Time-Mod|Time-Created|Time-Accessed|Attrib|Size|KB|MB
Loop, Files, c:\temp\*.* ;Get list of files in c:\temp
{
	LV_Add("",A_LoopFileName
	         ,A_LoopFileExt
	         ,A_LoopFileFullPath
	         ,A_LoopFileLongPath
	         ,A_LoopFileShortPath
	         ,A_LoopFileShortName
	         ,A_LoopFileDir 
	         ,A_LoopFileTimeModified 
	         ,A_LoopFileTimeCreated
	         ,A_LoopFileTimeAccessed
	         ,A_LoopFileAttrib 
	         ,A_LoopFileSize 
	         ,A_LoopFileSizeKB 
	         ,A_LoopFileSizeMB )	
}

LV_ModifyCol()  ; Auto-size each column to fit its contents.
gui, show
return