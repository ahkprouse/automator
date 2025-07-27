#Requires Autohotkey v2.0+
Explorer_GetSelection(hwnd:='')
{
	ToReturn := []
	process := WinGetProcessName('ahk_id' hwnd := hwnd? hwnd:WinExist('A'))
	class := WinGetClass('ahk_id' hwnd)
	if (process != 'explorer.exe')
		return (ToolTip('Nothing was Selected'), SetTimer((*)=>Tooltip, 2500), ToReturn)

	if (class ~= 'i)Progman|WorkerW')
	{
		files:=ListViewGetContent('Selected Col1', 'SysListView321', 'ahk_class' class)
		Loop Parse, files, '`n', '`r'
			ToReturn.Push(A_Desktop '\' A_LoopField)
	}
	else if (class ~= '(Cabinet|Explore)WClass')
	{
		for window in ComObject('Shell.Application').Windows
		{
			if (window.hwnd!=hwnd)
				continue
			sel := window.Document.SelectedItems
			break
		}

		for item in sel
			ToReturn.Push(item.path)
	}

	return ToReturn
}