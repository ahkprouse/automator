;http://msdn.microsoft.com/en-us/library/aa394238%28VS.85%29.aspx
PropertyList := "Caption,CreationClassName,Description,DeviceType,Enabled,"
   . "HotSwappable,InstallDate,Manufacturer,Model,Name,OtherIdentifyingInfo,"
   . "PartNumber,PoweredOn,Removable,Replaceable,SerialNumber,SKU,Status,Tag,Version"
   
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_OnBoardDevice
colOnboard := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colOnboard[objOnboard]
   Loop, Parse, PropertyList, `,
      OnboardDeviceList .= A_index = 1 ? objOnboard[A_LoopField] . "`n" : "`t" . A_LoopField . ":`t" . objOnboard[A_LoopField] . "`n"

logfile = %A_ScriptDir%\OnboardDeviceList.txt
FileDelete, %logfile%
FileAppend, %OnboardDeviceList%, %logfile%
Run, "%logfile%"