#Include <default_Settings>
;**************************************
sum:=0
One:=1
Two:=2
myFunc(One,Two)

MsgBox % "after function: " Sum


myFunc(One,Two){
	global Sum
	Static Counter
	Sum:=One + Two ;inside function
	Counter++
	MsgBox % "inside function`nsum: " Sum  "`n`n(not a surprise)`n`nCounter: " Counter	
}

