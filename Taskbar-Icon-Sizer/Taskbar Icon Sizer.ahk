#Requires AutoHotkey v2.0+
#Include <ScriptObject>
#SingleInstance Force
;--
;@Ahk2Exe-SetVersion     0.0.1
; @Ahk2Exe-SetMainIcon   res\main.ico
;@Ahk2Exe-SetProductName Taskbar Icon Sizer
;@Ahk2Exe-SetDescription Taskbar Icon Sizer
/**
 * ============================================================================ *
 * @Author   : Rizwan                                                           *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : 23 Sep, 2023                                                     *
 * @Modified : Sep 23, 2023                                                     *
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

TraySetIcon("shell32.dll", 134)
script := {
    base         : ScriptObj(),
    version      : "0.0.1",
    hwnd         : 0,
    author       : "the-Automator",
    email        : "joe@the-automator.com",
    crtdate      : "23-09-2024",
    moddate      : "23-09-2024",
    resfolder    : A_ScriptDir "\res",
    iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "Taskbar Icon Sizer",
    homepagelink : "the-automator.com/Taskbar Icon Sizer?src=app",
    DevPath      : "S:\RegistryHacks\Taskbar Icon Sizer\Taskbar Icon Sizer.ahk",
    donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
tray.Add()
tray.AddStandard()

Result := VerCompare(A_OSVersion,'10.0.22630')
if !(Result > 0)
{
    msgbox "It's only work on windows 11 Bulid 22631+",,'Iconx'
    return
}

;Read hte current taskbar icon size from the registry 
Current_IconSize := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons','1')

;Define dimension for GUI elements
Width := 120
Height := 50
;Create a Gui Window with the titile 
Mygui := Gui(,'Taskbar Icon Sizer')
; Set up an event to exit the app when the GUI is closed
Mygui.OnEvent('Close', (*) => ExitApp())
Mygui.AddText('center w380 h35','Set your Taskbar Icon Size').SetFont('S20')

Mygui.SetFont('S15')
;Add a radio button for "Small" icons
Small := Mygui.AddRadio('vRadioValues center xm+80 yp+40 h50 Checked' (Current_IconSize),'Small')
Small.OnEvent('Click',apply)
;Add a radio button for "Large" icons
Large := Mygui.AddRadio('center x+m+50 h50 Checked' (!Current_IconSize),'Large')
Large.OnEvent('Click',apply)
Mygui.Show()

;Function that's called when a radio button is clicked
apply(GuiCtrl,*)
{
    ;Small.Value if 0 it will be Taksbar icon 
    RegWrite(Small.Value,'REG_DWORD', 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','TaskbarSmallIcons')
}


