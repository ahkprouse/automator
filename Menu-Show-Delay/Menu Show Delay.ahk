
/**
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 * @Author   : Joe                                                              *
 * @Homepage : the-automator.com                                                *
 *                                                                              *
 * @Created  : September 14, 2024                                               *
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
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <NotifyV2>
#Include <ScriptObject\ScriptObject>

;--
;@Ahk2Exe-SetVersion     0.1.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Menu Show Delay
;@Ahk2Exe-SetDescription Menu Show Delay by the-Automator

OnError logerrors

Logerrors(err, mode)
{
    line := err.What '`t' err.extra '`t' err.Message '`t' err.Line '`t' err.File '`n'
    FileAppend line, 'error.log', 'utf-8'
    return -1
}

Notify.Default :=
{
	HDText 		: "Menu Show Delay",
	HDFontColor : '0x196F3D',
	HDFontSize  : 18,
	HDFont 		: 'Bauhaus 93',
	BDFontColor : 'Black',
	BDFontSize  : 15,
	BDFont 		: 'Gill Sans MT',
	GenBGColor 	: '0xE99E31',
	GenIcon 	: 'Critical',
	GenIconSize : 50,
	GenDuration : 3,
	Genloc 		: 'c',
}

script := {
	base         : ScriptObj(),
	version      : "0.1.0",
	hwnd         : '',
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "2024-09-14",
	moddate      : "2024-09-14",
	resfolder    : A_ScriptDir "\res",
	iconfile     : A_ScriptDir '\res\main.ico',
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "the-automator.com/Menushowdelay",
	homepagelink : "the-automator.com/Menushowdelay?src=app",
	VideoLink 	 : "",
	DevPath 	 : "S:\Menu Show Delay\Menu Show Delay.ahk",
	donateLink   : "",
}

Regedit_MenuShowDelay := "HKEY_CURRENT_USER\Control Panel\Desktop"

preferences := menu()
preferences.add('one', (*)=>false)
preferences.add('two', (*)=>false)
preferences.add('three', (*)=>false)
preferences.add('four', (*)=>false)

Width := 200
Height := 40
Font := 30

TraySetIcon A_ScriptDir '\res\main.ico'
A_TrayMenu.add('Open Folder',(*)=>Run(A_ScriptDir))
A_TrayMenu.SetIcon("Open Folder","shell32.dll",4)

MyGui := Gui(,'MenuShowDelay')
MyGui.SetFont('S' Font-10)
Change_MenuShowDelay := myGui.AddEdit('Limit4 r0 xm yp+30 w' Width-120 ' h' Height ' vChange_MenuShowDelay +Number +Center')
;MyGui.AddUpDown('x+m Range0-1000')
MyGui.SetFont('S' Font / 2)
MyGui.Add("Button", 'x+m w' Width ' h' Height, "Test Menu Speed").onEvent('click',TestButton)

MyGui.SetFont('S' Font-15)
MyGui.Add("Button", 'xm+180 w' Width-80  ' h' Height, "Apply").OnEvent("Click", Apply)
MyGui.OnEvent('Close', (*) => ExitApp())
MyGui.Show()
return

TestButton(*)
{
    Value := MyGui["Change_MenuShowDelay"].value
    if(Value = "") or (MyGui["Change_MenuShowDelay"].value > 1000)
    {
        Notify.Show({BDText:"Enter a value between 0 and 1000",HDText:"Menu Show Delay",GenIcon:"Exclamation"})
        ;msgbox 'Enter a value between 0 and 1000'
        return
    }
    Value := MyGui["Change_MenuShowDelay"].value
    Sleep(Value)
    preferences.show()
}

Apply(*)
{
	if (MyGui["Change_MenuShowDelay"].value > 1000)
	{
		Notify.Show({BDText:"Enter a value between 0 and 1000",HDText:"Menu Show Delay",GenIcon:"Exclamation"})
        return
	}

    MyGui.Hide()
    WS_EX_TOPMOST := 0x40000
    res := MsgBox("In order to apply the changes, your computer needs to reboot.`n`nWould you like to reboot now?", "System Reboot Required", "Icon? YesNoCancel " WS_EX_TOPMOST)
    if (res = 'No')
    {
        WriteReg()
        return !!MsgBox('Changes will be applied on your next reboot', 'Info', 'Iconi ' WS_EX_TOPMOST)
    }
    if (res = 'Cancel')
        return    
    WriteReg()
    Shutdown 2 ; Reboots the system
        
}

WriteReg()
{
    Value := MyGui["Change_MenuShowDelay"].value 
    RegWrite Value, "REG_SZ", Regedit_MenuShowDelay, "MenuShowDelay"
}


