#Requires AutoHotkey v2.0
#include Simple BarChart.ahk
allChart := getallCharts() ; get all charts data

mGui :=Gui(,'Bar Charts') ; creating parent Gui
mGui.SetFont('s12')
mGui.AddButton('w100 h30', 'Previous').OnEvent('click', changechart)
mGui.AddText('x+m w300 Center', 'Bar Chart Example')
mGui.AddButton('x+m w100 h30', 'Next').OnEvent('click', changechart)
mGui.Show('w560 h600')

ChartHwnd := [] ; array to store chart hwnd
for chartName, Chartmap in allChart
{
	barGui := CreateBarChart(Chartmap,chartName)
	barGui.show('hide x10 y80')
	barGui.opt('-caption +parent' mGui.hwnd )
	ChartHwnd.Push(barGui) ; storing chart hwnd in array
}
ChartHwnd[1].show() ; point to first chart and execute show method


; in here user can change the chart by clicking on previous and next button
changechart(ctrl,*)
{
	static CurrentChart := 1 ; static variable to keep track of current chart
	Switch ctrl.text ; ctrl.text is the text of the button
	{
		Case 'Previous':
			ChartHwnd[CurrentChart].Hide()
			CurrentChart := (CurrentChart--) <= 0 ? ChartHwnd.Length : CurrentChart-1
			ChartHwnd[CurrentChart].Show()
		Case 'Next':
			ChartHwnd[CurrentChart].Hide()
			CurrentChart := (CurrentChart++) >= ChartHwnd.Length ? 1 : CurrentChart+1
			ChartHwnd[CurrentChart].Show()
	
	}
}


; in here user can create charts with their data and they will be show in to Gui
getallCharts()
{
	return allChart := Map(
		'Food chart', Map(
			'Pizza', 10,
			'Burger', 20,
			'Pasta', 30,
			'Fries', 40,
			'Hotdog', 50,
			'Noodles', 60
		),
		'Clothes chart', Map(
			'Shirt', 10,
			'Pants', 80,
			'Socks', 35,
			'Shoes', 40,
			'Jacket', 50
		),
		'Electronics chart', Map(
			'Phone', 10,
			'Laptop', 45,
			'TV', 30,
			'Headphones', 72
		),
		'Books chart', Map(
			'Fiction', 20,
			'Non-Fiction', 38,
			'Biography', 57,
			'Autobiography', 88,
			'Poetry', 45,
			'Novel', 67,
			'Comic', 34
		),
		'Furniture chart', Map(
			'Sofa', 10,
			'Chair', 20,
			'Table', 30,
			'Bed', 40,
			'Wardrobe', 50,
		)
	)

}
