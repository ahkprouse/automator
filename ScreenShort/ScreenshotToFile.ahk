/**
 * =========================================================================== *
 * @author      Xeo786                                                         *
 * @version     0.0.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-01-01                                                     *
 * @modified    2025-01-01                                                     *
 * @description                                                                *
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
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
;@Ahk2Exe-SetProductName 
;@Ahk2Exe-SetDescription 
#Requires Autohotkey v2.0+
#SingleInstance
   
   script := {
     base : ScriptObj(),
     version : "1.1.0",
     hwnd : 0,
     author : "the-Automator",
     email : "joe@the-automator.com",
     crtdate : "",
     moddate : "",
     resfolder : A_ScriptDir "\res",
     iconfile : 'mmcndmgr.dll' ,
     config : A_ScriptDir "\settings.ini",
     homepagetext : "ScreenShort",
     homepagelink : "the-automator.com/SceenShort?src=app",
     donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
   }

F1::
{
    try
    {
        a_clipboard := ''
        Send '!{PrintScreen}'
        Clipwait(3,true)
        Sleep 10
        SaveScreenshotAsBMP(a_desktop '\image.bmp')
        Msgbox 'Done'
    }
    catch as err
        MsgBox("Error: " . err.Message)
}

SaveScreenshotAsBMP(filePath) {
    static CF_DIB := 8

    if !DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
        throw Error("Unable to open clipboard")

    try {
        if !DllCall("IsClipboardFormatAvailable", "Uint", CF_DIB)
            throw Error("CF_DIB format not available")

        hBitmap := DllCall("GetClipboardData", "Uint", CF_DIB, "Ptr")
        if !hBitmap
            throw Error("Failed to get clipboard data")

        ; Get DIB data size
        size := DllCall("GlobalSize", "Ptr", hBitmap, "Ptr")
        pBits := DllCall("GlobalLock", "Ptr", hBitmap, "Ptr")

        ; Create file header
        fileHeaderSize := 14
        fileSize := fileHeaderSize + size
        fileHeader := Buffer(fileHeaderSize)
        NumPut("ushort", 0x4D42, fileHeader, 0)  ; 'BM' signature
        NumPut("uint", fileSize, fileHeader, 2)  ; File size
        NumPut("uint", fileHeaderSize + NumGet(pBits, "uint"), fileHeader, 10)  ; Offset to pixel data

        ; Open file for writing
        file := FileOpen(filePath, "w")
        if !file
            throw Error("Unable to open file for writing")

        ; Write file header
        file.RawWrite(fileHeader)

        ; Write DIB data
        file.RawWrite(pBits, size)

        file.Close()
        DllCall("GlobalUnlock", "Ptr", hBitmap)
    }
    finally {
        DllCall("CloseClipboard")
    }
}