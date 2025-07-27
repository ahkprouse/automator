#Include <default_Settings>
;**************************************
Var1:="Joe"
myFunc(Var1) ;Calling the function

;********************Defining the function***********************************
MyFunc(Var1:="one",Var2:="two",Var3:=""){   
;~ MyFunc(Var1,Var2,Var3){
	MsgBox % Var1 "`n" Var2 "`n|" Var3 "|"
}
