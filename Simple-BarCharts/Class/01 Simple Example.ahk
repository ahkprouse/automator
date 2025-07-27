#Requires AutoHotkey v2.0
#include BarChatClass.ahk

myBarChart := BarChart(,'AHK Hero Points')
mymap := Map('joe',99,'irfan',32,'rizwan',46)
var := 'joe:100,irfan:50,rizwan:30,ali:200'

bargui1 := myBarChart.Create(var)  ; this will create and show at the center of the screen

bargui2 := myBarChart.Create(mymap,'x400 y700') ; this will create and show at x400 y700