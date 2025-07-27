#SingleInstance
#Requires AutoHotkey v2.0
#include <NotifyV2>
#Include <Messeages>
#Include <OnClock>
#include <ScriptObj\scriptobj>

/*
* ============================================================================ *
* Want a clear path for learning AutoHotkey?                                   *
* Take a look at our AutoHotkey courses here: the-Automator.com/Discover          *
* They're structured in a way to make learning AHK EASY                        *
* And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
* ============================================================================ *
*/

;**  TIME_ZONE_ID_DAYLIGHT := 2 ;TIME_ZONE_ID_STANDARD := 1
;**  TIME_ZONE_ID_UNKNOWN := 0 ;'Daylight saving time is not used'

; TIME_ZONE_INFORMATION := Buffer(172,0)
; vIsDST := (DllCall("GetTimeZoneInformation", "Ptr",TIME_ZONE_INFORMATION) = 2)


daylightSavings := 1 ; vIsDST
ZOOMLINK := 'http://the-Automator.com/AHKHeroMember?src=Reminder' ; Change this to the direct link to the zoom meeting

script := {
	        base : ScriptObj(),
			hwnd : 0,
	     version : "1.0.0",
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	   resfolder : A_ScriptDir '\res',
	    iconfile : A_ScriptDir '\res\gap.ico' ,
	homepagetext : "the-automator.com/downloads/herocall-notifier", ; https://www.the-automator.com/downloads/herocall-notifier/
	homepagelink : "the-automator.com/downloads/herocall-notifier?src=app",
	  donateLink : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}


timeObject := Map(
    'Friday', {
                    HH:15-daylightSavings,            ; UTC hour
                    mm:[60,30,15,4],    ; Minutes Before you get notified
                    len:2             ; len/how long Hero call in hours
    },
    'Saturday', {
                    HH:16-daylightSavings,         ; UTC hour
                    mm:[60,30,15], ; Minutes Before you get notified
                    len:1
    }
)

Notify.default := {
    HDText: 'Hero Call Reminder!',
    HDFontSize:20,
    BDFontSize:18,
    GenDuration:10, ; time in seconds to display the notification
    GenIcon: "res\AHKHero.png",
    GenIconSize: 64,
}
TraySetIcon 'mmcndmgr.dll', 15

tray := A_TrayMenu
tray.Delete()
tray.Add("Remind me Hero Call",(*) => timeleft())
tray.SetIcon("Remind me Hero Call",'mmcndmgr.dll', 15)
tray.Add("Join Hero Call",(*) => run(ZOOMLINK)) ; Hero members can swap this to the direct url to the zoom meeting
tray.default := "Remind me Hero Call"
tray.ClickCount := 1 ; how many clicks (1 or 2) to trigger the default action above
tray.Add()
tray.Add("Startup",toggleStartup)
tray.check("Startup")
tray.Add()
tray.Add("About",(*) => Script.About())
tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()
;tray.Add("Reload",(*) => Reload())
;tray.Add("Exitapp",(*) => ExitApp())
; tray.AddStandard()

; add startup ability
Startup := 1 ; turn it zero script will not run in startup
if Startup
	RegWrite(A_ScriptFullPath, 'REG_SZ', 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run', A_ScriptName)
else
	RegDelete('HKCU\Software\Microsoft\Windows\CurrentVersion\Run\' A_ScriptName)

SchTime := 0

onclock.change(CheckforHerocall)


timeleft()
{
    Day := FormatTime(A_NowUTC,'dddd')
    tHH := FormatTime(A_NowUTC,'HH')
    tMM := FormatTime(A_NowUTC,'mm')
    if timeObject.Has(day)
    {
        hh := timeObject[day].hh 
        hh := HH - thh
        MM := 60 - tMM  
        len := -(timeObject[day].len)
        ;msgbox len '--'
        if( hh >= 0)
        {
            if MM = 60
                MM:=0, hh+=1
            Notify.show( ( hh ? hh ' hrs ' : '') MM ' min until Todays Call')   
        }
        else if HH < 0 && HH >= -timeObject[day].len
        {
            Notify.show('Hero Call is ongoing')
        }
        else if hh < -timeObject[day].len
            Notify.show("Today's Hero Call has already finished")
        return
    }
    Notify.show('there are no calls for today')   
}

CheckforHerocall()
{
    Global SchTime
    Day := FormatTime(A_NowUTC,'dddd')
    time := FormatTime(A_NowUTC,'HH:mm')
    if timeObject.Has(day)
    {
        hh := timeObject[day].hh
        for minutes in timeObject[day].mm
        {
            Notifytime := Format('{1:02d}:{2:02d}',hh, 60-minutes) ; HH:mm
            hour := 0
            if time = Notifytime
            {
                if minutes = '15'
                    Notify.show({link:GetMsgNoLink(minutes=60 ? '1 hour' : minutes ' minutes')})
                else
                    Notify.show({link:GetMsg(minutes=60 ? '1 hour' : minutes ' minutes')})
                break    
            }
        }
    }
}

toggleStartup(*)
{
    Global Startup
    Startup := !Startup
    tray.ToggleCheck("Startup")
    if Startup
        RegWrite(A_ScriptFullPath, 'REG_SZ', 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run', A_ScriptName)
    else
        try RegDelete('HKCU\Software\Microsoft\Windows\CurrentVersion\Run\', A_ScriptName)
}