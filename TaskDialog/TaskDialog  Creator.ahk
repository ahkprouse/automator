;**********************Gui creator for Task Dialog*********************************
;~ http://ahkscript.org/boards/viewtopic.php?f=6&t=4635&sid=192e609bed34f194cd4e951cf37ce08f&start=20
#NoEnv
#NoTrayIcon
#SingleInstance  force
SetWorkingDir %A_ScriptDir%
SetBatchLines -1
ListLines Off

Gui, Add, Edit, x110 y30 w340 h70 Multi vmain   r3, MainTip
Gui, Add, Edit, x110 y90 w340 h40 Multi vextra   r5, ExtraTip
Gui, Add, Edit, x110 y180 w340 h20 -Multi  vtitle, Title
Gui, Add, Edit, x110 y210 w340 h20 -Multi  vwidth +number, 400
Gui, Add, Edit, x110 y240 w340 h20 -Multi vtimeout +number, 10

Gui, Add, GroupBox, x470 y20 w290 h125 , Buttons

Gui, Add, Radio, x490 y40 w100 h20 vbutton1 checked, Ok
Gui, Add, Radio, x490 y64 w100 h20 vbutton2, Yes
Gui, Add, Radio, x490 y88 w100 h20 vbutton3, Yes/No
Gui, Add, Radio, x490 y112 w130 h20 vbutton4, Cancel/Retry/Close

Gui, Add, Radio, x620 y40 w100 h20 vbutton5, Close
Gui, Add, Radio, x620 y64 w100 h20 vbutton6, Retry/Cancel
Gui, Add, Radio, x620 y88 w100 h20 vbutton7, Retry/Close
Gui, Add, Radio, x620 y112 w130 h20 vbutton8, Yes/No/Close

Gui, Add, GroupBox, x470 y150 w290 h160 , Icons

Gui, Add, Radio, x490 y170 w100 h20 vicon1, Warn
Gui, Add, Radio, x490 y198 w100 h20 vicon2, Error
Gui, Add, Radio, x490 y226 w100 h20 vicon3, Info
Gui, Add, Radio, x490 y254 w100 h20 vicon4, Shield
Gui, Add, Radio, x490 y282 w100 h20 vicon5, Blue

Gui, Add, Radio, x610 y170 w100 h20 vicon6, Yellow
Gui, Add, Radio, x610 y198 w100 h20 vicon7, Red
Gui, Add, Radio, x610 y226 w100 h20 vicon8 checked, Green
Gui, Add, Radio, x610 y254 w100 h20 vicon9, Gray
Gui, Add, Radio, x610 y282 w100 h20 vicon10, Question

Gui, Add, Text, x20 y55 w90 h30, MainTip：
Gui, Add, Text, x20 y120 w90 h20, ExtraTip：
Gui, Add, Text, x20 y185 w90 h20, Title：
Gui, Add, Text, x20 y215 w90 h20 , Width：
Gui, Add, Text, x20 y245 w90 h20 , Timeout：
Gui, Add, Text, x20 y345 w90 h20 , Result：
gui,font,s13
Gui, Add, Edit, x110 y330 w650 h50 r3  vcontent, Result
gui,font
Gui, Add, Button, x110 y270 w170 h40 gcommand, Generate
Gui, Add, Button, x280 y270 w170 h40 gview, View
Gui, Add, Text, x380 y410 w700 h30 +disabled, A normal Msgbox will display on XP.The TaskDialog's author:just me.
; Generated using SmartGuiXP Creator mod 4.3.29.0
Gui, Show, Center w780 h430, TaskDialogEx Creator
GuiControl, +Default, Generate
Return

GuiClose:
ExitApp

command:
Gui, Submit, NoHide

loop 8
{
    if button%a_index%=1
    {
        if A_Index = 1
            button = 1
        else if A_Index = 2
            button = 2
        else if A_Index = 3
            button = 6
        else if A_Index = 4
            button = 56
        else if A_Index = 5
            button = 32
        else if A_Index = 6
            button = 24
        else if A_Index = 7
            button = 48
        else if A_Index = 8
            button = 38
        break
    }

}


loop 10
{
    if icon%a_index%=1
    {
        if A_Index = 1
            Icon = 1
        else if A_Index = 2
            Icon = 2
        else if A_Index = 3
            Icon = 3
        else if A_Index = 4
            Icon = 4
        else if A_Index = 5
            Icon = 5
        else if A_Index = 6
            Icon = 6
        else if A_Index = 7
            Icon = 7
        else if A_Index = 8
            Icon = 8
        else if A_Index = 9
            Icon = 9
        else if A_Index = 10
            Icon = 0
        break
    }

}       
myfunction=TaskDialogUseMsgBoxOnXP(true)`r`nTaskDialogEx("%main%","%extra%","%title%",%button%,%icon%,%width%,-1,%timeout%)
;~ msgbox % myfunction
GuiControl,,content,%myfunction%
return


