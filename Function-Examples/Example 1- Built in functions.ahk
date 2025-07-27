;~ #Include <default_Settings>
#SingleInstance,Force
;**************************************
;~ MsgBox % " the result is: " SubStr("123abc789",4,3) ; Returns abc
text:="Joe was here " 
wrap:="|"
MsgBox % wrap Text wrap
MsgBox % Wrap trim(text) Wrap

;~ MsgBox % StrSplit()
