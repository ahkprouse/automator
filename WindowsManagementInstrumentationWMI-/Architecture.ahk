MsgBox, % "Architecture is: " . Architecture()

Architecture()
{
	for objItem in ComObjGet("winmgmts:\\.\root\CIMV2").ExecQuery("SELECT * FROM Win32_Processor")
		return, % (objItem.Architecture = "0") ? "x86" : (objItem.Architecture = "9") ? "x64" : "other Architecture"
}