#SingleInstance,Force
;**************************************
;Stop the First Service in the List of the running Services 
;Run As Admin
if (! A_IsAdmin){ ;http://ahkscript.org/docs/Variables.htm#IsAdmin
	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}
colServices := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colServices[objService] {
	DemoRunService := objService.DisplayName
	if errReturnCode := objService.StartService()
		MsgBox, 48,, Error Code: %errReturnCode%`nCould Not Start the Service, %DemoRunService%
	else {
		Msgbox %DemoRunService% is Started. After OK is Pressed, It Will be Stopped.
		if errReturnCode := objService.StopService()
			MsgBox, 48,, Error Code: %errReturnCode%`nCould Not Stop the Service, %DemoRunService%
		else
			Msgbox Successfully Stopped the Service : %DemoRunService%
	}
	Break	;just one service to start and stop for demo
}