#SingleInstance,Force
Browser_Forward::Reload ;RControl::
Browser_Back::
;**************************************
Gosub, Loop_File_Read
Gosub, File_Read_Line
return

;********************Loop File read***********************************
Loop_File_Read:

Gui, Add, ListView, r40 w600 ,Index|First Name|Last Name|Title
Loop, read, B:\the-automator\Webinar\Scripts\2017-12-Files and Folders\Files_to_manipulate\Full_List.txt
{
	msgbox % A_index a_Space A_LoopReadLine
	;~lv_add("",A_index,StrSplit(A_LoopReadLine,"`t").1,StrSplit(A_LoopReadLine,"`t").2 ,StrSplit(A_LoopReadLine,"`t").3)
	;~IfEqual, A_INdex,100,Break ;Stop at the 100th
}
;~LV_ModifyCol()  ; Auto-size each column to fit its contents.
;~Gui Show
return

;********************File read line example***********************************
File_Read_Line:
FileReadLine, Data, B:\the-automator\Webinar\Scripts\2017-12-Files and Folders\Files_to_manipulate\Full_List.txt, 5
MsgBox % data
return
