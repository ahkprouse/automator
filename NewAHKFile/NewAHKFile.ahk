/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      Joe G                                                          *
 * @version     1.2.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-02-07                                                     *
 * @modified    2025-02-25                                                     *
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
#SingleInstance Force ; Limit one running version of this script
DetectHiddenWindows true ; Ensure can find hidden windows

/*****************Place in Running Script or use here***************
#HotIf WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Cursor.exe") || WinActive("ahk_exe explorer.exe") ;If Explorer is active it will Edit with VS code
^n:: Run "S:\NewAHKFile\NewAHKFile.ahk" ; Update to your path where the below file is located
#HotIf ; End WinActive condition
 ********************************************************************/


; Font size variable - adjust this to change all GUI text size
guiFontSize := 13

; Path variables (edit these as needed)
saveFolder := "S:\_Client_work\Joe_G\" ; Folder for saving scripts
editorPathVSCode := A_AppData "\..\Local\Programs\Microsoft VS Code\Code.exe" ; Path to VS Code
editorPathCursor := A_AppData "\..\Local\Programs\cursor\Cursor.exe" ; Path to Cursor
; Template for new AutoHotkey script
scriptTemplate := 
( 
    "#Requires AutoHotkey v2.0.2+
    #SingleInstance Force ; Limit one running version of this script
    DetectHiddenWindows true ; Ensure can find hidden windows
    TraySetIcon('S:\lib\Icons\Progs\trash.ico') ;Update path to your icon 
    A_TrayMenu.Add('Open Folder', openFolder)
    A_TrayMenu.SetIcon('Open Folder','shell32.dll',4)
    openFolder(*) => Run(A_ScriptDir)

    "
)

if !FileExist(editorPathCursor) 
|| !FileExist(editorPathVSCode) {
    MsgBox 'Could not find cursor or vscode', 'Error', 'IconX 0x1000'
    ExitApp()
}

; Trigger when VS Code or Cursor is active
global myGui ; Declare myGui as global for use in event handlers

; Create a custom GUI for file name input
myGui := Gui()
myGui.Title := "New AHK File"

; Set the font for all GUI controls
myGui.SetFont("s" . guiFontSize, "Segoe UI")

myGui.Add("Text",, "File name (with/without .ahk):")
editField := myGui.Add("Edit", "vfileNameInput w250", "")
myGui.Add("Button", "default x+m w80 h35", "OK").OnEvent("Click", SubmitGui)
myGui.Add("Button", "x+m yp w80 h35", "Cancel").OnEvent("Click", CancelGui)
myGui.Add('Text','xm',"Template:")
myGui.Add('Edit','vscriptTemplate xm w500 Multi r9',scriptTemplate)
myGui.Show() 

; Add escape key handler for when GUI is active
myGui.OnEvent("Escape", ExitScript) ;Escape will Exit / Cancel 

; GUI event handlers
SubmitGui(*) {
    global myGui, fileNameInput
    myGui.Submit()
    if !fileNameInput := editField.Value ; Get the entered file name
        fileNameInput := "Temp Script" ; Default name if empty

    ContinueScript()
    myGui.Destroy()
}

CancelGui(*) {
    global myGui
    myGui.Destroy()
    return
}

ExitScript(*) {
    ExitApp() ; Exit the entire script when Escape is pressed
}

ContinueScript() {
    global fileNameInput, newFileName
    
    ; Ensure the file has .ahk extension
    if !InStr(fileNameInput, ".ahk") {
        fileNameInput .= ".ahk"
    }
    scriptTemplate := myGui["scriptTemplate"].Value ; Get the template from the GUI
    ; Generate unique filename if file already exists
    newFileName := GenerateUniqueFileName(saveFolder, fileNameInput)
    
    ; Write template to new file with proper file handling
    try {
        fileObject := FileOpen(newFileName, "w", "UTF-8") ; Open file for writing
        if (fileObject) {
            fileObject.Write(scriptTemplate) ; Write the template
            fileObject.Close() ; Close and unlock the file
        } else {
            MsgBox "Failed to create file: " newFileName
            return
        }
    } catch as err {
        MsgBox "Error writing to file: " err.Message
        return
    }
    
    ; Verify file exists before opening
    if FileExist(newFileName) {
        try {
            ; Determine which editor is active and set its path
            editorPath := WinActive("ahk_exe Cursor.exe") 
                ? editorPathCursor ; Use Cursor path
                : editorPathVSCode ; Use VS Code path
            Run '"' editorPath '" "' newFileName '"' ; Open file in the active editor
        } catch as err {
            MsgBox "Failed to open file in editor: " err.Message "`nFile created at: " newFileName
            return
        }
    } else {
        MsgBox "File was not created: " newFileName
        return
    }
}

; Generate unique filename by incrementing number if file exists
GenerateUniqueFileName(folderPath, fileName) {
    fullPath := folderPath . fileName ; Create full path with folder and filename
    
    ; If file doesn't exist, return original path
    if !FileExist(fullPath) {
        return fullPath
    }
    
    ; Split filename and extension
    baseName := RegExReplace(fileName, "\.[^.]*$", "") ; Remove extension
    dotPosition := InStr(fileName, ".", , -1) ; Find last dot position (search from end)
    extension := SubStr(fileName, dotPosition) ; Get extension (.ahk)
    
    ; Check if filename ends with a digit
    if RegExMatch(baseName, "(\d+)$", &match) {
        ; Extract the number and increment it
        currentNumber := Integer(match[1]) ; Convert matched number to integer
        baseNameWithoutNumber := SubStr(baseName, 1, match.Pos - 1) ; Get filename without the number
        
        ; Keep incrementing until we find an available filename
        loop {
            currentNumber++ ; Increment the number
            newBaseName := baseNameWithoutNumber . currentNumber ; Create new base name
            newFullPath := folderPath . newBaseName . extension ; Create full path
            
            if !FileExist(newFullPath) {
                return newFullPath ; Return when we find available filename
            }
        }
    } else {
        ; Filename doesn't end with digit, start with 2
        newBaseName := baseName . "2" ; Add "2" to the end
        newFullPath := folderPath . newBaseName . extension ; Create full path
        
        ; If that exists too, keep incrementing
        if FileExist(newFullPath) {
            counter := 3 ; Start from 3 since we tried 2
            loop {
                newBaseName := baseName . counter ; Create new base name with counter
                newFullPath := folderPath . newBaseName . extension ; Create full path
                
                if !FileExist(newFullPath) {
                    return newFullPath ; Return when we find available filename
                }
                counter++ ; Increment counter for next attempt
            }
        } else {
            return newFullPath ; Return if filename with "2" is available
        }
    }
}

;*************************END OF FILE********************