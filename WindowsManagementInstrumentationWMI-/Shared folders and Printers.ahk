;http://msdn.microsoft.com/en-us/library/aa394507%28v=vs.85%29.aspx
PropertyList := "Name,AccessMask,AllowMaximum,Caption,Description,InstallDate,"
    . "MaximumAllowed,Path,Status,Type"
WMIClass := "Win32_Share"
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