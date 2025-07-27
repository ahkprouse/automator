/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-09-Apr                                                    *
 * @modified    2025-09-Apr                                                    *
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
;@Ahk2Exe-SetVersion     "0.0.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <ScriptObject>

script := {
    base         : ScriptObj(),
    version      : "0.0.0",
    hwnd         : 0,
    author       : "the-Automator",
    email        : "joe@the-automator.com",
    crtdate      : "2025-Apr-09",
    moddate      : "2025-Apr-09",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "OpenScriptinVscode",
    homepagelink : "the-automator.com/OpenScriptinVscode?src=app",
    Devpath      : "S:\Open Script in Vscode\Open Script in Vscode.ahk",
    donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
tray.Add()
tray.AddStandard()

; Create GUI
myGui := Gui("", "Configure Script Editor")
myGui.SetFont("s10")
myGui.Add("Text", "w400", "Provide the path VS code or cursor.")
; Add custom path option
;myGui.Add("Text", "xm w400", "Add VScode editor path:")
customPath := myGui.Add("Edit", "w400 vCustomPath")
browseBtn := myGui.Add("Button", "w100", "Browse...")
browseBtn.OnEvent("Click", BrowseForEditor)

; Add buttons
installBtn := myGui.Add("Button", "xm w100", "Install")
installBtn.OnEvent("Click", InstallEditor)
cancelBtn := myGui.Add("Button", "x+10 w100", "Cancel")
cancelBtn.OnEvent("Click", (*) => myGui.Destroy())

; Show the GUI
myGui.Show()

; Function to browse for a custom editor
BrowseForEditor(*)
{
    global customPath
    selectedFile := FileSelect("1", "", "Select Editor", "Applications (*.exe)")
    if selectedFile
        customPath.Value := selectedFile
}

; Function to install the selected editor configuration
InstallEditor(*)
{
    global myGui
    
    ; Get values from GUI
    savedValues := myGui.Submit(false)  ; false = don't hide GUI
    
    ; Create helper script path
    helperScriptPath := A_ScriptDir "\OpenWithEditor.ahk"
    
    ; Determine which editor to use
    editorCmd := ""
    if savedValues.CustomPath  ; Custom path
    {
        SplitPath(savedValues.CustomPath, &editorExe)
        editorCmd := '"' . savedValues.CustomPath . '" .@'
    }
    else
    {
        MsgBox "Please select an editor or provide a custom path."
        return
    }
    
    ; Create the helper script
    try
    {
        helperScript := 
        (
'#Requires AutoHotkey v2.0
if A_Args.Length
{
    filePath := A_Args[1]
    SplitPath(filePath,,&folderPath)
    cmd := A_ComSpec  /c ' editorCmd '
    Run(cmd, folderPath, "Hide")
}'
        )
        
        ; Save the helper script
        if FileExist(helperScriptPath)
            FileDelete(helperScriptPath)
        
        helperScript := StrReplace(helperScript,"A_ComSpec","A_ComSpec '")
        helperScript := StrReplace(helperScript,"@","'")
        FileAppend(helperScript, helperScriptPath)
        
        ; Update registry
        regPath := "HKEY_CLASSES_ROOT\AutoHotkeyScript\shell\edit\command"
        regValue := '"' . A_AhkPath . '" "' . helperScriptPath . '" "%1"'
        RegWrite(regValue, "REG_SZ", regPath)
        
        MsgBox 'Now your editor will open the folder, instead of the file`nTo test this, right click on an AutoHotkey file in Explorer and choose "edit"'
        myGui.Destroy()
    }
    catch as err
    {
        MsgBox "Error updating registry: " . err.Message
    }
}