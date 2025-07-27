;http://msdn.microsoft.com/en-us/library/aa394091%28VS.85%29.aspx
PropertyList := "Caption,AccessMask,Archive,Compressed,CompressionMethod,"
    . "CreationClassName,CreationDate,CSCreationClassName,CSName,Description,"
    . "Drive,EightDotThreeFileName,Encrypted,EncryptionMethod,Extension,"
    . "FileName,FileSize,FileType,FSCreationClassName,FSName,Group,Hidden,"
    . "InstallDate,InUseCount,LastAccessed,LastModified,Manufacturer,Name,"
    . "Path,Readable,Status,System,Version,Writeable"
WMIClass := "Win32_CodecFile"
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