#SingleInstance,Force
Browser_Forward::Reload ;RControl::
Browser_Back::
Gosub, Get_SubFolders
;~Gosub, Files_in_Folder
;~gosub, Structure
return

;********************Sub folders***********************************
Get_SubFolders:
;~ https://blogs.technet.microsoft.com/heyscriptingguy/2004/10/20/how-can-i-get-a-list-of-all-the-files-in-a-folder-and-its-subfolders/
folder:=ComObjCreate("Scripting.FileSystemObject").GetFolder(A_MyDocuments)
subFolders:=folder.SubFolders
gui, font, s11,Arial
Gui, Add, ListView, r20 w1600 , path|ShortPath|name|shortName|DateCreated|DateLastModified|DateLastAccessed|type
for f in SubFolders
	Lv_Add("",f.path,f.ShortPath,f.name,f.shortName,f.DateCreated,f.DateLastModified,f.DateLastAccessed,f.type)
LV_ModifyCol()  ; Auto-size each column to fit its contents.
Gui, Show
return

;********************Files in folders***********************************
Files_in_Folder:
folder:=ComObjCreate("Scripting.FileSystemObject").GetFolder(A_MyDocuments)
files:=folder.Files
;~   https://msdn.microsoft.com/en-us/library/6tkce7xa(v=vs.84).aspx
gui, font, s11,Arial
Gui, Add, ListView, r20 w1600 , path|ShortPath|name|shortName|DateCreated|DateLastModified|DateLastAccessed|size|type
for e, file in Files
	Lv_Add("",e.path,e.ShortPath,e.name,e.shortName,e.DateCreated,e.DateLastModified,e.DateLastAccessed,e.size,e.type)
LV_ModifyCol()  ; Auto-size each column to fit its contents.
gui, show
return


;****objects**************************
Structure:
folder:=ComObjCreate("Scripting.FileSystemObject").GetFolder(A_MyDocuments)
files:=folder.Files
for e, file in Files {
      drive:= e.Drive
	 
MsgBox % drive.DriveLetter   a_tab  drive.VolumeName
MsgBox % e.ParentFolder.name 
}
return