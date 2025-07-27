#Include <default_Settings>
;**************************************
cool:=myFunc()
MsgBox % cool.1 a_tab cool.2 a_tab cool.3
return
myFunc(){
	Var1:=1
	Var2:=2	
	Var3:=3
	Array := [Var1,Var2,Var3]
	return Array
}

