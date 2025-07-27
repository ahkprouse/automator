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

; Create a GUI to display admin status information
adminGui := Gui("+Resize", "Windows Admin Status Check")
adminGui.SetFont("s10")
adminGui.Add("Text", "w500", "Checking administrative privileges...")

; Run different admin check methods
isElevated := IsProcessElevated()
isAdminGroup := IsUserInAdminGroup()

; Create text controls for detailed status information
resultText := adminGui.Add("Text", "w500 h20 y+10", "")
elevatedText := adminGui.Add("Text", "w500 h20 y+10", "")
adminGroupText := adminGui.Add("Text", "w500 h20 y+10", "")
infoText := adminGui.Add("Edit", "w500 h100 y+10 ReadOnly", "")

; Update the GUI with results
if (isElevated) {
    resultText.Value := "STATUS: Script is running WITH elevated privileges (as Administrator)"
    resultText.Opt("cGreen") 
    ; Make font bold by setting it directly
    adminGui.SetFont("s10 bold")
    resultText.SetFont()
    adminGui.SetFont("s10 norm") ; Reset font weight
} else {
    resultText.Value := "STATUS: Script is NOT running with elevated privileges"
    resultText.Opt("cRed")
    ; Make font bold by setting it directly
    adminGui.SetFont("s10 bold")
    resultText.SetFont()
    adminGui.SetFont("s10 norm") ; Reset font weight
}

elevatedText.Value := "Process elevation status: " . (isElevated ? "Elevated" : "Not elevated")
adminGroupText.Value := "Current user in admin group: " . (isAdminGroup ? "Yes" : "No")

; Add explanatory information
infoText.Value := "IMPORTANT: Even if you are in the administrators group, Windows UAC may prevent " 
    . "processes from running with full admin rights unless specifically run as administrator. "
    . "Right-click the script and select 'Run as administrator' to run with elevated privileges."

; Add a button to relaunch with admin privileges
restartButton := adminGui.Add("Button", "w200 h30 y+10", "Restart as Administrator")
restartButton.OnEvent("Click", RestartAsAdmin)

; Add a close button
closeButton := adminGui.Add("Button", "w120 h30 x+20", "Close")
closeButton.OnEvent("Click", (*) => adminGui.Destroy())

; Show the GUI
adminGui.Show()

; Function to check if the current process is elevated (running as admin)
IsProcessElevated() {
    ; This function checks if the current process has elevated privileges
    ; (i.e., was launched with "Run as administrator")
    
    try {
        ; Open the current process token
        hToken := 0
        if (!DllCall("advapi32\OpenProcessToken", "Ptr", DllCall("GetCurrentProcess"), "UInt", 0x0008, "Ptr*", &hToken))
            return false
        
        ; Check token elevation
        tokenElevation := Buffer(4, 0)
        cbSize := 0
        result := DllCall("advapi32\GetTokenInformation", "Ptr", hToken, "Int", 20, "Ptr", tokenElevation, "UInt", tokenElevation.Size, "UInt*", &cbSize)
        
        ; Close the token handle
        DllCall("CloseHandle", "Ptr", hToken)
        
        ; Return the elevation status
        if (result)
            return NumGet(tokenElevation, 0, "UInt") != 0
    } catch {
        return false
    }
    
    return false
}

; Function to check if the user belongs to the administrators group
IsUserInAdminGroup() {
    ; This function checks if the current user is a member of the
    ; administrators group, regardless of elevation status
    
    try {
        ; Create a buffer for SID (security identifier)
        sidSize := 0
        ; First call to get required buffer size
        DllCall("advapi32\CreateWellKnownSid", "Int", 26, "Ptr", 0, "Ptr", 0, "UInt*", &sidSize) ; 26 = WinBuiltinAdministratorsSid
        
        ; Create buffer of the required size
        sidBuffer := Buffer(sidSize, 0)
        
        ; Second call to fill the buffer
        if (!DllCall("advapi32\CreateWellKnownSid", "Int", 26, "Ptr", 0, "Ptr", sidBuffer, "UInt*", &sidSize))
            return false
        
        ; Check if current user is a member of the group
        isMember := 0
        if (!DllCall("advapi32\CheckTokenMembership", "Ptr", 0, "Ptr", sidBuffer, "Int*", &isMember))
            return false
        
        return isMember != 0
    } catch {
        return false
    }
    
    return false
}

; Function to restart the script with admin privileges
RestartAsAdmin(*) {
    ; This function restarts the current script with administrative privileges
    
    try {
        ; Get the full path of the current script
        scriptPath := A_ScriptFullPath
        
        ; Use RunAs to launch the script with admin privileges
        Run '*RunAs "' A_AhkPath '" "' scriptPath '"'
        
        ; Exit the current instance
        ExitApp
    } catch Error as e {
        MsgBox "Error attempting to restart with admin privileges: " e.Message
    }
}

;*************************END OF FILE********************