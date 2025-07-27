/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 */
#Requires Autohotkey v2.0+
#SingleInstance
;link to the video 
;homepagelink : "the-automator.com/DisableClipboard?src=app",


^t::DllCall( "OpenClipboard", "Ptr", 0 ) ; disables clipboard
^+t::DllCall( "CloseClipboard" ) ; enables clipboard