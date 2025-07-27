;http://msdn.microsoft.com/en-us/library/aa394507%28v=vs.85%29.aspx
PropertyList := "Caption,AccountType,Description,Disabled,Domain,FullName,InstallDate,LocalAccount,"
    . "Lockout,Name,PasswordChangeable,PasswordExpires,PasswordRequired,SID,SIDType,Status"
WMIClass := "Win32_UserAccount"
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