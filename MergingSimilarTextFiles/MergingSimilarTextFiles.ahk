;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;*******************************************************
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance,Force
SetBatchLines,-1
;********************Merge files with the same Headers***********************************
FileSelectFile, Files, M3 ; M3 = Multiselect existing files. set default path to downloads folder
Cancelled(Files) ;Check to see if user selected any files, if not, cancel
;********************Now loop over files, get paths, then combine***********************************
Loop, parse, files, `n 
{
	if A_Index = 1 ;get path
		Folder_Path:=A_LoopField "\" ;Store path to folder with backslash
	else { ;If the second one, read the whole file plus header
		If (A_Index=2)
			FileRead, Data, % *P65001  Folder_Path A_LoopField 
		else{
			Loop, read, %Folder_Path%%A_LoopField% ;Loop over Additional files
			{
				If (A_Index=1) ;If header row
					Continue
				Data.= A_LoopReadLine "`r`n"	;Append each row
		}}
	}
}
InputBox,New_File,New File Name,What do you want the new file name to be?`n`nBe sure to include the extension! ;Get file name with Extension
Cancelled(New_File) ;If they don't give it a name, cancel
File_Name:=InVaild_FileName_Fixer(File_Name) 
FileAppend, %Data%,%Folder_Path% %New_File%,UTF-8 ;Write file
Run %Folder_Path% %New_File% ;Launch it in default text editor
return

;********************See if the user took Action or hit cancel***********************************
Cancelled(Var){
	if (Var =""){
		MsgBox, The user pressed cancel.
		ExitApp
	}	
}

InVaild_FileName_Fixer(File_Name){
	Return File_Name:=Trim(RegExReplace(File_Name,"[\\/:*?""<>|]","_")," _") ;Get rid of invalid charachters and trim ends for underscore or space
}