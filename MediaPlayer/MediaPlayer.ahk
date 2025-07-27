#Requires AutoHotkey v2.0+
#SingleInstance Force
;#include <Notify\v2\NotifyV2>
#include <NotifyV2>
#include <ScriptObj\scriptobj>
/*
* ============================================================================ *
* Want a clear path for learning AutoHotkey?                                   *
* Take a look at our AutoHotkey courses here: the-Automator.com/Learn          *
* They're structured in a way to make learning AHK EASY                        *
* And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
* ============================================================================ *
*/
script := {
	        base : ScriptObj(),
	     version : "1.0.0",
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
       resfolder : A_ScriptDir "\res",
        ;iconfile : 'shell32.dll', ;A_ScriptDir "\res\UltimateSpybg512.ico",
        ;  config : A_ScriptDir "\settings.ini",
	homepagetext : "the-automator.com/mediaplayer",
	homepagelink : "the-automator.com/mediaplayer?src=app",
	  donateLink : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6",
}
; todo  create prefernece gui for root/default folder
; wmaexe := A_ProgramFiles "\Windows Media Player\wmplayer.exe"
wmaexe  := A_ScriptDir '\res\Guitar.ico'
stopico := A_ScriptDir '\res\Stop.ico'
TraySetIcon wmaexe

; including  Gui after TraySetIcon 
#include <Gui>
SendLevel 1
; Defining Default Notify Parameterss
Notify.Default := 
{
    HDText : "MediaPlayer",
    HDFontColor : '0x196F3D',
    HDFontSize  : 18,
    HDFont : 'Bauhaus 93',
    BDFontColor : 'Black',
    BDFontSize  : 15,
    BDFont : 'Gill Sans MT',
    GenBGColor : '0xE99E31',
    GenIcon : 'Critical',
    GenIconSize : 50,
    GenDuration : 0
}

if !FileExist(wmaexe)
{
    Notify.show('Unable to locate Window MediaPlayer, click to close and Exitapp')
    while MultiGui.Guis.length > 0
        sleep 200
    exitapp
}
Notify.Default.GenDuration := 3
Notify.Default.GenIcon := wmaexe
OnExit(Exit)

ini := A_ScriptDir "\MediPlayer.ini"
RootDir     := IniRead(ini,A_UserName ' Media','DefaultPath','')
TrackNotify := IniRead(ini,A_UserName ' Media','NotifyTrack',1)
MediaFolder := IniRead(ini,A_UserName ' Media','Path','')
Volume := IniRead(ini,A_UserName ' Media','Volume',40)

if !MediaFolder
|| !DirExist(MediaFolder)
    MediaFolder := OpenFolder()

if !DirExist(MediaFolder)
{
    Notify.show('Unable to find Folder`n' MediaFolder)
    IniWrite('nil',ini,A_UserName ' Media','Path')
    MediaFolder := OpenFolder()
}

; creating playlist
Playlist := Map()
List := []
MediaExts := 'mp3|wav|midi|wma'

mPause := 0

loop files, MediaFolder "\*", 'RF'
    if InStr(MediaExts,A_LoopFileExt)
        Playlist[A_LoopFileName] := A_LoopFileFullPath, List.Push(A_LoopFileName)

if List.length = 0
{
    Notify.show('Unable to find any Support Media`n' MediaFolder)
    IniWrite('nil',ini,A_UserName ' Media','Path')
    exitapp
}

; todo tie functions to tray
tray := A_TrayMenu
tray.Delete()
tray.Add("Show Current Track",showCurrentTrack)
tray.Default := "Show Current Track"
tray.ClickCount := 1
tray.Add("Ctrl+Shift+O >> Select Media Folder",(*) => SetNewFolder())
tray.Add("Ctrl+Shift+J >> Jumps to Folder",(*) => Run(MediaFolder))
tray.Add("Ctrl+Shift+P >> Play/Pause",(*) => PlayPause())
tray.Add("Ctrl+Shift+S >> Skip track",(*) => ChooseRandMedia(0))
tray.Add()
tray.Add("(Alt) Ctrl+Shift+ (i or Wheelup)  >> Volume Increase",(*) => ChangeVolume(+15))
tray.Add("(Alt) Ctrl+Shift+ (d or Wheeldown) >> Volume decrease",(*) => ChangeVolume(-15))
tray.Add()
tray.Add("Preference",(*) => ChangePreference())
tray.Add()
tray.Add("Ctrl+Shift+Delete >> Delete Track",(*) => a_now)
tray.Add("Ctrl+Shift+Esc >> Exitapp",(*) => ExitApp())
tray.Add()
tray.Add('Suspend',(*) => Suspend(-1))
tray.Add()
tray.Add("About",(*) => Run('https://' script.homepagelink))
tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()

