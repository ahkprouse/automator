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
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
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
#Include <Scriptobject>


script := {
    base         : ScriptObj(),
    version      : "0.0.1",
    hwnd         : 0,
    author       : "the-Automator",
    email        : "joe@the-automator.com",
    crtdate      : "",
    moddate      : "",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' , 
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "ImageFormatChecker",
    homepagelink : "https://www.the-automator.com/ImageFormatChecker?src=app",
    donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()


; Example usage
MsgBox("The image format is: " IdentifyImageFormat("S:\Snap Capture for OCR\test.png"))
MsgBox("The image format is: " IdentifyImageFormat("S:\Snap Capture for OCR\new.jpg"))



IdentifyImageFormat(filePath) {
    try {
        fileBuffer := FileRead(filePath, "RAW")
        
        if (NumGet(fileBuffer, 0, "UChar") == 0xFF && NumGet(fileBuffer, 1, "UChar") == 0xD8 && NumGet(fileBuffer, 2, "UChar") == 0xFF) {
            return "JPEG"
        } else if (NumGet(fileBuffer, 0, "UChar") == 0x89 && NumGet(fileBuffer, 1, "UChar") == 0x50 && NumGet(fileBuffer, 2, "UChar") == 0x4E && NumGet(fileBuffer, 3, "UChar") == 0x47) {
            return "PNG"
        } else if (NumGet(fileBuffer, 0, "UChar") == 0x47 && NumGet(fileBuffer, 1, "UChar") == 0x49 && NumGet(fileBuffer, 2, "UChar") == 0x46 && NumGet(fileBuffer, 3, "UChar") == 0x38) {
            return "GIF"
        } else if (NumGet(fileBuffer, 0, "UChar") == 0x42 && NumGet(fileBuffer, 1, "UChar") == 0x4D) {
            return "BMP"
        } else {
            return "Unknown"
        }
    } catch as err {
        MsgBox("Error reading file: " . err.Message)
        return "Error"
    }
}



