#Requires AutoHotkey v2.0

/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-automator                                                  *
 * @version     0.6.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-26-02                                                     *
 * @modified    2024-26-02                                                     *
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

setup()

#Include <UIA-v2\Lib\UIA>
#Include <NotifyV2>
#Include <ScriptObject>
#include <SoundGui>
#Include <ConfigGui>
#SingleInstance Force
Persistent
Notify.Default.BDFontSize := 14
Notify.Default.HDFontColor := 0x23B14D
Notify.Default.HDText := "DeviceMute"
MultiGui.ShellDll := "ddores.dll"
Notify.Default.GenIcon := 4
Notify.Default.GenIconSize := 50
Notify.Default.GenLoc := iniread(ini, "Settings-" A_UserName,"MuteNotePos",'BottomRight')



script := {
	        base : ScriptObj(),
	     version : "0.6.1",
	        hwnd : '',
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : '2024-02-26',
        iconfile : "ddores.dll",
    homepagetext : "the-automator.com/DeviceMute",
	homepagelink : "the-automator.com/DeviceMute?src=app",
       VideoLink : "https://www.youtube.com/watch?v=DWB-vGa5zDI",
         DevPath : "S:\DeviceMute\V2\DeviceMute.ahk",
	  donateLink : 'https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6',
}

;TraySetIcon script.iconfile, 4
tray := A_TrayMenu
tray.Delete()
tray.Add("Mic Mute/Unmute`t" HKToString(cGui.oldHK),MuteMicDevice)
tray.Add("Default Speaker Mute/Unmute`t" HKToString(cGui.oldSPHK),DefaultSpeakerMute)
tray.Add("Mute Both`t" HKToString(cGui.oldBHK),MuteUnmuteinout)
tray.Add()
tray.Add("Change Microphone" ,ChooseSoundDevice)
tray.Add("Preferences",(*) => (DisableallHotkeys(),cgui.Show(), (IsSet(scGui)?a_now:scGui.hide())))
tray.Add()
tray.Default := "Preferences"
tray.ClickCount := 1
tray.Add("About",(*) => Script.About())
tray.Add("Intro Video",(*) => Run(script.VideoLink))
tray.SetIcon("Intro Video","imageres.dll", 19)
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()
;TraySetIcon script.iconfile

if !DeviceName := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceName",0)
{
    ChooseSoundDevice()
    return
}
DeviceNum := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceNum",0)
try micMute := SoundGetMute(DeviceName,DeviceNum)
catch
    {
        Notify.show('Microphone Devices Disconnected/removed please Select new Microphone Device')
        ChooseSoundDevice()
        return
    }
if micMute
    TraySetIcon IconMute
else
    TraySetIcon IconUnmute

MuteUnmuteinout(*)
{
    MuteNote := IniRead(ini, "Settings-" A_UserName,"MuteNote",0)
    default_device := SoundGetName()
    Send "{Volume_Mute}"
    DeviceName := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceName",0)
    DeviceNum := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceNum",0)
    MuteNote := IniRead(ini, "Settings-" A_ComputerName,"MuteNote",0)
    Mute := SoundGetMute(,default_device)
    if Mute
        MuteIn(DeviceName,DeviceNum,MuteNote)
    else
        UnMuteIn(DeviceName,DeviceNum)
}

UnMuteIn(DeviceName,DeviceNum)
{
    ;tray.Rename("Unmute Both","Mute Both")
    SoundSetMute(0,DeviceName,DeviceNum)
    Notify.CloseLast()
    Notify.show({BDText:"Both Devices set to unmute",GenIcon:IconUnmute,HDFontColor:0x23B14D})
    TraySetIcon IconUnmute
}

MuteIn(DeviceName,DeviceNum,MuteNote)
{
    ;tray.Rename("Mute Both","Unmute Both")
    SoundSetMute(1,DeviceName,DeviceNum)
    TraySetIcon IconMute
    Notify.CloseLast()
    if MuteNote
        Notify.show({BDText:"Both Devices set to mute`nClick here to Unmute",GenIcon:IconMute,HDFontColor:"Red",GenCallback:MuteUnmuteinout})
    else
        Notify.show({BDText:"Both Devices set to mute",GenIcon:IconMute,HDFontColor:"Red"})
}


DefaultSpeakerMute(*)
{
    ; add default speaker function here
    MuteNote := IniRead(ini, "Settings-" A_UserName,"MuteNote",0)
    default_device := SoundGetName()
    Send "{Volume_Mute}"
    Mute := SoundGetMute(,default_device)
    If Mute
    {
        Notify.CloseLast()
        if MuteNote
        {
            Notify.show({BDText:"Default Speaker set to mute`nClick here to Unmute",GenIcon:IconSpMute,HDFontColor:"Red",GenCallback:DefaultSpeakerMute})
        }
        else
            Notify.show({BDText:"Default Speaker set to mute",GenIcon:IconSpMute,HDFontColor:"Red"})
    }
    Else
    {
        Notify.CloseLast()
        Notify.show({BDText:"Default Speaker set to unmute",GenIcon:IconSpUnmute,HDFontColor:0x23B14D})
    }
}

; Run Script with Left Control Key Down to Force Choose Sound Device, or Delete Settings.ini to reset
MuteMicDevice(*)
{
    DeviceName := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceName",0)
    DeviceNum := IniRead(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName, "DeviceNum",0)

    MuteNote := IniRead(ini, "Settings-" A_ComputerName,"MuteNote",0)

    try
        cmpName := SoundGetName(DeviceName, DeviceNum)
    catch
    {
        IniDelete(A_ScriptDir "\Settings.ini", "Mic-" A_ComputerName)
        DeviceName := 0
        DeviceNum := 0
        Notify.Show("Device " DeviceName " " DeviceNum " NotFound!`nMic settings reset")
    }

    if DeviceName = 0
    && DeviceNum = 0
    {
        ChooseSoundDevice()
        return
    }
    try micMute := SoundGetMute(DeviceName,DeviceNum)
    catch
        {
            Notify.show('Microphone Devices Disconnected/removed please Select new Microphone Device')
            ChooseSoundDevice()
            return
        }
    If micMute=1
    {
        Notify.CloseLast()
        SoundSetMute(0,DeviceName,DeviceNum)
        Notify.show({BDText:"Mic set to unmute",GenIcon:IconUnmute,HDFontColor:0x23B14D})
        TraySetIcon IconUnmute
    }
    Else
    {
        Notify.CloseLast()
        SoundSetMute(1,DeviceName,DeviceNum)
        TraySetIcon IconMute
        if MuteNote
            Notify.show({BDText:"Mic set to mute`nClick here to Unmute",GenIcon:IconMute,HDFontColor:"Red",GenCallback:MuteMicDevice})
        else
            Notify.show({BDText:"Mic set to mute",GenIcon:IconMute,HDFontColor:"Red"})
    }
}

setup(){
    DirCreate 'res'
    FileInstall 'res\MicMute.ico', 'res\MicMute.ico', true
    FileInstall 'res\MicUnmute.ico', 'res\MicUnmute.ico', true
    FileInstall 'res\SpMute.ico', 'res\SpMute.ico', true
    FileInstall 'res\SpUnMute.ico', 'res\SpUnMute.ico', true
}