ShellDll := A_WinDir "\System32\shell32.dll"

wmploc := A_WinDir "\System32\wmploc.dll"

tray.SetIcon("Show Current Track", wmploc, 60)
tray.SetIcon("Ctrl+Shift+O >> Select Media Folder", ShellDll, 267)
tray.SetIcon("Ctrl+Shift+J >> Jumps to Folder", ShellDll, 264)
tray.SetIcon("Ctrl+Shift+S >> Skip track", wmploc, 134)
tray.SetIcon("Ctrl+Shift+P >> Play/Pause", wmploc,136) ; 92 play

tray.SetIcon("(Alt) Ctrl+Shift+ (i or Wheelup)  >> Volume Increase", ShellDll, 247)
tray.SetIcon("(Alt) Ctrl+Shift+ (d or Wheeldown) >> Volume decrease", ShellDll, 248)
tray.SetIcon("Ctrl+Shift+Delete >> Delete Track", ShellDll, 260)
tray.SetIcon('Preference',wmaexe)
tray.SetIcon("Ctrl+Shift+S >> Skip track", ShellDll, 268)
tray.SetIcon("Ctrl+Shift+Esc >> Exitapp", ShellDll, 110)
tray.SetIcon("About", ShellDll, 14)
;tray.AddStandard()
;tray.Add("Settings",(*) => ClipGui.show())

wma:= ComObject("WMPlayer.OCX")
; xx := 
; (
;     "Variant type:`t" ComObjType(wma) "
;     Interface name:`t" ComObjType(wma, "Name") "
;     Interface ID:`t" ComObjType(wma, "IID") "
;     Class name:`t" ComObjType(wma, "Class") "
;     Class ID (CLSID):`t" ComObjType(wma, "CLSID")
; )
; A_Clipboard := xx

;IniWrite(ComObjValue(wma),ini,A_UserName ' Media','COM')
wma.settings.volume := Volume
mFileduration:= 0
mFile := ChooseRandMedia(0)
wmaMedia := wma.newMedia(mFile)

wma.controls.play
; checking if playing done playing then play next song
SetTimer CheckPLay, 10 


#hotif !WinActive('ahk_exe Resolve.exe')
^+s::ChooseRandMedia(0)
Pause:: ;Pause media player
Media_Play_Pause:: ;Pause media player
^+p::PlayPause()
^+o::SetNewFolder() ;allows for selecting of new folder
^+esc::exit ;Quits the program
^+i::ChangeVolume(+5)
^+d::ChangeVolume(-8)
^+Wheelup::ChangeVolume(+5)
^+WheelDown::ChangeVolume(-5)
^+j::Run(MediaFolder)
^+Delete::DeleteTrack() ;msgbox('under construction')
^!+i::ChangeVolume(+15)
^!+d::ChangeVolume(-15)
^#NumpadDot::ChangeVolume(-(Volume??0)+3) ; set volume to 3 >> hotkey for participant counter 
#hotif

; ^+Delete:: ; will delete the file but ask user before deleting
; openfolder
OpenFolder()
{
    global MediaFolder, RootDir
    settimer focusDirectUIHWND2, -500 ; we need settimer because next line lock the script execution
    MediaFolder := FileSelect('D',RootDir,'Select Media Folder') ; 
    if !MediaFolder
        return 0
    IniWrite(MediaFolder,ini,A_UserName ' Media','Path')
    return MediaFolder
}

focusDirectUIHWND2() ; move focus to folder selection from edit1
{
    WinWaitActive 'Select Media Folder' ; this is also lock the execution if settimmer 
    ControlFocus('DirectUIHWND2','Select Media Folder')
    send '{down}{up}' ; using up and down to select first item. in DirectUIHWND2 control
}

