#Include <default_Settings> ;NoIndex ;RAlt::
global Obj:=[] ;Creates obj holder for variables
Browser_Forward::Reload ;RControl::
Browser_Back::
;~Gosub, Write_File
Gosub, Read_File
;~Gosub, Read_Last_Row
return
;******************Write file********************
Write_File:
FileDelete File_Object_example.txt
f := FileOpen("File_Object_example.txt","w","CP65001") ;Open the file with UTF-8 encoding and Write access
FileOpen(ea.file,0,ea.encoding)
f.WriteLine("Joe was here") ;Add another line
f.WriteLine("Next Line") ;one more
;~MsgBox % Row:=f.ReadLine.tell()
MsgBox % F.Length
loop, 5 
	f.WriteLine("loop #" A_index) ;add 5 lines
MsgBox % F.Length
f.Close() ;close the file 
return

;********************read***********************************
Read_File:
f := FileOpen("File_Object_example.txt", "r","CP65001") ;Open the file with UTF-8 Encoding and Read access
MsgBox % Text:=f.ReadLine()
MsgBox % f.Tell()
MsgBox % Text:=f.ReadLine()
return

;********************Read last row***********************************
Read_Last_Row:
f := FileOpen("B:\Full_List.txt", "r") ;Open the file with Read access
While Not f.AtEOF 
	Last_Line := f.ReadLine(), Row:=A_Index  ;store data and index

f.Close()
MsgBox % "last row # is " RegExReplace(row, "\d(?=(\d{3})+(\D|$))", "$0,") " and is: " Last_Line
return