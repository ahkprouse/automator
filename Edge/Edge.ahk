;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
; Location of this script: the-Automator.com/Edge ;If you share, please include this original source
;Huge thanks to Tank for adapting my crappy version of using ACC to this gem!

;*******************************************************
;If Edget doesn't exist, launch it, returnes the PID if you wish to kill it later you can store it on the call
Edge_Create(neww = false){
	static edgePID
	IF !WinExist("ahk_exe msedge.exe") || neww {
		run msedge.exe,,,edgePID
		WinWaitActive, ahk_pid %edgePID%,,5 ;timeout after 5 seconds		
	}
	else {
		winget,edgePID,PID,ahk_exe msedge.exe
	}
	return edgePID ;Use this to kill it later if you wish
}

;********************Quit Edge (Last active instance if no PID passed)***********************************
Edge_Quit(edgePID = false){ ;proivde PID if you want to kill a specific instance
	criteria := edgePID ? edgePID : Edge_Create()
	for obj in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process Where processID = " criteria) {
		obj.terminate()
	}
}

;********************Get the Active Edge / IE window***********************************
Edge_GetIE(edgePID = false){ ;Connect to DOM of IE within Edge
	static IID_IWebDOCUMENT := "{332C4425-26CB-11D0-B483-00C04FD90119}"
	static counter = 0
	window := "ahk_class Chrome_WidgetWin_1 ahk_exe msedge.exe ahk_pid " pid :=  edgePID ? edgePID : Edge_Create()
	msg := WM_HTML_GETOBJECT()
	SendMessage msg, 0, 0, Internet Explorer_Server1, %window%
	if (ErrorLevel != "FAIL"){
		lResult := ErrorLevel
		VarSetCapacity( GUID, 16, 0 )
		if DllCall( "ole32\CLSIDFromString", "wstr", IID_IWebDOCUMENT, "ptr", &GUID ) >= 0 {
			DllCall( "oleacc\ObjectFromLresult", "ptr", lResult, "ptr", &GUID, "ptr", 0, "ptr*", IWebDOCUMENT )
			try {
				pwb := IWebBrowserApp_from_IWebDOCUMENT( IWebDOCUMENT )
				counter := 0
				ToolTip
			}
			return  pwb
		}else
			errorMSG := "no CLSIDFromString"
	}else
		errorMSG :=  "FAIL"
	
	if  (counter++ < 10){ ;try up to 10 times to connect to IE
		ToolTip * %counter% * %pid% * retyring %errorMSG%
		sleep 1000
		return Edge_GetIE()
	}
	ToolTip
	msgbox %errorMSG%
}
;*******************************************************
;********************The next functions are Used above***********************************
;*******************************************************
WM_HTML_GETOBJECT(){
    return DllCall( "RegisterWindowMessage", "str", "WM_HTML_GETOBJECT" )
}

IWebBrowserApp_from_IWebDOCUMENT( IWebDOCUMENT ){
    static IID_IWebBrowserApp := "{0002DF05-0000-0000-C000-000000000046}"  ; IID_IWebBrowserApp
    return ComObj(9,ComObjQuery( IHTMLWindow2_from_IWebDOCUMENT( IWebDOCUMENT ), IID_IWebBrowserApp, IID_IWebBrowserApp),1)
}

IHTMLWindow2_from_IWebDOCUMENT( IWebDOCUMENT ){
	static IID_IHTMLWindow2 := "{332C4427-26CB-11D0-B483-00C04FD90119}"  ; IID_IHTMLWindow2
	return ComObj(9,ComObjQuery( IWebDOCUMENT, IID_IHTMLWindow2, IID_IHTMLWindow2),1)
}