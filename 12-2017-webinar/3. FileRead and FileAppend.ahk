#SingleInstance,Force  ; Recommended for performance and compatibility with future AutoHotkey releases.
Browser_Forward::Reload ;RControl::
Browser_Back::
Gosub, File_Append
Gosub, File_Read
return

;********************File Append***********************************
File_Append:
;~FileDelete, %A_ScriptDir%\Files_to_Manipulate\File_append_example.txt
fileAppend,This`nis`nmy`ntext`r,%A_ScriptDir%\Files_to_Manipulate\File_append_example.txt,UTF-8

return

;********************FileRead***********************************
File_Read:
FileRead,Var,*P65001 %A_ScriptDir%\Files_to_Manipulate\File_append_example.txt
DebugWindow(Var,Clear:=1,LineBreak:=1,Sleep:=500,AutoHide:=0)
return

