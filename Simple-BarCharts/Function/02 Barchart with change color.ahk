#Requires AutoHotkey v2.0
#include Simple BarChart.ahk


; showing Barchart with yellow bars red background
; Footer := 'AHK Hero Points'
; BarColor := 'Yellow'
; BackgroundColor := '0x98080'
; mymap := Map('joe',99,'irfan',32,'rizwan',46)
input := 'joe:400,irfan:150'
; CreateBarChart(input) ;,,Footer,,,,,BarColor,BackgroundColor)

msgbox type(input)
mymap := str2map(input,',','|')
msgbox type(mymap)
str2map(str,lineSep,ValSep)
{
	mymap := map()
	for i, line in StrSplit(str, lineSep)
	{
		result := StrSplit(line, ValSep)
		mymap[result[1]] := result[2]
	}
	return mymap
}


; showing Barchart Changing fontsize
;CreateBarChart(input:='joe:100,irfan:50,rizwan:30,ali:200',HeaderText:='AHK Hero Points',,BarWidth:=800,BarHeight:=100,FontSize:=12,FontColor:='Red')
