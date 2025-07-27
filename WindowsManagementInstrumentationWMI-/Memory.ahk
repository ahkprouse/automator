;http://msdn.microsoft.com/en-us/library/aa394347%28v=vs.85%29.aspx
PropertyList := "BankLabel,Capacity,Caption,CreationClassName,DataWidth,Description,DeviceLocator,FormFactor,"
    . "HotSwappable,InstallDate,InterleaveDataDepth,InterleavePosition,Manufacturer,MemoryType,Model,Name,"
    . "OtherIdentifyingInfo,PartNumber,PositionInRow,PoweredOn,Removable,Replaceable,SerialNumber,SKU,Speed,"
    . "Status,Tag,TotalWidth,TypeDetail,Version"

objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_PhysicalMemory
colMemInfo := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colMemInfo[objMemInfo]
    Loop, Parse, PropertyList, `,
        MemInfo .= A_index = 1 ? objMemInfo[A_LoopField] . "`n" : "`t" . A_LoopField . ":`t" . objMemInfo[A_LoopField] . "`n"
logfile = %A_ScriptDir%\MemoryInfoList.txt
FileDelete, %logfile%
FileAppend, %MemInfo%, %logfile%
Run, "%logfile%"