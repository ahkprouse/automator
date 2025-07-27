#SingleInstance,Force
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2") 

;Determinig which services are currently stopped and the start mode is 'Manual'
WQLQuery = SELECT DisplayName FROM Win32_Service Where State='Stopped' AND StartMode='Manual'
colServices := objWMIService.ExecQuery(WQLQuery)._NewEnum
count := 0
While colServices[objService] && ++count
	StoppedServices .= objService.DisplayName . "`n"
;~ MsgBox,, Services Currently Stopped and 'Manual': %count%, %StoppedServices%
ServicesList:= % count " Services Currently Stopped and Manual`n*************************************`n" StoppedServices
logfile = %A_ScriptDir%\ListOfServicesStoppedAndManual.txt
FileDelete, %logfile%
FileAppend, %ServicesList%, %logfile%
Run, "%logfile%"
return

