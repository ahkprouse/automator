#Include <default_Settings>
;**************************************
One:=1
MyByRef(One)
MsgBox % one
;~ MsgBox % "after function: " One


MyByRef(ByRef One){
	;~ test:="taco"
	;~ return test
	MsgBox % "In funciton: " One
	One:="two"
	MsgBox % "2nd msgbox in function " One
	;~ return One
}