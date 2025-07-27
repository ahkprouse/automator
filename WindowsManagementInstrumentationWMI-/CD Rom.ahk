strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")

colItems := objWMIService.ExecQuery("Select * from Win32_CDROMDrive")._NewEnum
While colItems[objItem]
    MsgBox % "Device ID: " . objItem.DeviceID
   . "`nDescription: " . objItem.Description
   . "`nName: " . objItem.Name