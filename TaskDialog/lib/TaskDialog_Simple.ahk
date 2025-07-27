; ======================================================================================================================
; TaskDialog -> msdn.microsoft.com/en-us/library/bb760540(v=vs.85).aspx
; Main:     String to be used for the main instruction (mandatory).
; Extra:    String used for additional text that appears below the main instruction (optional).  Default: 0 - no additional text.
; Title:    String to be used for the task dialog title (optional).          Default: "" - A_ScriptName.
; Buttons:  Specifies the push buttons displayed in the dialog box (optional).
;           This parameter may be a combination of the integer values defined in TDBTNS or a pipe (|) separated list of the string keys.
;           Default: 0 - OK button
; Icon:     Specifies the icon to display in the task dialog (optional). This parameter can be one of the keys defined in TDICON. Default: 0 - no icon
; Parent:   HWND of the owner window of the task dialog to be created(optional).    If specified, the task dialog will become modal.  Default: 0 - no owner window
; Returns:  An integer value identifying the button pressed by the user:
;           1 = OK, 2 = CANCEL, 4 = RETRY, 6 = YES, 7 = NO, 8 = CLOSE
;           If the function fails, ErrorLevel will be set to 1 and the return value will be empty.
; ======================================================================================================================
TaskDialog(Main, Extra := 0, Title := "", Buttons := 0, Icon := 0, Parent := 0) {
   Static S_OK := 0
   Static TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
   Static TDICON := {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
                   , WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8, GRAY: 9}
   If ((DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6) {
      MsgBox, 16, %A_ThisFunc%, This function requires Windows Vista or newer!
      Return
   }
   BTNS := 0
   If Buttons Is Integer
      BTNS := Buttons & 0x3F
   Else
      For Each, Btn In StrSplit(Buttons, "|")
         BTNS |= (B := TDBTNS[Btn]) ? B : 0
   ICO := (I := TDICON[Icon]) ? 0x10000 - I : 0
   If (S_OK = DllCall("Comctl32.dll\TaskDialog"
                    , "Ptr",  Parent
                    , "Ptr",  0
                    , "WStr", Title = "" ? A_ScriptName : Title
                    , "WStr", Main
                    , Extra = 0 ? "Ptr" : "WStr",  Extra
                    , "UInt", BTNS
                    , "Ptr",  ICO
                    , "IntP", Result))
      Return Result
   ErrorLevel := 1
}