#Requires AutoHotkey v2.0
/**
 * ============================================================================ *
 * @Author   : the-automator                                                          *
 * @Homepage : the-automator.com                                               *
 * @version  : 0.1.2                                                                          *
 * @Created  : Dec 16, 2024                                                    *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/

Filepath := Explorer_GetSelection()

/**
 * 
 * @param {Integer} hwnd 
 * @param {String} ReturnType 
 * @returns {Array | String} 
 */
Explorer_GetSelection(hwnd:='',ReturnType:="string")
{
	ToReturn := []
	process := WinGetProcessName('ahk_id' hwnd := hwnd? hwnd:WinExist('A'))
	class := WinGetClass('ahk_id' hwnd)
	if (process != 'explorer.exe')
	{
		ToolTip('Nothing was Selected'), SetTimer(Tooltip, -2500)
		return ToReturn
	}
	
	if (class ~= 'i)Progman|WorkerW')
	{
		files:=ListViewGetContent('Selected Col1', 'SysListView321', 'ahk_class' class)
		Loop Parse, files, '`n', '`r'
			ToReturn.Push(A_Desktop '\' A_LoopField)
	}
	else if (class ~= '(Cabinet|Explore)WClass')
	{
		for item in ExplorerTab(hwnd).Document.SelectedItems
			ToReturn.Push(item.path)
	}
	if(ReturnType = "string")
	{
		paths := ""
		for path in ToReturn
			paths .= path "`n"
		return trim(paths,"`n")
	}
	return ToReturn
}

ExplorerTab(hwnd) {
	; Thanks Lexikos - https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907
	try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	catch
	try activeTab := ControlGetHwnd("TabWindowClass1", hwnd) ; IE
	for window in ComObject("Shell.Application").Windows {
		if (window.hwnd != hwnd)
			continue
		if IsSet(activeTab) { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			IShellBrowser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(GetWindow := 3, IShellBrowser, "uint*", &thisTab := 0)
			if (thisTab != activeTab)
			continue
		}
		return window ; Returns a ComObject with a .hwnd property
	}
	throw Error("Could not locate active tab in Explorer window.")
}