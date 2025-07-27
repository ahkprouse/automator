/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-03-March                                                  *
 * @modified    2025-03-March                                                  *
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
;@Ahk2Exe-SetVersion     "0.0.1"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <ScriptObject>
#Include <NotifyV2>

DetectHiddenWindows true ;ensure can find hidden windows
ListLines True ;on helps debug a script-this is already on by default
SetWorkingDir A_InitialWorkingDir ;Set the working directory to the scripts directory

; Include the Notify class with the correct path
;#Include S:\lib\v2\Notify\Notify\NotifyV2.ahk

script := {
    base         : ScriptObj(),
    version      : "0.0.1",
    hwnd         : 0,
    author       : "the-Automator",
    email        : "joe@the-automator.com",
    crtdate      : "2025-03-March",
    moddate      : "2025-03-March",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' ,
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "URL Memory",
    homepagelink : "the-automator.com/URLMemory?src=app",
    donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete() ; Clear default menu items
tray.Add("Copy URLs to Clipboard", CopyToClipboard) ; Default action
tray.Default := "Copy URLs to Clipboard" ; Set as default when clicking the tray icon
tray.Add("View Stored URLs", ShowStoredContent)
tray.Add("Clear Stored URLs", ClearStoredContent)
tray.Add() ; Add a separator line
tray.Add("Edit Script", (*) => Edit())
tray.Add("Reload Script", (*) => Reload())
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
tray.Add("Exit", (*) => ExitApp())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
;tray.AddStandard()



; Initialize the variable to store clipboard content
theAutomatorContent := "" ; Variable to store text containing "the-Automator.com"

; Flag to prevent self-triggering when we set the clipboard ourselves
isInternalClipboardChange := false

; Set up an OnClipboardChange event handler
OnClipboardChange ClipboardMonitor

; Set a custom tray icon tooltip
A_IconTip := "the-Automator.com URL Monitor"

; === Auto-Execute section ends here ===

; Hotkeys
^+e::Edit         ;Control+Shift+E to Edit the current script
^+Escape::ExitApp ;Control Shift + Escape will Exit the app
^+r::Reload       ;Reload the current script

; Function that gets called whenever the clipboard content changes
ClipboardMonitor(Type) {
    global theAutomatorContent, isInternalClipboardChange
    
    ; Skip processing if this is our own clipboard change
    if (isInternalClipboardChange)
        return
    
    ; Only process text content (Type=1 means text)
    if (Type = 1) {
        clipText := A_Clipboard ; Get the clipboard content
        
        ; Don't waste time on clipboard content that doesn't contain the-Automator.com
        if (!InStr(clipText, "the-Automator.com"))
            return
            
        ; Parse the clipboard text line by line
        urls := ""
        foundUrl := false
        
        ; Split the clipboard text into lines
        Loop Parse, clipText, "`n", "`r"
        {
            lineText := A_LoopField
            
            ; Find the position of "the-Automator.com" in the current line
            pos := InStr(lineText, "the-Automator.com")
            if (pos) {
                ; Extract a reasonable URL from the line
                startPos := pos
                endPos := pos + 16  ; Length of "the-Automator.com"
                
                ; Look backward to find start of URL (http:// or https://)
                while (startPos > 1) {
                    if (SubStr(lineText, startPos-1, 1) ~= "[^\w\-\./:]")
                        break
                    startPos--
                    
                    ; If we found "http", stop looking back
                    if (startPos >= 4 && SubStr(lineText, startPos-4, 4) = "http")
                        break
                }
                
                ; Look forward to find end of URL (typically space, quote, etc.)
                while (endPos <= StrLen(lineText)) {
                    if (SubStr(lineText, endPos, 1) ~= "[^\w\-\./]")
                        break
                    endPos++
                }
                
                ; Extract the URL
                extractedUrl := SubStr(lineText, startPos, endPos - startPos)
                
                ; Clean up the URL prefix - remove any malformed prefixes
                extractedUrl := RegExReplace(extractedUrl, "^(s://)+", "")
                
                ; Add http:// prefix if missing
                if (!RegExMatch(extractedUrl, "^https?://"))
                    extractedUrl := "https://" . extractedUrl
                else if (RegExMatch(extractedUrl, "^(https?://)+(https?://)*"))
                    extractedUrl := RegExReplace(extractedUrl, "^(https?://)+", "https://")
                
                ; Remove any query parameters (everything after ?)
                if (InStr(extractedUrl, "?"))
                    extractedUrl := StrSplit(extractedUrl, "?")[1]
                
                urls .= extractedUrl . "`n"
                foundUrl := true
            }
        }
        
        ; If we found URLs, process them
        if (foundUrl) {
            ; Remove the trailing newline
            urls := RTrim(urls, "`n")
            
            ; Process each extracted URL
            Loop Parse, urls, "`n"
            {
                url := A_LoopField
                
                ; Add to our list if it's not already there
                if (!InStr(theAutomatorContent, url)) {
                    ; Add a line break if this isn't the first entry
                    if (theAutomatorContent != "")
                        theAutomatorContent .= "`n"
                    
                    theAutomatorContent .= url
                    
                    ; Sort the content alphabetically
                    theAutomatorContent := Sort(theAutomatorContent)
                    
                    ; Count URLs
                    urlCount := 0
                    if (theAutomatorContent != "") {
                        urlCount := 1  ; Start with 1 for the first line
                        Loop Parse, theAutomatorContent, "`n"
                            urlCount := A_Index
                    }
                    
                    ; Show notification using Notify class
                    Notify.Show({
                        HDText: "URL Added",
                        BDText: "Added: " . url . "`nTotal unique URLs: " . urlCount,
                        GenIcon: "Information",
                        GenDuration: 3
                    })
                }
                ; Silently ignore duplicates - no notification needed
            }
        }
    }
}

; Function to display the stored content in a new GUI
ShowStoredContent(*) {
    global theAutomatorContent
    
    if (theAutomatorContent = "") {
        Notify.Show({
            HDText: "Nothing Stored",
            BDText: "No URLs have been collected yet.",
            GenIcon: "Exclamation",
            GenDuration: 2
        })
        return
    }
    
    ; Create a new GUI to show the content
    contentGui := Gui(, "Stored the-Automator.com URLs")
    contentGui.MarginX := 10
    contentGui.MarginY := 10
    contentGui.Add("Text",, "URLs collected from clipboard:")
    contentGui.Add("Edit", "r20 w600 ReadOnly vContentEdit", theAutomatorContent)
    contentGui.Show("w620 h390") ; Adjusted size to be closer to edit control size
}

; Function to copy the stored content to clipboard
CopyToClipboard(*) {
    global theAutomatorContent, isInternalClipboardChange
    
    if (theAutomatorContent = "") {
        Notify.Show({
            HDText: "Nothing Stored",
            BDText: "No URLs have been collected yet.",
            GenIcon: "Exclamation",
            GenDuration: 2
        })
        return
    }
    
    ; Set the flag to prevent self-triggering
    isInternalClipboardChange := true
    
    ; Copy to clipboard
    A_Clipboard := theAutomatorContent
    
    ; Show notification
    Notify.Show({
        HDText: "Copied to Clipboard",
        BDText: "All stored URLs have been copied to your clipboard!",
        GenIcon: "Information",
        GenDuration: 2
    })
    
    ; Reset the flag after a short delay to allow clipboard processing to complete
    SetTimer(() => isInternalClipboardChange := false, -500)
}

; Function to clear the stored content
ClearStoredContent(*) {
    global theAutomatorContent
    
    if (MsgBox("Are you sure you want to clear all stored URLs?", "Clear Content", "YesNo") = "Yes") {
        theAutomatorContent := ""
        Notify.Show({
            HDText: "URLs Cleared",
            BDText: "All stored URLs have been cleared.",
            GenIcon: "Information",
            GenDuration: 2
        })
    }
}