DeleteTrack()
{
    global Playlist, List
    if !IsObject(wma)
        return
    SplitPath(wma.url,&trackName,&mfolder,&oExt)
    if 'yes' = MsgBox(
        'Are you sure you want to delete following song`n`n"' trackName '"', 
        'MediaPLayer : Track Delete!',
        'y/n IconX'
    )
    {
        wma.controls.stop
        wma.url := ''
        ;FileDelete(mfolder '\' trackName)
        FileRecycle mfolder '\' trackName
        if A_LastError 
            return notify.show('unable to delete')

        for ltrackname in List
            if ltrackname = trackName
                List.RemoveAt(a_index), Playlist.Delete(trackName)
        notify.show({HDtext:'File deleted',BDtext:trackName})
        ChooseRandMedia(0)
    }
}

SetNewFolder()
{
    global MediaFolder, Playlist, List, mPause
    if !IsObject(wma)
        return Notify.show('Media Player COM is not ready try again...!')
    MediaFolder := OpenFolder()
    if !MediaFolder
        return
    oldplaylist := Playlist.Clone()
    Playlist := map()
    List := []
    loop files, MediaFolder "\*", 'RF'
    if InStr(MediaExts,A_LoopFileExt)
        Playlist[A_LoopFileName] := A_LoopFileFullPath, List.Push(A_LoopFileName)

    if List.length = 0
    {
        Notify.show('Unable to find any Support Media`n' MediaFolder)
        Playlist := oldplaylist.Clone()
        SetNewFolder()
    }
    ChooseRandMedia(0)
    mPause := 0
}

; Choosing Random File to play
ChooseRandMedia(n)
{
    Global mFileduration, wmaMedia, mPause
    if !IsObject(wma)
        return
    mPause := 0
    TraySetIcon wmaexe
    Notify.Default.GenIcon := wmaexe

    if List.Length = 0
    {
        notify.show('No Media found in folder')
        exitapp
    }

    i := 0
    while( i = 0 && i = n)
        i := Random(1,List.Length)
    wma.url:=Playlist[List[i]]
    wmaMedia := wma.newMedia(wma.url)
    mFileduration:= wmaMedia.getItemInfo("Duration")
	; wma.settings.volume:=10
    wma.controls.stop
    wma.controls.play
    
    Artist := wmaMedia.getItemInfo('Artist')
    Title := wmaMedia.getItemInfo('Title')
    Album := wmaMedia.getItemInfo('Album')
    Duration := wmaMedia.getItemInfo('Duration')

    ;  If artist is there, and clicked, leave as is
    
    notifyText := ''
    notifyText .= Title  ? '      Title: <a href="' CreateAmazonLink(Title,Artist) '" >'   Title  '</a>`n' : ''
    notifyText .= Artist ? '     Artist: <a href="' CreateAmazonLink(Artist) '" >'  Artist '</a>`n' : 'Unknown`n'
    notifyText .= Album  ? '    Album: <a href="' CreateAmazonLink(Album,Artist) '" >'     Album  '</a>`n' : ''
    notifyText .= Duration ? 'Duration: ' FmtSecs(Duration) '' : ''

    ;Notify.CloseLast()
    if TrackNotify
        Notify.show({Link:Trim(notifyText,'`n'),HDText:'Now Playing'})
    return wma.url
}

CreateAmazonLink(search,artist:=0)
{
    s := ( artist ? artist ' ' : '') search
    return "https://www.amazon.com/s?k=" TextEncode( s ) "&tag=theautomator01-20&language=en_US&ref_=as_li_ss_tl"
}

showCurrentTrack(*)
{
    Artist := wmaMedia.getItemInfo('Artist')
    Title := wmaMedia.getItemInfo('Title')
    Album := wmaMedia.getItemInfo('Album')
    Duration := wmaMedia.getItemInfo('Duration')
    notifyText := ''
    notifyText .= Title  ? '      Title: <a href="' CreateAmazonLink(Title,Artist) '" >'   Title  '</a>`n' : ''
    notifyText .= Artist ? '     Artist: <a href="' CreateAmazonLink(Artist) '" >'  Artist '</a>`n' : 'Unknown`n'
    notifyText .= Album  ? '    Album: <a href="' CreateAmazonLink(Album,Artist) '" >'     Album  '</a>`n' : ''
    notifyText .= Duration ? 'Duration: ' FmtSecs(Duration) '' : ''
    ;Notify.CloseLast()
    Notify.show({Link:Trim(notifyText,'`n'),HDText: mPause ? 'Paused' :'Now Playing'})
}

CheckPLay()
{
    Global mPause
    if wma.PlayState = 1
    && mPause = 0 ;(wma.controls.currentPosition) = mFileduration) ; or wma.controls.currentPosition = 0
    {
        sleep 1000
        ChooseRandMedia(0)
    }
}

