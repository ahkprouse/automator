/*
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover          *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */
#Requires AutoHotkey v2.0+ 64-bit
#Include .\lib\WinClip.ahk
#Include .\lib\WinClipAPI.ahk

wc := WinClip()

Clipster(str,sendkeys:="")
{
    clipsave := ClipboardAll()
    Switch Sendkeys,0
    {
        Case "Pic":
            ImagePath2bitmap(str)
            sendkeys := ""
        Case "Html":
            HtmltoClip(str)
            sendkeys := ""
        Default:
        wc.Clear()
        wc.SetText(str)
    }
    send "^v"
    sleep 100
    if sendkeys != ""
        Send sendkeys
    sleep 1000 ; you may need to tweak this depending on your system.
    A_Clipboard := clipsave
}

ImagePath2bitmap(picPath)
{
    wc.Clear()
    wc.SetBitmap( picPath )
}

HtmltoClip(html)
{
    html:= "<span>" html "</span>" ;Build href
    wc.Clear()
    wc.SetHTML( html ) ;set clipboard to be Hyperlink
}