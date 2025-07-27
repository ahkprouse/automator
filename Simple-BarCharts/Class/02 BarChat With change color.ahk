#Requires AutoHotkey v2.0

#Requires AutoHotkey v2.0
#include BarChatClass.ahk


; showing Barchart with yellow bars red background
myBarChart := BarChart('AHK Hero Points')
myBarChart.BarColor := 'Yellow'
myBarChart.BackgroundColor := 'c98080'
bargui1 := myBarChart.Create('joe:100,irfan:50,rizwan:30,ali:200') ; directly passing parameters


; showing Barchart Changing fontsize

mySecondBarChart := BarChart('AHK Hero Points','footer')
mySecondBarChart.FontColor := 'Red'
mySecondBarChart.FontSize := '20'
mySecondBarChart.BarHeight := 100
mySecondBarChart.BarWidth := 800
bargui1 := mySecondBarChart.Create('joe:100,irfan:50,rizwan:30,ali:200') ; directly passing parameters

charts := BarChart()
charts.Header := 'AHK Hero Points'
charts.BarColor := 'Green'
charts.BackgroundColor := 'c98080'
charts.FontColor := 'Blue'
charts.FontSize := '20'
charts.BarHeight := 100
charts.BarWidth := 800
bargui1 := charts.Create('joe:100,irfan:50,rizwan:30,ali:200') ; directly passing parameters