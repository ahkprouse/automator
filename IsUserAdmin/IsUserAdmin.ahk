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
#Requires AutoHotkey v2.0
MsgBox checkAdminMembershipWhoami()

checkAdminMembershipWhoami() {
    try {
        ; Create a temporary file to store command output
        tempFile := A_Temp '\whoami_check_' A_TickCount '.txt'
        RunWait 'cmd.exe /c whoami /groups > ' tempFile, , 'Hide'         ; Run the command silently with hidden window
        
        ; Read the file contents
        if FileExist(tempFile) {
            output := FileRead(tempFile)
            FileDelete tempFile ; Delete the temp file
        
            ; Check for admin group markers in output (case-insensitive)
            if (InStr(output, "BUILTIN\Administrators", false) 
            || InStr(output, "S-1-5-32-544", false)) 
                return true
        }
        
        return false
    } catch as e {
        MsgBox "Error: " e.Message
        return false
    }
}

