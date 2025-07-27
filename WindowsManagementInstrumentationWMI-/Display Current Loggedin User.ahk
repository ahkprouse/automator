strComputer := "."
strNamespace := "\root\cimv2"

objWMI := ComObjGet("winmgmts:\\"  strComputer  strNamespace)
colCS := objWMI.ExecQuery("SELECT * FROM Win32_ComputerSystem")

For objSession in colCS{
	MsgBox, % "User: " objSession.UserName
}