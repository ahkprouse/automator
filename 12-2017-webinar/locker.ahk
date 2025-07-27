#SingleInstance force
#Noenv	

Sleep 500  ; Give user a chance to release keys (in case their release would wake up the monitor again).

SetTimer, sleepy, 250 ;set every 1/4 of a second to ensure it is sleeping
return
;***********subroutine to ensure sleeping******************* 
Sleepy:
SendMessage, 0x112, 0xF170, 2,, Program Manager ; Use 2 to turn the monitor off.
return

;***********kill script******************* 
AppsKey & u::
SendMessage, 0x112, 0xF170, -1,, Program Manager ; Use -1 to turn the monitor on.
ExitApp
return

;***********create hotstrings for keys so they will do nothing******************* 
;key list found at: http://www.autohotkey.com/docs/KeyList.htm
Tab::
Escape::
Backspace::

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
Up::
Down::
Left::
Right::

LWin::
RWin::

LControl::
RControl::
LShift::
RShift::
LAlt::
RAlt::
Enter::
Space::

PrintScreen::
CtrlBreak::
;~ Pause:: ;I like being able to pause my music even when screen off
;~ Break::

Help::
Sleep::

Browser_Back::
Browser_Forward::
Browser_Refresh::
Browser_Stop::
Browser_Search::
Browser_Favorites::
Browser_Home::
;~ Volume_Mute:: ;I like being able to turn up/down/mute music
;~ Volume_Down::
;~ Volume_Up::
Media_Next::
Media_Prev::
Media_Stop::
;~Media_Play_Pause::
Launch_Mail::
Launch_Media::
Launch_App1::
Launch_App2::

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
NumpadEnter::
NumpadAdd::

LButton::
RButton::
MButton::

a::
b::
c::
d::
e::
f::
g::
h::
i::
j::
k::
l::
m::
n::
o::
p::
q::
r::
s::
t::
u::
v::
w::
x::
y::
z::

0::
1::
2::
3::
4::
5::
6::
7::
8::
9::

Return 
