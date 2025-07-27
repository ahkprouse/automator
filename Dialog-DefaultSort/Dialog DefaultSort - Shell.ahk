#SingleInstance
#Requires Autohotkey v2.0-
;--
;@Ahk2Exe-SetVersion     0.0.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
/**
 * ============================================================================ *
 * @Author   : RaptorX                                                          *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : June 17, 2023                                                    *
 * @Modified : June 17, 2023                                                    *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey Udemy courses.                                 *
 * They're structured in a way to make learning AHK EASY                        *
 * Right now you can  get a coupon code here: https://the-Automator.com/Learn   *
 * ============================================================================ *
 */

#Include <UIA-v2\Lib\UIA>
Persistent
; ItemNameDisplay            This sorts by Name
; ItemTypeText               This sorts by Type
; DateModified               This sorts by Date Modified
; Size                       This sorts by Size
sortBy        := 'DateModified' ; use one of the above

; Ascending
; Descending
sortDirection := 'Descending' ; use one of the above

main := Gui()

DllCall 'RegisterShellHookWindow', 'UInt', main.hwnd
MsgNum := DllCall('RegisterWindowMessage', 'Str','SHELLHOOK')
OnMessage(MsgNum, AutoSort)
Return

AutoSort(wParam, lParam, msg, hwnd)
{
	static WM_COMMAND            := 0x0111
	static HSHELL_MONITORCHANGED := 16

	; if GetKeyState('Shift')
	; 	return

	if wParam != HSHELL_MONITORCHANGED
		return

	try if WinGetClass(lParam) != 'WorkerW'
		return
	catch
		return

	if !WinWaitActive('ahk_class #32770',,3)
		return

	try ctrlid := ControlGetHwnd('DirectUIHWND2', 'ahk_class #32770')
	catch
		return false

	;set listview mode detail
	SendMessage WM_COMMAND,0x702c,0,, DllCall("GetParent","UInt", ctrlid)

	openDialog := UIA.ElementFromHandle(ctrlid)
	column := openDialog.FindElement({AutomationId: Format('System.{}', sortBy)})

	if column.ItemStatus != Format('Sorted ({})', sortDirection)
	{
		column.Click()
		OutputDebug ' Clicked'
	}

}