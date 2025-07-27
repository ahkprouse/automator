;http://msdn.microsoft.com/en-us/library/aa394072%28v=vs.85%29.aspx
PropertyList := "Caption,CreationClassName,Depth,Description,Height,HostingBoard,HotSwappable,InstallDate,"
   . "Manufacturer,Model,Name,OtherIdentifyingInfo,PartNumber,PoweredOn,Product,Removable,Replaceable,"
   . "RequirementsDescription,RequiresDaughterBoard,SerialNumber,SKU,SlotLayout,SpecialRequirements,"
   . "Status,Tag,Version,Weight,Width"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_BaseBoard
colMBInfo := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colMBInfo[objMBInfo]   
   Loop, Parse, PropertyList, `,
      MatherBoardInfo .= A_LoopField . ":`t" . objMBInfo[A_LoopField] . "`n"
MsgBox % MatherBoardInfo