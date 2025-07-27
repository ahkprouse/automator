objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2") 

;Determining the services which can be stopped
WQLQuery = SELECT * FROM Win32_Service WHERE AcceptStop = True		;"AcceptStop = True"
colServices := objWMIService.ExecQuery(WQLQuery)._NewEnum
count := 0
While colServices[objService] && ++count
	StoppableServices .= objService.DisplayName . "`n"
MsgBox,, Services which can be stopped: %count%, %StoppableServices%

;Determining the services wich can be paused
WQLQuery = SELECT * FROM Win32_Service WHERE AcceptPause = True		;AcceptPause = True
colServices := objWMIService.ExecQuery(WQLQuery)._NewEnum
count := 0
While colServices[objService] && ++count
	PausableServices .= objService.DisplayName . "`n"
MsgBox,, Services which can be paused: %count%, %PausableServices%

;Retrieves a complete list of services and their associated properties.
WQLQuery = Select * from Win32_Service
colServices := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colServices[objService] {
	ServicePropertyList .= objService.DisplayName . "`n"
	. "`tSystemName:`t" . objService.SystemName . "`n"
	. "`tName:`t" . objService.Name . "`n"
	. "`tServiceType:`t" . objService.ServiceType . "`n"
	. "`tState:`t" . objService.State . "`n"
	. "`tExitCode:`t" . objService.ExitCode . "`n"
	. "`tProcessID:`t" . objService.ProcessID . "`n" 
	. "`tAcceptPause:`t" . objService.AcceptPause . "`n" 
	. "`tAcceptStop:`t" . objService.AcceptStop . "`n" 
	. "`tCaption:`t" . objService.Caption . "`n" 
	. "`tDescription:`t" . objService.Description . "`n" 
	. "`tDesktopInteract:`t" . objService.DesktopInteract . "`n" 
	. "`tDisplayName:`t" . objService.DisplayName . "`n" 
	. "`tErrorControl:`t" . objService.ErrorControl . "`n" 
	. "`tPathName:`t" . objService.PathName . "`n" 
	. "`tStarted:`t" . objService.Started . "`n" 
	. "`tStartMode:`t" . objService.StartMode . "`n" 
	. "`tStartName:`t" . objService.StartName . "`n" 	
}
logfile = %A_ScriptDir%\ServicePropertyList.txt
FileDelete, %logfile%
FileAppend, %ServicePropertyList%, %logfile%
Run, "%logfile%"