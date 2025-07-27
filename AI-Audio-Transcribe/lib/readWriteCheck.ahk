
; testpath := A_ScriptDir '\res\'

; msgbox RWCheck('C:\TEMP')

RWCheck(path)
{
	if !FileExist(path)
		DirCreate(path)

	tmp := Path '\ReadWrite.tmp'
	if FileExist(tmp)
		FileDelete(tmp)
	
	FileAppend("test", tmp)

	if FileExist(tmp)
	&& FileRead(tmp) = 'test'
	{
		FileDelete(tmp)
		return true
	}
	
	try FileDelete(tmp)
	return false

}