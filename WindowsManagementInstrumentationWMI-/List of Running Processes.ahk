strComputer := "."
objWMIService := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" . strComputer . "\root\cimv2")
colItems := objWMIService.ExecQuery("SELECT Caption,ExecutablePath,ProcessID FROM Win32_Process where ExecutablePath is not null")._NewEnum
While colItems[objItem]
	Result.= "Caption: " . objItem.Caption
               . "`nProcessID: " . objItem.ProcessID
               . "`nExecutablePath: " . objItem.ExecutablePath "`n`n"
logfile = %A_ScriptDir%\Running_Processes.txt
FileDelete, %logfile%
FileAppend, %Result%, %logfile%
Run, "%logfile%"
