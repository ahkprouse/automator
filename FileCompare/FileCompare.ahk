/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      Rizwan                                                         *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-12-Sep                                                    *
 * @modified    2025-01-Jan                                                    *
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
;@Ahk2Exe-SetProductName FileCompare
;@Ahk2Exe-SetDescription Instantly Compare File Sizes with Visual Progress Bars
#Requires AutoHotkey v2.0
#SingleInstance Force
#include <GetActivePath>
#include <Calculation>
#Include <ScriptObject>


script := {
    base         : ScriptObj(),
    version      : "0.0.1",
    hwnd         : 0,
    author       : "the-Automator",
    email        : "joe@the-automator.com",
    crtdate      : "12-09-2024",
    moddate      : "27-01-2025",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\FileComparebg512.ico",
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "FileCompare",
    homepagelink : "the-automator.com/FileCompare?src=app",
    donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()


A_TrayMenu.add('Open Folder',(*)=>Run(A_ScriptDir))
A_TrayMenu.SetIcon("Open Folder","shell32.dll",4)

ProgressBarColor := 'c98fa98'
MainGuiBackColor := 'dffae6'
MainGuiFontColor := 'cBlack'

TraySetIcon("compstui.dll",58) 
Prog := Gui("-MinimizeBox -MaximizeBox -Caption +Owner +AlwaysOnTop")

Prog.SetFont('s12 w500 ' MainGuiFontColor)
Prog.Add("Text", "vresult1 BackgroundTrans w500")
Prog.SetFont()

Prog.BackColor := MainGuiBackColor
Prog.Add("Progress", "xm w500 h50 vProg1 Backgroundwhite " ProgressBarColor)
Prog.SetFont('s12 w500 ' MainGuiFontColor)
Prog.Add("Text", "vPath1 w500 BackgroundTrans xp yp+15 ")
Prog.SetFont()

Prog.Add("Progress", "xm w500 h50 vProg2 Backgroundwhite " ProgressBarColor)
Prog.SetFont('s12 w500 ' MainGuiFontColor)
Prog.Add("Text", "vPath2 w500 BackgroundTrans xp yp+15 ")


Prog.Add("Text", "xm vresult2 BackgroundTrans w500")
Prog.SetFont()
Prog.OnEvent('Close', (*) => ExitApp())
OnMessage(0x0201, WM_LBUTTONDOWN)

f1::
{
    ; static Size1 = 0
    Static SelectedFile1
    Static RunCount := 0
    if (RunCount = 2)
    {
        CloseAllNotify()
        Prog.Hide()
        RunCount := 0
    }
    
    if (RunCount = 1)
    {
        CloseAllNotify()
        SelectedFile2 := GetActivatePath()
        if !FileExist(SelectedFile2)
            return
        Size2 := FileGetSize(SelectedFile2,'B')
        ConvSize2 := FormatBytes(Size2)
        
        fileSize1 := FileGetSize(SelectedFile1)
        fileSize2 := FileGetSize(SelectedFile2)
        ;totalSize := fileSize1 + fileSize2

        File1 := SplitPaths(SelectedFile1)
        File2 := SplitPaths(SelectedFile2)

        FILES := Calculation(fileSize1,fileSize2,SelectedFile1,SelectedFile2)
        ;MSGBOX FILES.File1 "`n" FILES.File2
        
        Prog['Prog1'].value := Round(FILES.File1,0)
        Prog['Prog2'].value := Round(FILES.File2,0)
        Prog['result1'].value := FILES.A1
        Prog['result2'].value := FILES.A2
        
        Prog['Path1'].value := "  " File1.Filename
        Prog['Path2'].value := "  " File2.Filename
        Prog.Show()
    }
    else
    {
        if (RunCount = 0)
        {
            SelectedFile1 := GetActivatePath()
            if !FileExist(SelectedFile1)
                return
            Size1 := FileGetSize(SelectedFile1,'B')
            ConvSize1 := FormatBytes(Size1)
            Notify.show({HDText:"File one is:",BDText:SelectedFile1,GenDuration:0})
        }
    }
    RunCount := RunCount+1

}

WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
{
    if InStr(WinGetTitle("A"),"About")
        return

    static HTCAPTION := 2
    static WM_NCLBUTTONDOWN := 0x00A1

    PostMessage WM_NCLBUTTONDOWN, HTCAPTION, 0,, Prog
}

CloseAllNotify()
{
    for tempgui in MultiGui.Guis
        tempgui.Destroy() 
     MultiGui.LastPOs := map()

    for i, Gui in MultiGui.Guis
       Gui.Destroy()
}

FormatBytes(bytes)
{
    if (bytes < 1024)
        return bytes " B"
    if (bytes < 1048576)
        return Round(bytes / 1024, 2) " KB"
    if (bytes < 1073741824)
        return Round(bytes / 1048576, 2) " MB"
    return Round(bytes / 1073741824, 2) " GB"
}

SplitPaths(Path)
{
	SplitPath(Path, &FileName, &Dir, &Ext, &NNE, &Drive)
	return {FileName:Filename,Dir:Dir,Ext:Ext,NNE:NNE,Drive:Drive}
}

ESC::Prog.hide




