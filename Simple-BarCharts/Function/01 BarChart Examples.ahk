#Requires AutoHotkey v2.0
#include Simple BarChart.ahk

; mymap := Map('joe',99,'irfan',32,'rizwan',46)
; CreateBarChart(mymap,'Hero Points Chart')

var := 'joe:100,irfan:57,rizwan:33,ali:201'
CreateBarChart(var,'header','Hero Points Chart', 'p')