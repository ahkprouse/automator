
/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      Joe Glines                                                     *
 * @version     0.1.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-06-01                                                     *
 * @modified    2025-06-18                                                     *
 * @description                                                                *
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
;@Ahk2Exe-SetVersion     "0.1.0"
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 

#Requires AutoHotkey v2.0.2+
#SingleInstance Force ;Limit one running version of this script
DetectHiddenWindows true ;ensure can find hidden windows
ListLines True ;on helps debug a script-this is already on by default
SetWorkingDir A_InitialWorkingDir ;Set the working directory to the scripts directory

#Include <ScriptObject>
#Include <Func>
#Include <Triggers>
Persistent ; Keep script running

; Script object to store global script info
script := {
    base         : ScriptObj(),
    version      : "0.1.0",
    hwnd         : 0,
    author       : "Joe Glines",
    email        : "joe@the-automator.com",
    crtdate      : "",
    moddate      : "",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' ,
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "SimpleTextSender",
    title        : "Simple Text Sender",
    homepagelink : "the-automator.com/SimpleTextSender?src=app",
    Davpath      : "S:\Simple Menu\SimpleTextSender.ahk",
    donateLink   : "" ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}
TraySetIcon("C:\Windows\system32\pifmgr.dll", 15)
; Create the GUI
myGui := Gui("+Resize", script.title)
myGui.SetFont("s12", "Segoe UI")

; Load saved text from INI file - convert \n back to newlines
savedRawContent := IniRead(script.config, "TextStorage", "Content", "Enter your text here")
; Convert \n back to actual newlines
savedContent := StrReplace(savedRawContent, "\n", "`n")

; Add instructions
myGui.AddText("xm w580", "Enter text items below. Each line will become a menu item.")
myGui.AddText("xm y+5 w580", "Use the ¶ symbol to create line breaks when the text is pasted.")

; Add the edit control
editBox := myGui.Add("Edit", "xm y+10 w580 h300 Multi WantTab", savedContent)

; Add buttons
saveButton := myGui.Add("Button", "xm y+15 w120 h30", "Save")
saveButton.OnEvent("Click", SaveText)

insertLineButton := myGui.Add("Button", "x+15 w150 h30", "Insert New Line")
insertLineButton.OnEvent("Click", InsertNewLine)

closeButton := myGui.Add("Button", "x+15 w120 h30", "Close")
closeButton.OnEvent("Click", GuiClose)

; Set up event handlers
myGui.OnEvent("Close", GuiClose)
myGui.OnEvent("Size", GuiResize)

; Set up hotkey to display the text menu - with trayAction=true to show in tray
triggers.AddHotkey(ShowTextMenu, "Display Text Menu", '^t', "", true)

; Add our Edit Text Items option to tray
A_TrayMenu.Add("Edit Text Items", ShowEditor)
A_TrayMenu.Default := "Edit Text Items"
; Just let Triggers finish the menu
triggers.FinishMenu()
triggers.tray.AddStandard
; Show the GUI
myGui.Show()

; Add hotkeys for the script
; ^+e::Edit           ;Control+Shift+E to Edit the current script
; ^+Escape::Exitapp   ;Control Shift + Escape will Exit the app
; ^+r::Reload         ;Reload the current script

; Function to show the editor
ShowEditor(*) {
    global myGui
    myGui.Show()
    return
}

; Function to show the text menu
ShowTextMenu(*) {
    ; Custom function to show menu and handle paragraph marks
    CustomTextMenu()
    return
}

; Function to create and show a custom menu
CustomTextMenu() {
    ; Create a menu
    myMenu := Menu()

    ; Load saved text items directly - with special handling for newlines
    savedRawContent := IniRead(script.config, "TextStorage", "Content", "")
    savedContent := StrReplace(savedRawContent, "\n", "`n")  ; Convert \n to actual newlines

    ; Split by newlines to create menu items
    for menuItem in StrSplit(savedContent, "`n") {
        if (menuItem != "")  ; Skip empty items
            myMenu.Add(menuItem, CustomAction)
    }

    ; Show the menu
    myMenu.Show()
}

; Function that handles menu item selection
CustomAction(ItemName, *) {
    ; Store original clipboard
    oldClip := ClipboardAll()

    ; Replace paragraph marks with actual newlines
    processedText := StrReplace(ItemName, "¶", "`n")

    ; Copy to clipboard
    A_Clipboard := processedText

    ; Send paste command
    Send("^v")

    ; Wait for paste to complete
    Sleep(1000)

    ; Restore original clipboard
    A_Clipboard := oldClip
    return
}

; Function to handle GUI resize
GuiResize(thisGui, minMax, width, height) {
    global editBox, saveButton, insertLineButton, closeButton

    if (minMax = -1) ; If window is minimized
        return

    ; Calculate positions
    buttonHeight := 30
    margin := 10
    buttonY := height - buttonHeight - margin

    ; Get button widths
    closeButton.GetPos(&closeX, &closeY, &closeWidth, &closeHeight)
    saveButton.GetPos(&saveX, &saveY, &saveWidth, &saveHeight)

    ; Adjust edit box to fill most of the space
    editBox.Move(margin, margin, width - (2 * margin), buttonY - (2 * margin))

    ; Position buttons at the bottom
    insertLineButton.Move(margin, buttonY)

    ; Calculate right-aligned positions for Save and Close buttons
    closeX := width - closeWidth - margin
    saveX := closeX - saveWidth - margin

    ; Position Save and Close buttons at bottom right
    saveButton.Move(saveX, buttonY)
    closeButton.Move(closeX, buttonY)
}

; Function to insert paragraph symbol at cursor position
InsertNewLine(*) {
    global editBox, myGui

    ; Focus the control
    ControlFocus(editBox, myGui)
    Send("¶") ; Insert the paragraph symbol
    return
}

; Function to save text to INI file
SaveText(*) {
    global editBox

    ; Get content from edit box
    savedContent := editBox.Value

    ; Replace actual newlines with \n for storage
    iniContent := StrReplace(savedContent, "`n", "\n")

    ; Save the modified content
    IniWrite(iniContent, script.config, "TextStorage", "Content")
    triggers.ApplyTriggers()
    ; Show a brief save confirmation
    ToolTip("Text saved")
    SetTimer () => ToolTip(), -1000

    return
}

; Function to handle GUI close
GuiClose(*) {
    global myGui

    ; Save content before closing
    SaveText()

    ; Hide the GUI
    myGui.Hide()

    return
}