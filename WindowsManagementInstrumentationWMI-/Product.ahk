;http://msdn.microsoft.com/en-us/library/aa394105%28v=vs.85%29.aspx
PropertyList := "Caption,Description,IdentifyingNumber,Name,SKUNumber,UUID,Vendor,Version"
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . A_ComputerName . "\root\cimv2")
WQLQuery = Select * From Win32_ComputerSystemProduct
colSysProduct := objWMIService.ExecQuery(WQLQuery)._NewEnum
While colSysProduct[objSysProduct]
   Loop, Parse, PropertyList, `,
      ProductInfo .= A_LoopField . ":`t" . objSysProduct[A_LoopField] . "`n"
MsgBox % ProductInfo