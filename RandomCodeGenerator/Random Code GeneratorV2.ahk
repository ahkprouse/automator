#SingleInstance


Rnd:=[],Dup:=Map(),Items:=[]
for char in StrSplit("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz") ;put whatever characters you want in here
	Rnd.Push(char) ;Add each character to Rnd Array
Count  := InputBox('How Many Codes','How Many Codes do you want?')
Length := InputBox('How Long For Each Code','How Long?')

DllCall('QueryPerformanceFrequency', 'Int64*', &freq := 0)
DllCall('QueryPerformanceCounter', 'Int64*', &CounterBefore := 0)
While(Items.Length < Count.value){ ;Keep iterating until you have enough "keys"
	Out:=""  ;Clear out variable
	while(StrLen(Out) < Length.Value){
		;keep max lenght of Rnd at right level
		Digit := Random(1,Rnd.Length)
		Out.=Rnd[Digit] ;append the Random digit to out.
	}
	if(!Dup.Has(Out))
		Items.Push(Out),Dup[Out]:=1 ;Add key to object
}
for char in Items ;Iterate over list
	Total.=char "`n" ;Add to total with new line

DllCall('QueryPerformanceCounter', 'Int64*', &CounterAfter := 0)
OutputDebug 'Elapsed time: ' (CounterAfter - CounterBefore) / freq * 1000 ' ms`n'
msgbox A_Clipboard := Total