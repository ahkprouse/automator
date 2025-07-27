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
#Requires AutoHotkey v2.0
#SingleInstance Force
#Include <NotifyV2>
#Include <ContextMenuTrigger>
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
    iconfile     : 'mmcndmgr.dll' , 
    config       : A_ScriptDir "\settings.ini",
    homepagetext : "Context Menu Syntax Writer",
    homepagelink : "the-automator.com/ContextMenuSyntaxWriter?src=app",
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

CMgui := Gui('+alwaysontop',"Context Menu Syntax Writer")
CMgui.OnEvent('DropFiles',Catchverbs)
CMgui.OnEvent('close',(*) => ExitApp())
;CMgui.AddCheckbox(,'selected File')
CMgui.AddButton('h30 w300 +disabled','Drag Drop File or Folder')
LV := CMgui.AddListView('r15 w300',['Verbs'])
LV.OnEvent('DoubleClick',getLvVerb)
CMgui.Show()

getLvVerb(GuiCtrlObj, row)
{
    A_Clipboard := ""
    A_Clipboard := 'ContextMenuTrigger(' Chr(39) CMgui.path Chr(39) ',' Chr(39) lv.GetText(row) Chr(39) ')'
    if !ClipWait(0)
        return Notify.show( 'failed to copy verb')
    Notify.show('Verb Copied!`n' A_Clipboard)
    sleep 1000
    ToolTip
}


Catchverbs(GuiObj, GuiCtrlObj, FileArray, X, Y)
{
    LV.Delete()
    for verb in StrSplit(ContextMenuGet(CMgui.path := FileArray[1]),'`n')
    {
        if verb 
            LV.Add(,verb)
    }
    LV.ModifyCol()
}
