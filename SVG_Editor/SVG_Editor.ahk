/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      Joe G                                                          *
 * @version     0.1.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-06-01                                                     *
 * @modified    2025-07-02                                                     *
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
; Include WebView2 library and Notification library
#Include <WebView2>
#Include <NotifyV2>
#include <ScriptObject>

script := {
	        base : ScriptObj(),
	     version : "0.1.0",
	        hwnd : 0,
	      author : "Joe Glines",
	       email : "joe@the-automator.com",
	     crtdate : "2024-06-01",
	     moddate : "2025-07-02",
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'imageres.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	      config : "",
	homepagetext : "SVG Editor",
	homepagelink : "the-automator.com//SVGEditor?src=app",
	  donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
TraySetIcon("imageres.dll", 160) ;grey,orange,yellow,blue,image
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.Add('Open Folder', openFolder)
tray.SetIcon('Open Folder','shell32.dll',4)
openFolder(*) => Run(A_ScriptDir)
tray.AddStandard()


; Global variables
mainGui := ""
codeEdit := ""
previewText := ""
previewBrowser := ""
currentZoom := 150 ; Start at 150% zoom
zoomLabel := ""
lastScrollX := 0 ; Track horizontal scroll position
lastScrollY := 0 ; Track vertical scroll position

; Function to update the preview when code changes
UpdatePreview(*) {
    global lastScrollX, lastScrollY
    svgCode := codeEdit.Text
    if (svgCode = "") {
        return ; Don't update if empty
    }
    
    ; Save current scroll position if browser is available
    if (previewBrowser != "") {
        try {
            ; Get current scroll position before updating
            if (previewBrowser.value.Document && previewBrowser.value.Document.documentElement) {
                lastScrollX := previewBrowser.value.Document.documentElement.scrollLeft
                lastScrollY := previewBrowser.value.Document.documentElement.scrollTop
            }
        } catch {
            ; If we can't get scroll position, keep last known values or use 0
            if (!IsSet(lastScrollX)) {
                lastScrollX := 0
            }
            if (!IsSet(lastScrollY)) {
                lastScrollY := 0
            }
        }
    }
    
    ; Create HTML wrapper for the SVG
    htmlContent := "<!DOCTYPE html><html><head><style>body{margin:0;padding:10px;background:#f5f5f5;font-family:Arial,sans-serif;}.container{background:white;border:1px solid #ddd;border-radius:4px;padding:10px;box-shadow:0 2px 4px rgba(0,0,0,0.1);}svg{max-width:100%;height:auto;display:block;}</style></head><body><div class=`"container`">" . svgCode . "</div></body></html>"
    
    ; Update preview based on what's available
    if (previewBrowser != "") {
        ; Use WebBrowser to render HTML with SVG - add IE compatibility and zoom
        htmlContent := "<!DOCTYPE html><html><head><meta http-equiv=`"X-UA-Compatible`" content=`"IE=edge`"><style>body{margin:0;padding:10px;background:#f5f5f5;font-family:Arial,sans-serif;zoom:" . currentZoom . "%;}.container{background:white;border:1px solid #ddd;border-radius:4px;padding:10px;box-shadow:0 2px 4px rgba(0,0,0,0.1);}svg{max-width:100%;height:auto;display:block;}</style></head><body><div class=`"container`">" . svgCode . "</div><script>window.onload=function(){document.documentElement.scrollLeft=" . lastScrollX . ";document.documentElement.scrollTop=" . lastScrollY . ";}</script></body></html>"
        
        ; Create a temporary HTML file
        tempFile := A_Temp . "\svg_preview.html"
        try {
            fileObj := FileOpen(tempFile, "w", "UTF-8")
            if (fileObj) {
                fileObj.Write(htmlContent)
                fileObj.Close()
                previewBrowser.value.Navigate("file:///" . StrReplace(tempFile, "\", "/"))
            }
        }
    } else if (previewText != "") {
        ; Fallback to showing raw SVG text
        previewText.Text := svgCode
    }
}

; Function to handle window resizing
ResizeControls(guiObj, minMax, width, height) {
    if (minMax = -1) { ; Minimized
        return
    }
    
    ; Calculate new sizes (split window in half with margins)
    leftWidth := (width - 30) // 2
    rightWidth := width - leftWidth - 30
    controlHeight := height - 55 ; Account for single button row height
    
    ; Resize the controls based on what's available
    codeEdit.Move(10, 45, leftWidth, controlHeight)
    if (previewBrowser != "") {
        ; WebView2 controls usually have their own resize method
        try {
            previewBrowser.Move(leftWidth + 20, 45, rightWidth, controlHeight)
        }
    } else if (previewText != "") {
        previewText.Move(leftWidth + 20, 45, rightWidth, controlHeight)
    }
}

; Function to load a sample SVG from local file
LoadSampleSvg(*) {
    sampleFile := A_ScriptDir . "\sample.svg"
    
    ; Check if sample file exists
    if (!FileExist(sampleFile)) {
        Notify.Show({
            HDText: "File Not Found",
            BDText: "Sample file not found: " . sampleFile . "`n`nPlease create a sample.svg file in the script directory.",
            GenBGColor: "Red",
            GenSound: "Critical",
            GenDuration: 5
        })
        return
    }
    
    try {
        fileObj := FileOpen(sampleFile, "r", "UTF-8")
        if (fileObj) {
            svgContent := fileObj.Read()
            fileObj.Close()
            codeEdit.Text := svgContent
            UpdatePreview()
            Notify.Show({
                HDText: "Sample Loaded",
                BDText: "Sample SVG loaded successfully!",
                GenBGColor: "Green",
                GenSound: "Success",
                GenDuration: 3
            })
        }
    } catch Error as err {
        Notify.Show({
            HDText: "File Error",
            BDText: "Error loading sample file: " . err.Message,
            GenBGColor: "Red",
            GenSound: "Critical",
            GenDuration: 5
        })
    }
}

; Function to open an SVG file
OpenSvgFile(*) {
    selectedFile := FileSelect(1, , "Open SVG File", "SVG Files (*.svg)")
    if (selectedFile != "") {
        try {
            fileObj := FileOpen(selectedFile, "r", "UTF-8")
            if (fileObj) {
                svgContent := fileObj.Read()
                fileObj.Close()
                codeEdit.Text := svgContent
                UpdatePreview()
                ; Show success notification only if requested (uncomment next lines if desired)
                ; Notify.Show({
                ;     HDText: "File Opened",
                ;     BDText: "SVG file loaded successfully!",
                ;     GenBGColor: "Green",
                ;     GenSound: "Success",
                ;     GenDuration: 2
                ; })
            }
        } catch Error as err {
            Notify.Show({
                HDText: "File Error",
                BDText: "Error opening file: " . err.Message,
                GenBGColor: "Red",
                GenSound: "Critical",
                GenDuration: 5
            })
        }
    }
}

; Function to save SVG file
SaveSvgFile(*) {
    if (codeEdit.Text = "") {
        Notify.Show({
            HDText: "Save Error",
            BDText: "Nothing to save! Please add some SVG code first.",
            GenBGColor: "Orange",
            GenSound: "Exclamation",
            GenDuration: 4
        })
        return
    }
    
    selectedFile := FileSelect("S", , "Save SVG File", "SVG Files (*.svg)")
    if (selectedFile != "") {
        ; Add .svg extension if not present
        if (!RegExMatch(selectedFile, "\.svg$")) {
            selectedFile .= ".svg"
        }
        
        try {
            fileObj := FileOpen(selectedFile, "w", "UTF-8")
            if (fileObj) {
                fileObj.Write(codeEdit.Text)
                fileObj.Close()
                Notify.Show({
                    HDText: "Save Complete",
                    BDText: "File saved successfully!",
                    GenBGColor: "Green",
                    GenSound: "Success",
                    GenDuration: 3
                })
            }
        } catch Error as err {
            Notify.Show({
                HDText: "File Error",
                BDText: "Error saving file: " . err.Message,
                GenBGColor: "Red",
                GenSound: "Critical",
                GenDuration: 5
            })
        }
    }
}

; Function to create new SVG
NewSvg(*) {
    result := MsgBox("Create a new SVG? This will clear the current content.", "New SVG", "YesNo Icon?")
    if (result = "Yes") {
        codeEdit.Text := '<svg viewBox="0 0 400 300" xmlns="http://www.w3.org/2000/svg">' . "`n" . '  <!-- Your SVG content here -->' . "`n" . '</svg>'
        UpdatePreview()
        Notify.Show({
            HDText: "New SVG",
            BDText: "New SVG template created!",
            GenBGColor: "Blue",
            GenSound: "Info",
            GenDuration: 2
        })
    }
}

; Function to URL encode content for data URI
EncodeForDataUri(text) {
    ; Simple encoding for data URI - replace problematic characters
    encodedText := StrReplace(text, "#", "%23")
    encodedText := StrReplace(encodedText, " ", "%20")
    encodedText := StrReplace(encodedText, "`n", "%0A")
    encodedText := StrReplace(encodedText, "`r", "%0D")
    encodedText := StrReplace(encodedText, "<", "%3C")
    encodedText := StrReplace(encodedText, ">", "%3E")
    return encodedText
}

; Function to exit the application
ExitApplication(*) {
    ExitApp
}

; Zoom control functions
ZoomIn(*) {
    global currentZoom, zoomLabel
    currentZoom += 25
    if (currentZoom > 500) {
        currentZoom := 500 ; Max zoom
    }
    zoomLabel.Text := "Zoom: " . currentZoom . "%"
    UpdatePreview()
}

ZoomOut(*) {
    global currentZoom, zoomLabel
    currentZoom -= 25
    if (currentZoom < 25) {
        currentZoom := 25 ; Min zoom
    }
    zoomLabel.Text := "Zoom: " . currentZoom . "%"
    UpdatePreview()
}

ZoomReset(*) {
    global currentZoom, zoomLabel
    currentZoom := 100
    zoomLabel.Text := "Zoom: " . currentZoom . "%"
    UpdatePreview()
}

; Create the main GUI window
mainGui := Gui("+Resize +MinSize400x300", "SVG Code & Preview Tool")
mainGui.BackColor := "White"

; All buttons in one row across the top
openBtn := mainGui.Add("Button", "x10 y10 w70 h25", "Open")
saveBtn := mainGui.Add("Button", "x90 y10 w70 h25", "Save")
newBtn := mainGui.Add("Button", "x170 y10 w70 h25", "New")
sampleBtn := mainGui.Add("Button", "x250 y10 w80 h25", "Sample")
zoomInBtn := mainGui.Add("Button", "x340 y10 w60 h25", "Zoom +")
zoomOutBtn := mainGui.Add("Button", "x410 y10 w60 h25", "Zoom -")
zoomResetBtn := mainGui.Add("Button", "x480 y10 w60 h25", "Reset")
zoomLabel := mainGui.Add("Text", "x550 y15 w100 h15", "Zoom: " . currentZoom . "%")

; Connect button events
openBtn.OnEvent("Click", OpenSvgFile)
saveBtn.OnEvent("Click", SaveSvgFile)
newBtn.OnEvent("Click", NewSvg)
sampleBtn.OnEvent("Click", LoadSampleSvg)
zoomInBtn.OnEvent("Click", ZoomIn)
zoomOutBtn.OnEvent("Click", ZoomOut)
zoomResetBtn.OnEvent("Click", ZoomReset)

; Create simple edit control for SVG code (left side)
codeEdit := mainGui.Add("Edit", "x10 y45 w790 h545 VScroll +Wrap", "")
codeEdit.OnEvent("Change", UpdatePreview)

; Create WebBrowser control for preview (right side)
try {
    ; Try the old reliable WebBrowser ActiveX control
    previewBrowser := mainGui.Add("ActiveX", "x810 y45 w790 h545", "Shell.Explorer")
    previewText := "" ; We'll use the browser if successful
} catch {
    ; Fallback to text if WebBrowser fails
    previewBrowser := ""
    previewText := mainGui.Add("Edit", "x810 y45 w790 h545 ReadOnly VScroll", "SVG preview will appear here...")
}

; Set initial window size
mainGui.Show("w1600 h600")

; Handle window resize
mainGui.OnEvent("Size", ResizeControls)

; Load sample SVG on startup (only if file exists)
if (FileExist(A_ScriptDir . "\sample.svg")) {
    LoadSampleSvg()
}

;*************************END OF FILE********************