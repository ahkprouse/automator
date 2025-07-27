strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colPings := objWMIService.ExecQuery("Select * From Win32_PingStatus where Address = 'www.google.com'")._NewEnum ;or ip address like 192.168.1.1

While colPings[objStatus]
{
    If (objStatus.StatusCode="" or objStatus.StatusCode<>0)
        MsgBox Computer did not respond.
    Else
        MsgBox Computer responded.
}