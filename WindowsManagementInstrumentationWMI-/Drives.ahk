for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_LogicalDisk")
	MsgBox, % "Drives:`t`t" . objItem.Caption . "`n"
            . "File System:`t" . objItem.FileSystem  . "`n"
            . "Drive Size:`t`t" . Round((objItem.Size / (1024 ** 3)), 2)  . " GB`n"
            . "Free Space:`t" . Round((objItem.FreeSpace / (1024 ** 3)), 2)  . " GB`n"
            . "Free Space:`t" . Round((100 * (objItem.FreeSpace / objItem.Size)), 2)  . " %"