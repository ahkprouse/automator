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
#SingleInstance Force ;Limit one running version of this script
DetectHiddenWindows true ;ensure can find hidden windows

; Get the current username
currentUser := A_UserName



; Check if user is in admin group using command line method
checkAdminMembershipCmd() {
    ; This function uses the "net localgroup administrators" command to check membership
    
    try {
        ; Create a temporary file to store command output
        tempFile := A_Temp "\admin_check_" A_TickCount ".txt"
        
        ; Run the command and redirect output to our temp file
        RunWait "cmd.exe /c net localgroup administrators > " tempFile, , "Hide"
        
        ; Read the file contents
        if FileExist(tempFile) {
            fileObj := FileOpen(tempFile, "r")
            if (fileObj) {
                output := fileObj.Read()
                fileObj.Close()
                
                ; Delete the temp file
                FileDelete tempFile
                
                ; Check if current username is in the output
                if (InStr(output, A_UserName)) {
                    return true
                }
            }
        }
        
        return false
    } catch {
        return false
    }
}

; Another method using whoami command
checkAdminMembershipWhoami() {
    ; This function uses the "whoami /groups" command to check membership
    
    try {
        ; Create a temporary file to store command output
        tempFile := A_Temp "\whoami_check_" A_TickCount ".txt"
        
        ; Run the command and redirect output to our temp file
        RunWait "cmd.exe /c whoami /groups > " tempFile, , "Hide"
        
        ; Read the file contents
        if FileExist(tempFile) {
            fileObj := FileOpen(tempFile, "r")
            if (fileObj) {
                output := fileObj.Read()
                fileObj.Close()
                
                ; Delete the temp file
                FileDelete tempFile
                
                ; Check for admin group markers in output
                if (InStr(output, "BUILTIN\Administrators") || InStr(output, "S-1-5-32-544")) {
                    return true
                }
            }
        }
        
        return false
    } catch {
        return false
    }
}

; Run the checks and display results
isAdminCmd := checkAdminMembershipCmd()
isAdminWhoami := checkAdminMembershipWhoami()

; Show results
resultText := "Current user: " currentUser "`n`n"
resultText .= "Admin group membership check results:`n"
resultText .= "- NET LOCALGROUP method: " (isAdminCmd ? "YES" : "NO") "`n"
resultText .= "- WHOAMI method: " (isAdminWhoami ? "YES" : "NO") "`n`n"

; Also check built-in AHK admin status
resultText .= "AutoHotkey built-in admin check (A_IsAdmin): " (A_IsAdmin ? "YES" : "NO") "`n"
resultText .= "Note: A_IsAdmin checks if the script is running elevated, not if your`n"
resultText .= "account is in the Administrators group.`n`n"

resultText .= "To see a full list of your group memberships manually, open Command Prompt`n"
resultText .= "and type: whoami /groups"

MsgBox resultText, "Admin Group Membership Check"

; Function you can call from other scripts
IsUserInAdminGroup() {
    ; Returns true if user is in admin group, false otherwise
    ; Tries both methods and returns true if either succeeds
    return checkAdminMembershipCmd() || checkAdminMembershipWhoami()
}

;*************************END OF FILE********************