PlayPause()
{
    global mPause
    static toggle := 0
    if !IsObject(wma)
        return Notify.show('Media Player is not ready')
    if toggle = 0
    {
        mPause := 1
        wma.controls.pause
        TraySetIcon stopico
        Notify.Default.GenIcon := stopico
        Notify.show('Paused')
        tray.SetIcon("Ctrl+Shift+P >> Play/Pause", wmploc,92)
    }
    else
    {
        mPause := 0
        Notify.Default.GenIcon := wmaexe
        Notify.show('Playing Continue')
        tray.SetIcon("Ctrl+Shift+P >> Play/Pause", wmploc,136)
        TraySetIcon wmaexe
        while !FileExist(wma.url)
            sleep 200
        wma.controls.play
        ; try
        ;     wma.controls.play
        ; catch 
        ; {
        ;     while !FileExist()
        ;         sleep 200
        ;     wma.controls.play
        ; }
    }
    toggle := !toggle
}

ChangeVolume(n)
{
    Global Volume
    static found := 0
    if !IsObject(wma)
        return
    wma.settings.volume := Volume  + n ; make sure we are in limit
    volume := wma.settings.volume
    IniWrite(Volume,ini,A_UserName ' Media','Volume')
    ; looping through all the Gui matching if anyone has word volume in it then change volume in there
    for i, Gui in MultiGui.Guis
    {
        try ctrlText := Gui['text'].value
        catch 
            ctrlText := 0
        if InStr(ctrlText,"Volume")
        {
            Gui['text'].value := "Volume:" volume
            return sleep(300)
        }
    }
    ; did found volume notify so creating new one
    Notify.show({BDText:"Volume:" volume "  ", GenDuration:6})
}

ControlExist(Control, WinTitle:="", WinText:="", ExcludeTitle:="", ExcludeText:="") {
    try return ControlGetHwnd(Control, WinTitle, WinText, ExcludeTitle, ExcludeText)
    return 0
}

exit(*)
{
    if IsSet(wma)
    && IsObject(wma)
        wma.close
    Notify.show({BDText:'Exitting...!',GenDuration:3})
    Sleep 1000
    exitapp
}

FmtSecs(t:=0) { ; v0.50 by SKAN on D36G/H @ tiny.cc/fmtsecs
Local D:=0, H:=0, M:=0, HH:=0, Q:=60, R:=3600, S := 86400
Fmt:="{:}d {:02}h {:02}m {:02}s"
if t = ""
    t := 0
t:=Trans(t)
D:=(t//S + 0)
H:=(t:=Trans(t)-D*S)//R
M:=(t:=Trans(t)-H*R)//Q
xS:= Trans(t)-M*Q
HH:=D*24+H
if xS
    fmt := '{4:}s'
if M
    fmt := '{4:}m {3:}s'
if H
    fmt := '{4:}h {:02}m {:02}s'
if D
    fmt := '{:}d {:02}h {:02}m {:02}s'
Return Format(Fmt, D, H, M, xS, HH, HH*Q+M)
Trans(t) => Round(number(T))
}

TextEncode(str, sExcepts := "-_.", enc := "UTF-8")
{
    hex := "00", func := "msvcrt\swprintf"
    buff := Buffer(StrPut(str, enc)), StrPut(str, buff, enc)   ;转码
    encoded := ""
    Loop {
        if (!b := NumGet(buff, A_Index - 1, "UChar"))
            break
        ch := Chr(b)
        ; "is alnum" is not used because it is locale dependent.
        if (b >= 0x41 && b <= 0x5A ; A-Z
            || b >= 0x61 && b <= 0x7A ; a-z
            || b >= 0x30 && b <= 0x39 ; 0-9
            || InStr(sExcepts, Chr(b), true))
            encoded .= Chr(b)
        else {
            DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", b, "Cdecl")
            encoded .= hex
        }
    }
    return encoded
}

TextDecode(Url)
{
	Pos := 1
	while Pos := RegExMatch(Url, "i)(%(?<val>[\da-f]{2}+))", &code, Pos++)
		Url := StrReplace(Url, code[0], Chr('0x' code.val))
	Return Url
}