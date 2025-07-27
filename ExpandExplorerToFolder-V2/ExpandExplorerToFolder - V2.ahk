#Requires AutoHotkey v2.0
#SingleInstance Force

;--
;@Ahk2Exe-SetVersion     0.1.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Setting Scrollbar
;@Ahk2Exe-SetDescription Setting Scrollbar by the-Automator
/*
/**
 * ============================================================================ *
 * @Author   : Joe                                                              *
 * @Homepage : the-automator.com                                                *
 *                                                                              *
 * @Created  : August 28, 2024                                                  *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/

OnError logerrors

Logerrors(err, mode)
{
    line := err.What '`t' err.extra '`t' err.Message '`t' err.Line '`t' err.File '`n'
    FileAppend line, 'error.log', 'utf-8'
    return -1
}

TraySetIcon("C:\WINDOWS\system32\shell32.dll", 299)
RegeExplorer := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
; Set "Expand to open folder"
RegWrite 1, "REG_DWORD", RegeExplorer , "NavPaneExpandToCurrentFolder"
RegWrite 1, "REG_DWORD", RegeExplorer , "NavPaneShowAllFolders"
; Restart Explorer to apply changes
MsgBox 'Windows Explorer settings have been updated. Changes applied:`n- Expand to open folder: ON`n- Show all folders: ON','Close Explorer',262208
WinWaitClose "Close Explorer"
RestartApplication("ahk_class CabinetWClass")
return

RestartApplication(App)
{
    while WinExist(app)
            WinClose(app) ; kill program
}