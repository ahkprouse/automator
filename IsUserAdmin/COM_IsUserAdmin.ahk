/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      The Automator                                                  *
 * @version     0.1.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-01-01                                                     *
 * @modified    2025-01-01                                                     *
 * @description                                                                *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
#Requires AutoHotkey v2.0.2+
#SingleInstance Force  ; Limit one running version of this script
DetectHiddenWindows true  ; Ensure can find hidden windows

MsgBox checkAdminMembershipWhoami()  ; Show result of admin check

checkAdminMembershipWhoami() {  ; Checks if user is in admin group
    try {
        ; Create WScript.Shell object to run command
        shell := ComObject("WScript.Shell")
        
        ; Run whoami /groups in hidden mode (0 = hidden window)
        exec := shell.Exec("cmd.exe /c whoami /groups")
        
        ; Wait for command to finish and capture output
        while !exec.Status
            Sleep 10
        output := exec.StdOut.ReadAll()  ; Read command output directly
        
        ; Check for admin group markers in output (case-insensitive)
        if (InStr(output, "BUILTIN\Administrators", false) 
            || InStr(output, "S-1-5-32-544", false))
            return true
        
        return false
    } catch as e {
        MsgBox "Error: " e.Message  ; Show error if something goes wrong
        return false
    }
}

;*************************END OF FILE********************