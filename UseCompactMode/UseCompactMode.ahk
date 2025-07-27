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
#Include <ScriptObject>

  script := {
  base         : ScriptObj(),
  version      : "0.0.1",
  hwnd         : 0,
  author       : "the-Automator",
  email        : "joe@the-automator.com",
  crtdate      : "",
  moddate      : "",
  resfolder    : A_ScriptDir "\res",
  iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
  config       : A_ScriptDir "\settings.ini",
  homepagetext : "UseCompactMode",
  homepagelink : "the-automator.com/UseCompactMode?src=app",
  donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.Add("About",(*) => Script.About())
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()  


Result := VerCompare(A_OSVersion,'10.0.22630')
if !(Result > 0)
{
    msgbox "It's only work on windows 11 Bulid 22631+",,'Iconx'
    return
}

;Read hte current taskbar icon size from the registry 
Current_IconSize := RegRead('HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','UseCompactMode','1')

;Define dimension for GUI elements
Width := 120
Height := 50
;Create a Gui Window with the titile 
Mygui := Gui(,'Compact Mode')
; Set up an event to exit the app when the GUI is closed
Mygui.OnEvent('Close', (*) => ExitApp())
Mygui.AddText('center w380 h35','Use Compact Mode').SetFont('S20')

Mygui.SetFont('S15')
;Add a radio button for "Compact Mode" icons
CompactMode := Mygui.AddCheckbox('vRadioValues center xm+80 yp+40 h50 Checked' (Current_IconSize),'Use Compact Mode')
CompactMode.OnEvent('Click',apply)
Mygui.Show()

;Function that's called when a radio button is clicked
apply(GuiCtrl,*)
{
    ;Small.Value if 0 it will be Taksbar icon 
    RegWrite(CompactMode.Value,'REG_DWORD', 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced','UseCompactMode')
}


