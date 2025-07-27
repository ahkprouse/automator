/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.0.0                                                          *
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
Persistent

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
    homepagetext : "ToddlerKeyboard",
    homepagelink : "https://www.the-automator.com/ToddlerKeyboard?src=app",
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



;**********************Create Word document********************************.
oWord := ComObject("Word.Application")   ; create MS Word object
oWord.Documents.Add   ; create new document
oWord.Selection.Font.Bold := 1   ; bold
oWord.Selection.Font.size := 30   ; change size
oWord.Visible := 1
oWord.Activate ; make it visible and activate it.

SetTimer Activate, 1000


Activate(*)
{
    Loop
    {
        WinActivate 'Document'
        if !WinActivate 'Document' 
            WinActivate 'Document'
    }
}


Numpadadd & NumpadEnter::
{
    ProcessClose 'Winword.exe'
    ExitApp
}


SendMode 'Input' ;
;key list found at: http://www.autohotkey.com/docs/KeyList.htm
;-------------------------------------------------
;KEYS NOT ALLOWED:
;-------------------------------------------------
Tab::
Escape::
Delete::
Insert::
Home::
End::
PgUp::
PgDn::
ScrollLock::
NumLock::
F1::
F2::
F3::
F4::
F5::
F6::
F7::
F8::
F9::
F10::
F11::
F12::
F13::
F14::
F15::
F16::
F17::
F18::
F19::
F20::
F21::
F22::
F23::
F24::
AppsKey::
LWin::
RWin::
LControl::
~RControl::
LAlt::
RAlt::
PrintScreen::
CtrlBreak::
Pause::
;Break::
Help::
Sleep::
Browser_Back::
Browser_Forward::
Browser_Refresh::
Browser_Stop::
Browser_Search::
Browser_Favorites::
Browser_Home::
Volume_Mute::
Media_Next::
Media_Prev::
Media_Stop::
Media_Play_Pause::
Launch_Mail::
Launch_Media::
Launch_App1::
Launch_App2::
{
    return
}

;not an allowed key, so do nothing
;***********************Allowed keys********************************.
; Backspace::
;Volume_Down::
;Volume_Up::
;LShift::
;RShift::
;-------------------------------------------------
;Audio
;-------------------------------------------------
~0::SoundPlay(A_ScriptDir "\Sound\0.mp3")
~1::SoundPlay(A_ScriptDir "\Sound\1.mp3")
~2::SoundPlay(A_ScriptDir "\Sound\2.mp3")
~3::SoundPlay(A_ScriptDir "\Sound\3.mp3")
~4::SoundPlay(A_ScriptDir "\Sound\4.mp3")
~5::SoundPlay(A_ScriptDir "\Sound\5.mp3")
~6::SoundPlay(A_ScriptDir "\Sound\6.mp3")
~7::SoundPlay(A_ScriptDir "\Sound\7.mp3")
~8::SoundPlay(A_ScriptDir "\Sound\8.mp3")
~9::SoundPlay(A_ScriptDir "\Sound\9.mp3")
~a::SoundPlay(A_ScriptDir "\Sound\a.mp3")
~b::SoundPlay(A_ScriptDir "\Sound\b.mp3")
~c::SoundPlay(A_ScriptDir "\Sound\c.mp3")
~d::SoundPlay(A_ScriptDir "\Sound\d.mp3")
~e::SoundPlay(A_ScriptDir "\Sound\e.mp3")
~f::SoundPlay(A_ScriptDir "\Sound\f.mp3")
~g::SoundPlay(A_ScriptDir "\Sound\g.mp3")
~h::SoundPlay(A_ScriptDir "\Sound\h.mp3")
~i::SoundPlay(A_ScriptDir "\Sound\i.mp3")
~j::SoundPlay(A_ScriptDir "\Sound\j.mp3")
~k::SoundPlay(A_ScriptDir "\Sound\k.mp3")
~l::SoundPlay(A_ScriptDir "\Sound\l.mp3")
~m::SoundPlay(A_ScriptDir "\Sound\m.mp3")
~n::SoundPlay(A_ScriptDir "\Sound\n.mp3")
~o::SoundPlay(A_ScriptDir "\Sound\o.mp3")
~p::SoundPlay(A_ScriptDir "\Sound\p.mp3")
~q::SoundPlay(A_ScriptDir "\Sound\q.mp3")
~r::SoundPlay(A_ScriptDir "\Sound\r.mp3")
~s::SoundPlay(A_ScriptDir "\Sound\s.mp3")
~t::SoundPlay(A_ScriptDir "\Sound\t.mp3")
~u::SoundPlay(A_ScriptDir "\Sound\u.mp3")
~v::SoundPlay(A_ScriptDir "\Sound\v.mp3")
~w::SoundPlay(A_ScriptDir "\Sound\w.mp3")
~x::SoundPlay(A_ScriptDir "\Sound\x.mp3")
~y::SoundPlay(A_ScriptDir "\Sound\y.mp3")
~z::SoundPlay(A_ScriptDir "\Sound\z.mp3")


Numpad0::
NumpadIns::
Numpad1::
NumpadEnd::
Numpad2::
NumpadDown::
Numpad3::
NumpadPgDn::
Numpad4::
NumpadLeft::
Numpad5::
NumpadClear::
Numpad6::
NumpadRight::
Numpad7::
NumpadHome::
Numpad8::
NumpadUp::
Numpad9::
NumpadPgUp::
NumpadDot::
NumpadDel::
NumpadDiv::
NumpadMult::
Numpadsub::
{ 
    ;only send the key press through once if held down continually
    ;(send the literal keys)
    if (A_PriorHotkey != A_ThisHotkey or A_TimeSincePriorHotkey > 500)
    {
       Hotkey(A_ThisHotkey, "Off")
       Send(A_ThisHotkey)
       Hotkey(A_ThisHotkey, "On")
    }
    return
}

