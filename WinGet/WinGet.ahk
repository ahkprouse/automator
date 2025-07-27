#Include <default_Settings>
;~ https://autohotkey.com/docs/commands/WinGet.htm
;~ gosub Example_1
;~ gosub Example_2
gosub Example_3
gosub Example_4
return
;**********Get active window ID**************************************************
Example_1:
WinGet, active_id, ID, A
WinMaximize, ahk_id %active_id%
MsgBox, The active window's ID is "%active_id%".
return

Example_2:
; Example #2: This will visit all windows on the entire system and display info about each of them:
WinGet, id, list,,, Program Manager
Loop, %id%
{
    this_id := id%A_Index%
    WinActivate, ahk_id %this_id%
    WinGetClass, this_class, ahk_id %this_id%
    WinGetTitle, this_title, ahk_id %this_id%
    MsgBox, 4, , Visiting All Windows`n%a_index% of %id%`nahk_id %this_id%`nahk_class %this_class%`n%this_title%`n`nContinue?
    IfMsgBox, NO, break
}
return

Example_3:
; Example #3: Extract the individual control names from a ControlList:
WinGet, ActiveControlList, ControlList, A
Loop, Parse, ActiveControlList, `n
{
    MsgBox, 4,, Control #%a_index% is "%A_LoopField%". Continue?
    IfMsgBox, No
        break
}
return

Example_4:
; Example #4: Display in real time the active window's control list:
#Persistent
SetTimer, WatchActiveWindow, 200
return
WatchActiveWindow:
WinGet, ControlList, ControlList, A
ToolTip, %ControlList%
return