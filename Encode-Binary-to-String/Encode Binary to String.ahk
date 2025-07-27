;~ #Include <default_Settings> 
#SingleInstance,Force
Bits:="100011010010010101011001010"
Bits:="Hq"
/*
  0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz

  5
  100
  0=0
  1=1
  2=10
  3=11
  4=100
  5=110
  6=111
  7=1000
*/
Gui,Add,Edit,gGo w500 Number
Gui,Add,UpDown,Range1-5000 +0x80,1
Gui,Add,Text,w500
Gui,Show
return
GuiEscape:
ExitApp
return
Go(){
	ControlGetText,i,Edit1,A
	ControlSetText,Static1,% ((i>>8&1)(i>>7&1)(i>>6&1)(i>>5&1)(i>>4&1)(i>>3&1)(i>>2&1)(i>>1&1)(i&1)),A
}