view:
Gui, Submit, NoHide

loop 8
{
    if button%a_index%=1
    {
        if A_Index = 1
            button = 1
        else if A_Index = 2
            button = 2
        else if A_Index = 3
            button = 6
        else if A_Index = 4
            button = 56
        else if A_Index = 5
            button = 32
        else if A_Index = 6
            button = 24
        else if A_Index = 7
            button = 48
        else if A_Index = 8
            button = 38
        break
    }

}


loop 10
{
    if icon%a_index%=1
    {
        if A_Index = 1
            Icon = 1
        else if A_Index = 2
            Icon = 2
        else if A_Index = 3
            Icon = 3
        else if A_Index = 4
            Icon = 4
        else if A_Index = 5
            Icon = 5
        else if A_Index = 6
            Icon = 6
        else if A_Index = 7
            Icon = 7
        else if A_Index = 8
            Icon = 8
        else if A_Index = 9
            Icon = 9
        else if A_Index = 10
            Icon = 0
        break
    }

}       
TaskDialogUseMsgBoxOnXP(true)
MsgBox,262208,Notice, % "button clicked："  TaskDialogEx(main,extra,title,button,icon,width,-1,timeout)
return


;just me posted:http://ahkscript.org/boards/viewtopic.php?f=6&t=4635
TaskDialogEx(Main, Extra := "", Title := "Notice：", Buttons := 1, Icon := 8, Width := 600, Parent := -1, TimeOut := 0) {
  Static TDCB      := RegisterCallback("TaskDialogCallback", "Fast")
        , TDCSize   := (4 * 8) + (A_PtrSize * 16)
        , TDBTNS    := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
        , TDF       := {HICON_MAIN: 0x0002, ALLOW_CANCEL: 0x0008, CALLBACK_TIMER: 0x0800, SIZE_TO_CONTENT: 0x01000000}
        , TDICON    := {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
                      , WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8, GRAY: 9
                      , QUESTION: 0}
        , HQUESTION := DllCall("User32.dll\LoadIcon", "Ptr", 0, "Ptr", 0x7F02, "UPtr")
        , DBUX      := DllCall("User32.dll\GetDialogBaseUnits", "UInt") & 0xFFFF
        , OffParent := 4
        , OffFlags  := OffParent + (A_PtrSize * 2)
        , OffBtns   := OffFlags + 4
        , OffTitle  := OffBtns + 4
        , OffIcon   := OffTitle + A_PtrSize
        , OffMain   := OffIcon + A_PtrSize
        , OffExtra  := OffMain + A_PtrSize
        , OffCB     := (4 * 7) + (A_PtrSize * 14)
        , OffCBData := OffCB + A_PtrSize
        , OffWidth  := OffCBData + A_PtrSize
   ; -------------------------------------------------------------------------------------------------------------------
   If ((DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6) {
      If TaskDialogUseMsgBoxOnXP()
         Return TaskDialogMsgBox(Main, Extra, Title, Buttons, Icon, Parent, Timeout)
      Else {
         MsgBox, 16, %A_ThisFunc%, You need at least Win Vista / Server 2008 to use %A_ThisFunc%().
         ErrorLevel := "You need at least Win Vista / Server 2008 to use " . A_ThisFunc . "()."
         Return 0
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Flags := Width = 0 ? TDF.SIZE_TO_CONTENT : 0
   If (Title = "")
      Title := A_ScriptName
   BTNS := 0
   If Buttons Is Integer
      BTNS := Buttons & 0x3F
   Else
      For Each, Btn In StrSplit(Buttons, ["|", " ", ",", "`n"])
         BTNS |= (B := TDBTNS[Btn]) ? B : 0
   ICO := (I := TDICON[Icon]) ? 0x10000 - I : 0
   If Icon Is Integer
      If ((Icon & 0xFFFF) <> Icon) ; caller presumably passed HICON
         ICO := Icon
   If (Icon = "Question")
      ICO := HQUESTION
   If (ICO > 0xFFFF)
      Flags |= TDF.HICON_MAIN
   AOT := Parent < 0 ? !(Parent := 0) : False ; AlwaysOnTop
   ; -------------------------------------------------------------------------------------------------------------------
   PTitle := A_IsUnicode ? &Title : TaskDialogToUnicode(Title, WTitle)
   PMain  := A_IsUnicode ? &Main : TaskDialogToUnicode(Main, WMain)
   PExtra := Extra = "" ? 0 : A_IsUnicode ? &Extra : TaskDialogToUnicode(Extra, WExtra)
   VarSetCapacity(TDC, TDCSize, 0) ; TASKDIALOGCONFIG structure
   NumPut(TDCSize, TDC, "UInt")
   NumPut(Parent, TDC, OffParent, "Ptr")
   NumPut(BTNS, TDC, OffBtns, "Int")
   NumPut(PTitle, TDC, OffTitle, "Ptr")
   NumPut(ICO, TDC, OffIcon, "Ptr")
   NumPut(PMain, TDC, OffMain, "Ptr")
   NumPut(PExtra, TDC, OffExtra, "Ptr")
   If (AOT) || (TimeOut > 0) {
      If (TimeOut > 0) {
         Flags |= TDF.CALLBACK_TIMER
         TimeOut := Round(Timeout * 1000)
      }
      TD := {AOT: AOT, Timeout: Timeout}
      NumPut(TDCB, TDC, OffCB, "Ptr")
      NumPut(&TD, TDC, OffCBData, "Ptr")
   }
   NumPut(Flags, TDC, OffFlags, "UInt")
   If (Width > 0)
      NumPut(Width * 4 / DBUX, TDC, OffWidth, "UInt")
   If !(RV := DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC, "IntP", Result, "Ptr", 0, "Ptr", 0, "UInt"))
      Return TD.TimedOut ? -1 : Result
   ErrorLevel := "The call of TaskDialogIndirect() failed!`nReturn value: " . RV . "`nLast error: " . A_LastError
   Return 0
}
; ======================================================================================================================
; Call this function once passing 1/True if you want a MsgBox to be displayed instead of the task dialog on Win XP.
; ======================================================================================================================
TaskDialogUseMsgBoxOnXP(UseIt := "") {
   Static UseMsgBox := False
   If (UseIt <> "")
      UseMsgBox := !!UseIt
   Return UseMsgBox
}
; ======================================================================================================================
; Internally used functions
; ======================================================================================================================
TaskDialogMsgBox(Main, Extra, Title := "", Buttons := 0, Icon := 0, Parent := 0, TimeOut := 0) {
   Static MBICON := {1: 0x30, 2: 0x10, 3: 0x40, WARN: 0x30, ERROR: 0x10, INFO: 0x40, QUESTION: 0x20}
        , TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16}
   BTNS := 0
   If Buttons Is Integer
      BTNS := Buttons & 0x1F
   Else
      For Each, Btn In StrSplit(Buttons, ["|", " ", ",", "`n"])
         BTNS |= (B := TDBTNS[Btn]) ? B : 0
   Options := 0
   Options |= (I := MBICON[Icon]) ? I : 0
   Options |= Parent = -1 ? 262144 : Parent > 0 ? 8192 : 0
   If ((BTNS & 14) = 14)
      Options |= 0x03 ; Yes/No/Cancel
   Else If ((BTNS & 6) = 6)
      Options |= 0x04 ; Yes/No
   Else If ((BTNS & 24) = 24)
      Options |= 0x05 ; Retry/Cancel
   Else If ((BTNS & 9) = 9)
      Options |= 0x01 ; OK/Cancel
   Main .= Extra <> "" ? "`n`n" . Extra : ""
   MsgBox, % Options, %Title%, %Main%, %TimeOut%
   IfMsgBox, OK
      Return 1
   IfMsgBox, Cancel
      Return 2
   IfMsgBox, Retry
      Return 4
   IfMsgBox, Yes
      Return 6
   IfMsgBox, No
      Return 7
   IfMsgBox, TimeOut
      Return -1
   Return 0
}
; ======================================================================================================================
TaskDialogToUnicode(String, ByRef Var) {
   VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
   StrPut(String, &Var, "UTF-16")
   Return &Var
}
; ======================================================================================================================
TaskDialogCallback(H, N, W, L, D) {
   Static TDM_CLICK_BUTTON := 0x0466
        , TDN_CREATED := 0
        , TDN_TIMER   := 4
   TD := Object(D)
   If (N = TDN_TIMER) && (W > TD.Timeout) {
      TD.TimedOut := True
      PostMessage, %TDM_CLICK_BUTTON%, 2, 0, , ahk_id %H% ; IDCANCEL = 2
   }
   Else If (N = TDN_CREATED) && TD.AOT {
      DHW := A_DetectHiddenWindows
      DetectHiddenWindows, On
      WinSet, AlwaysOnTop, On, ahk_id %H%
      DetectHiddenWindows, %DHW%
   }
   Return 0
}
 