;http://msdn.microsoft.com/en-us/library/aa394068(VS.85).aspx
PropertyList := "ProductName,Accesses,Attributes,Caption,Description,IdentifyingNumber,"
    . "InstallDate,InstallState,LastUse,Name,Status,Vendor,Version"
WMIClass := "Win32_SoftwareFeature"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery := "Select * From " . WMIClass
colProperties := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colProperties[objProperty]
    Loop, Parse, PropertyList, `,
        Result .= A_index = 1 ? objProperty[A_LoopField] . "`n" : "`t" . A_LoopField . ":`t" . objProperty[A_LoopField] . "`n"
logfile = %A_ScriptDir%\%WMIClass%.txt
FileDelete, %logfile%
FileAppend, %Result%, %logfile%
Run, "%logfile%"