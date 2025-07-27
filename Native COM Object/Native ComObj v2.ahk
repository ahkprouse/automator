/* =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 */
#Requires Autohotkey v2.0+
; https://the-Automator.com/Objects
SetTitleMatchMode 2
OBJID_NATIVEOM := -16
hwnd := ControlGetHwnd("_WwG1","- Word ahk_class OpusApp") ;identify the hwnd for Word

; OBJID_NATIVEOM In response to this object identifier, 
; third-party applications can expose their own object model. 
; Third-party applications can return any COM interface in response to this object identifier.
; https://docs.microsoft.com/en-us/windows/win32/winauto/object-identifiers
Obj:=ObjectFromWindow(hwnd, OBJID_NATIVEOM)
return

;***borrowd & tweaked from Acc.ahk Standard Library*** by Sean  Updated by jethrow*****************
/**
 *
 * @param {String} idObject
 * @param {String} WinTitle
 * @param {String} ClassNN
 * @returns {Float | Integer | String | ComValue | ComObject | ComObjArray}
 */
ObjectFromWindow(idObject, WinTitle?, ClassNN?) {
	oldMode := A_TitleMatchMode
	SetTitleMatchMode 2
	if IsSet(ClassNN)
		hwnd := ControlGetHwnd(ClassNN, WinTitle?)
	else
		hwnd := WinExist(WinTitle?)
	SetTitleMatchMode oldMode

	IID := Buffer(16)
	res := DllCall(
			"oleacc\AccessibleObjectFromWindow"
			,"ptr" , hwnd
			,"uint", idObject &= 0xFFFFFFFF
			,"ptr" , -16 + NumPut("int64", idObject == 0xFFFFFFF0 ? 0x46000000000000C0 : 0x719B3800AA000C81
			, NumPut("int64", idObject == 0xFFFFFFF0 ? 0x0000000000020400 : 0x11CF3C3D618736E0, IID))
			,"ptr*", ComObj := ComValue(9,0)
		)

	return res ? res : ComObj
}