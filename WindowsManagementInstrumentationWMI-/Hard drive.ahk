;http://msdn.microsoft.com/en-us/library/aa394132%28v=vs.85%29.aspx
PropertyList := "Caption,Availability,BytesPerSector,CompressionMethod,ConfigManagerErrorCode,"
   . "ConfigManagerUserConfig,CreationClassName,DefaultBlockSize,Description,DeviceID,ErrorCleared,"
   . "ErrorDescription,ErrorMethodology,FirmwareRevision,Index,InstallDate,InterfaceType,LastErrorCode,"
   . "Manufacturer,MaxBlockSize,MaxMediaSize,MediaLoaded,MediaType,MinBlockSize,Model,Name,NeedsCleaning,"
   . "NumberOfMediaSupported,Partitions,PNPDeviceID,PowerManagementSupported,SCSIBus,SCSILogicalUnit,"
   . "SCSIPort,SCSITargetId,SectorsPerTrack,SerialNumber,Signature,Size,Status,StatusInfo,"
   . "SystemCreationClassName,SystemName,TotalCylinders,TotalHeads,TotalSectors,TotalTracks,TracksPerCylinder"
   
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_DiskDrive
colDiskDrive := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colDiskDrive[objDiskDrive]
   Loop, Parse, PropertyList, `,
      DiskDriveInfo  .= A_index = 1 ? objDiskDrive[A_LoopField] . "`n" : "`t" . A_LoopField . ":`t" . objDiskDrive[A_LoopField] . "`n"
         
logfile = %A_ScriptDir%\DiskDriveInfo.txt
FileDelete, %logfile%
FileAppend, %DiskDriveInfo%, %logfile%
Run, "%logfile%"