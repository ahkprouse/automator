;http://msdn.microsoft.com/en-us/library/aa394150%28VS.85%29.aspx
PropertyList := "ActionID,Caption,Description,Direction,File,FontTitle,"
    . "Name,SoftwareElementID,SoftwareElementState,TargetOperatingSystem,Version"
WMIClass := "Win32_FontInfoAction"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery := "Select * From " . WMIClass
colProperties := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colProperties[objProperty]
    Loop, Parse, PropertyList, `,
        Result .= A_Index = 1 ? objProperty[A_LoopField] . "`n" : "`t" . A_LoopField . ":`t" . objProperty[A_LoopField] . "`n"
logfile = %A_ScriptDir%\%WMIClass%.txt
FileDelete, %logfile%
FileAppend, %Result%, %logfile%
Run, "%logfile%"