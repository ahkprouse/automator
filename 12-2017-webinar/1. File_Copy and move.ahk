#SingleInstance,Force
Browser_Forward::Reload ;RControl::
Browser_Back::
;**************************************
Folder_Path:="B:\the-automator\Webinar\Scripts\2017-12-Files and Folders\Files_to_manipulate"
Gosub, Copy_Files
;~Gosub, Copy_Folders
;~Gosub, Select_Files
;~Gosub, Select_Folders
return


Copy_Files:
FileCopy, %Folder_Path%\example1.txt, %Folder_Path%\Sub_Folder\  ; Make a copy but keep the orig. file name.
;~FileCopy, %Folder_Path%\example1.txt, %Folder_Path%\Example_1_new_Name.txt  ; Copy a file into the same folder by providing a new name.
;~FileCopy, %Folder_Path%\example1.txt, %Folder_Path%\Example_1.bak  ; Copy to new location and give new extension.
return

Copy_Folders:
FileCopyDir, %Folder_Path%\Sub_Folder, %Folder_Path%\Folder_Copy ;Copy a folder & it's contents
;~FileCreateDir, %Folder_Path%\Folder_Copy\sub_folder\sub_subfolder ;Create subfolders (ddon't have to do individually)
return


Select_Files:
FileSelectFile, SelectedFile, 3,%Folder_Path% , Open a file, Text Documents (*.txt; *.csv; *.dat) ;select a text or DOC file
DebugWindow(SelectedFile,,200,4000)
;~
;~FileSelectFile, SelectedFiles, M3,%Folder_Path% , Open a file, Text Documents (*.txt; *.csv; *.dat) ;select a text or DOC file
;~for i, row in StrSplit(SelectedFiles,"`n") { ;Parse Parse SelectedFiles by `n
	;~IfEqual, i,1,SetEnv,Folder_Path,%row% ;if first- get path to folder
	;~IfGreater,i,1,SetEnv,files, %files%%Folder_Path%\%row%`n ;get list of files
;~}
;~DebugWindow(Files,1,,200,4000)
return

Select_Folders:
FileSelectFolder, Target_Folder, %Folder_Path%, 3, Select the folder you want ;Select Folder
DebugWindow(Target_Folder,1,200,4000)

;********************CLSID (CLass Identifier) Example  https://autohotkey.com/docs/misc/CLSID-List.htm  ***********************************
;~FileSelectFolder, Target_Folder, ::{20d04fe0-3aea-1069-a2d8-08002b30309d}  ; My Computer.
;~DebugWindow(Target_Folder,1,200,4000)
return