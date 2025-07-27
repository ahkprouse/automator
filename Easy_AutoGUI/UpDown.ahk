
#Requires Autohotkey v2
;AutoGUI creator: Alguimist autohotkey.com/boards/viewtopic.php?f=64&t=89901
;AHKv2converter creator: github.com/mmikeww/AHK-v2-script-converter
;EasyAutoGUI-AHKv2 github.com/samfisherirl/Easy-Auto-GUI-for-AHK-v2

if A_LineFile = A_ScriptFullPath && !A_IsCompiled
{
	myGui := Constructor()
	myGui.Show("w228 h160")
}

Constructor()
{	
	myGui := Gui()
	
	
	timerMinutes := myGui.Add("Edit", "x40 y64 w50 h21", "0")
	upDownMinutes := myGui.Add("UpDown", "x101 y64 w18 h21 0x80 +Wrap -16  Range0-1000", "0")

	
	upDownMinutes.OnEvent("Change", OnEventHandler)

	
	myGui.OnEvent('Close', (*) => ExitApp())
	
	
	myGui.Title := "Window"
	
	OnEventHandler(*)
	{	
		;old_timerMinutes := timerMinutes
		
		timerMinutes.value := upDownMinutes.value * 5
		upDownMinutes.value := timerMinutes.value / 5
		;if timerMinutes.value == 0 and timerHours.value >= 0{
		;	timerHours.value --
		
		;}
		
		;else if timerMinutes.value == 59{
		;	timerHours.value ++
		
		;}
		
		
		
		ToolTip("Click!`n"
		. "Active GUI element values include:`n"  
		. "timerMinutes => " timerMinutes.Value "`n"
		. "upDownMinutes => " upDownMinutes.value "`n"
		
		, 77, 277)
		SetTimer () => ToolTip(), -3000 ; tooltip timer
		
		
		
		
		
	}
	

	
	
	return myGui
}




