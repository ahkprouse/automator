/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 */
#Requires Autohotkey v1.1+
#SingleInstance
; https://the-Automator.com/Objects
SetTitleMatchMode 2
OBJID_NATIVEOM := -16
ControlGet, hwnd, hwnd, , % "_WwG1", % "- Word ahk_class OpusApp" ;identify the hwnd for Word

; OBJID_NATIVEOM In response to this object identifier, 
; third-party applications can expose their own object model. 
; Third-party applications can return any COM interface in response to this object identifier.
; https://docs.microsoft.com/en-us/windows/win32/winauto/object-identifiers
Obj:=ObjectFromWindow(hwnd, OBJID_NATIVEOM)
return

;***borrowd & tweaked from Acc.ahk Standard Library*** by Sean  Updated by jethrow*****************
ObjectFromWindow(hWnd, idObject = -4){
	if(h:=DllCall("LoadLibrary","Str","oleacc","Ptr"))
		If DllCall("oleacc\AccessibleObjectFromWindow","Ptr",hWnd,"UInt",idObject&=0xFFFFFFFF,"Ptr",-VarSetCapacity(IID,16)+NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81,NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0,IID,"Int64"),"Int64"), "Ptr*", pacc)=0
			Return ComObjEnwrap(9,pacc,1)
}