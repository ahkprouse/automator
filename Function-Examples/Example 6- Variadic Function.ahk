#Include <default_Settings>
MsgBox % StrSplit("This is really cool"," ").2






;**************************************
;~ myFunc("This","is","really","wow","neat") ;calling the function
var2:=StrSplit("This is really cool"," ")
myFunc(Var2)

;********************Defining the function***********************************
myFunc(var*){
	loop % var.MaxIndex()
		MsgBox % var[A_Index].3

}


var2:=StrSplit("This is really cool"," ")
loop % var2.MaxIndex()
	MsgBox % var2[A_Index]

;~ MsgBox % var2.2