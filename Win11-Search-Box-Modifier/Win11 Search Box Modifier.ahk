#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include <NotifyV2>
#Include <ScriptObject\ScriptObject>

;--
;@Ahk2Exe-SetVersion     0.1.0
; ;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Win11 Serach Box Modifier
;@Ahk2Exe-SetDescription Win11 Serach Box Modifier by the-Automator
/*
/**
 * ============================================================================ *
 * @Author   : Joe                                                              *
 * @Homepage : the-automator.com                                                *
 *                                                                              *
 * @Created  : September 19, 2024                                                  *
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

OS := StrSplit(A_OSVersion,".")
IF (OS[1] < 10) 
{
    Notify.Show({HDText:"This tool require windows 10 or higher",
        HDFontSize  : 20,
        HDFontColor : "Black",
        HDFont      : "Impact",
        GenIcon:"Critical",
        GenDuration : 0})
    return
}

OnError logerrors

Logerrors(err, mode)
{
    line := err.What '`t' err.extra '`t' err.Message '`t' err.Line '`t' err.File '`n'
    FileAppend line, 'error.log', 'utf-8'
    return -1
}

script := {
	base         : ScriptObj(),
	version      : "0.1.0",
	hwnd         : '',
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "2024-09-19",
	moddate      : "2024-09-19",
	resfolder    : A_ScriptDir "\res",
	iconfile     : A_ScriptDir '\res\main.ico',
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "the-automator.com/Win11 Serach Box Modifier",
	homepagelink : "the-automator.com/Win11 Serach Box Modifier?src=app",
    VideoLink    : "",
    DevPath      : "",
	donateLink   : "",
}
RegLoc_Disabled_SearchSetting := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\SearchSettings"
RegLoc_Disabled_SearchBing := "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer\"

DynamicSearchBoxEnabled := RegRead( RegLoc_Disabled_SearchSetting,'IsDynamicSearchBoxEnabled',1)
DisableSearchBoxBing    := RegRead( RegLoc_Disabled_SearchBing,'DisableSearchBoxSuggestions',0)

A_TrayMenu.add('Open Folder',(*)=>Run(A_ScriptDir))
A_TrayMenu.SetIcon("Open Folder","shell32.dll",4)

Width := 120
TraySetIcon("C:\WINDOWS\system32\ieframe.dll", 11)
Mygui := Gui(,'Win11 Serach Box Modifier')
Mygui.SetFont('S12')
EnableDyanmic      := Mygui.AddCheckbox('xm yp+30 Checked' DynamicSearchBoxEnabled,'Enabled Dynamic Search')
EnableDyanmic.OnEvent('Click',EnabledButton)
DisbledSuggestion   := Mygui.AddCheckbox('xm yp+40 Checked' DisableSearchBoxBing,'Disabled Search box Suggestions')
DisbledSuggestion.OnEvent('Click',EnabledButton)

;data := (DynamicSearchBoxEnabled = 0)?'+':(DisableSearchBoxBing = 1)?'+':'-'
ApplyButton := Mygui.AddButton('xm yp+50 +Disabled w' Width ,'Apply')
ApplyButton.OnEvent('Click',Apply)
Mygui.AddButton('x+m w' Width,'Cancel').OnEvent('Click',(*) => ExitApp())
ButtonReet := Mygui.AddButton('x+m w' Width,'Reset')
ButtonReet.OnEvent('Click',Reset)
EnabledButton
Mygui.Show()

EnabledButton(*)
{
    DynamicSearchBoxEnabled := RegRead( RegLoc_Disabled_SearchSetting,'IsDynamicSearchBoxEnabled',1)
    DisableSearchBoxBing    := RegRead( RegLoc_Disabled_SearchBing,'DisableSearchBoxSuggestions',0)

    if (EnableDyanmic.value = DynamicSearchBoxEnabled) and (DisbledSuggestion.Value = DisableSearchBoxBing)
        ApplyButton.Opt('+Disabled')
    else
        ApplyButton.Opt('-Disabled')
}

Apply(*)
{
    WS_EX_TOPMOST := 0x40000
    RegWrite(EnableDyanmic.value,'REG_DWORD', RegLoc_Disabled_SearchSetting ,'IsDynamicSearchBoxEnabled')
    RegWrite(DisbledSuggestion.value,'REG_DWORD', RegLoc_Disabled_SearchBing ,'DisableSearchBoxSuggestions')
        RestartApplication()
}

Reset(*)
{
    ApplyButton.Opt('-Disabled')
    if EnableDyanmic.value
    {
        RegDelete RegLoc_Disabled_SearchSetting, "IsDynamicSearchBoxEnabled"
    }

    ;EnableDyanmic.Value := false
    if DisbledSuggestion.value
    {
        WS_EX_TOPMOST := 0x40000
        RegDelete RegLoc_Disabled_SearchBing, "DisableSearchBoxSuggestions"
        ;DisbledSuggestion.Value := false
        ;MsgBox('Changes applied. Explorer has been restarted.', 'Info', 'Iconi ' WS_EX_TOPMOST)
    }
    RestartApplication()
}

RestartApplication()
{
    ProcessClose("explorer.exe")
    if !ProcessWaitClose("explorer.exe",10)
    {
        MsgBox('Error: Explorer not closed', 'Error', 'Iconi 16')
        ExitApp()
    }
    ;Run "explorer.exe"
}

