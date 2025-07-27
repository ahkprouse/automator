#SingleInstance,Force
Random:=[],Dup:=[],Items:=[]
for a,b in StrSplit("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz") ;put whatever characters you want in here
	Random.Push(b) ;Add each character to Random Array
InputBox,Count,How Many Codes,How Many Codes do you want?
InputBox,Length,How Long For Each Code,How Long?
While(Items.MaxIndex()<Count){ ;Keep iterating until you have enough "keys"
	Out:=""  ;Clear out variable
	while(StrLen(Out)<Length){
		Random,Digit,0,% Random.MaxIndex() ;keep max lenght of random at right level
		Out.=Random[Digit] ;append the Random digit to out.
	}
	if(!Dup[Out])
		Items.Push(Out),Dup[Out]:=1 ;Add key to object
}
for a,b in Items ;Iterate over list
	Total.=b "`n" ;Add to total with new line

msgbox % Clipboard:=Total
