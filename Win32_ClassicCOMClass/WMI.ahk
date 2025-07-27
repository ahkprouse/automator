;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;See more about WMI (Windows Management Instrumentation ) here:  https://the-Automator.com/WMI
;*******************************************************
#SingleInstance, Force
SendMode Input
SetWorkingDir, %A_ScriptDir%

WMI(){
    static oWMI := False
    return isObject(oWMI) ? oWMI : oWMI := new WMI()
}
; msgbox % WMI().type
class WMI {

    static obj := ComObjGet("winmgmts:")

    ExecQuery(StrQuery) {
        return this.obj.ExecQuery(StrQuery)
    }
}

