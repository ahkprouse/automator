;http://msdn.microsoft.com/en-us/library/aa394373%28v=vs.85%29.aspx
PropertyList := "AddressWidth,Architecture,Availability,Caption,ConfigManagerErrorCode,"
   . "ConfigManagerUserConfig,CpuStatus,CreationClassName,CurrentClockSpeed,CurrentVoltage,"
   . "DataWidth,Description,DeviceID,ErrorCleared,ErrorDescription,ExtClock,Family,InstallDate,"
   . "L2CacheSize,L2CacheSpeed,L3CacheSize,L3CacheSpeed,LastErrorCode,Level,LoadPercentage,"
   . "Manufacturer,MaxClockSpeed,Name,NumberOfCores,NumberOfLogicalProcessors,OtherFamilyDescription,"
   . "PNPDeviceID,PowerManagementSupported,ProcessorId,ProcessorType,Revision,Role,SocketDesignation,"
   . "Status,StatusInfo,Stepping,SystemCreationClassName,SystemName,UniqueId,UpgradeMethod,Version,VoltageCaps"
   
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_Processor
colCPU := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colCPU[objCPU]
   Loop, Parse, PropertyList, `,
      CPUInfo .= A_LoopField . ":`t" . objCPU[A_LoopField] . "`n"

logfile = %A_ScriptDir%\CPUInfo.txt
FileDelete, %logfile%
FileAppend, %CPUInfo%, %logfile%
Run, "%logfile%"