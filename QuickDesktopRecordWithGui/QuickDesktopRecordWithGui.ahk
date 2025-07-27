/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.1.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-06-01                                                     *
 * @modified    2025-06-02                                                     *
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
;@Ahk2Exe-SetVersion     "0.1.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName the-Automator 
;@Ahk2Exe-SetDescription the-Automator
#Requires AutoHotkey v2.0.2+
#SingleInstance Force ;Limit one running version of this script
DetectHiddenWindows true ;ensure can find hidden windows
ListLines True ;on helps debug a script-this is already on by default
SetWorkingDir A_InitialWorkingDir ;Set the working directory to the scripts directory

TraySetIcon("C:\Windows\system32\wiashext.dll", 14)
; Include the FFmpeg library and Notify class
#Include "<FFmpeg>"
#Include "<NotifyV2>"
#Include "<ScriptObject>"
#Include "<Triggers>"
#include "<prefGui>"
#Include "<GetWaveIN>" 

; Initialize global variables
global processId := 0           ; Stores the FFmpeg process ID
global ffWinId := ""            ; Stores the FFmpeg window ID
global fileName := ""           ; Stores the output file name
global countdownActive := false ; Flag to track if countdown is active
global settingsFps := 0         ; FPS setting
global settingsType := ""       ; Output file type
global hotkeyStop := ""         ; Hotkey to stop recording
global secondsLeft := 0         ; Countdown seconds
global microphoneName := ""     ; Stores the selected microphone name
; global microphoneNumber := 0    ; Stores the selected microphone number
global winPositionX := 0        ; Default X position for the window
global winPositionY := 0        ; Default Y position for the window
global hasRecorded := false      ; Flag to track if a recording has been made

triggers.tray.Add('about',(*)=>script.About())
triggers.tray.Add()
triggers.AddHotkey(Start,"Start Recording",'^+r')
triggers.AddHotkey(StopRecording,"Stop Recording","^+s")
triggers.tray.Add('Exit`tCtrl+Shift+Esc', (*) => true) ; Add hotkey to tray menu
triggers.FinishMenu()

triggers.save.onevent('click',Savesettings) ; Pref Gui save settings
triggers.tray.add('Open Folder',(*)=>Run(A_ScriptDir))
triggers.tray.AddStandard()

; Check if settings file exists
settingsFileExists := FileExist(A_ScriptDir "\settings.ini")

sGui := Gui('-DPIScale +ToolWindow +AlwaysOnTop', 'Recorder')
script := {
	        base : ScriptObj(),
	     version : "0.1.0",
	        hwnd : sGui.Hwnd,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	   resfolder : A_ScriptDir "\res",
		iconfile : 'mmcndmgr.dll',
	         ini : A_ScriptDir "\settings.ini",
	homepagetext : "Quick Desktop Record With Gui",
	homepagelink : "the-automator.com/QuickRecord?src=app",
	DavPath		 : "S:\ffmpeg\QuickDesktopRecord\QuickDesktopRecordWithGui.ahk",
	VideoLink 	 : "",
	;   donateLink : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6",
}

; Added menu bar with Preferences for easy access
menuBars := MenuBar()
menuBars.Add("Preferences", (*) => triggers.Show())
sGui.MenuBar := menuBars

sGui.OnEvent('Close', (*) => (
    GetWindowPosition()
    IniWrite(winPositionX, A_ScriptDir "\settings.ini", "Settings", "window_position_x")
    IniWrite(winPositionY, A_ScriptDir "\settings.ini", "Settings", "window_position_y")
    StopRecording()
    ExitHandler()
))
sGui.SetFont('s16 w500','Arial')
sGui.MarginX := 2
sGui.MarginY := 2
sGui.AddButton('','Start').OnEvent('Click', Start )
sGui.AddButton('x+m','Stop').OnEvent('Click', StopRecording )
;sGui.AddButton('x+m', 'Preferences').OnEvent('Click', (*) => triggers.Show()) ;Added for easy access to preferences
sGui.SetFont('s30 w700')
sGui.AddText('x+m center yp+1 vTime','00:00')

sGui.DisplayTime := a_yyyy A_MM a_DD
sGui.BalanceTime := 0
sGui.StartTickCount := A_TickCount
trymiccheck := 0
if microphoneName := IniRead(triggers.ini,A_ComputerName, "DeviceName",0)
	try trymiccheck := SoundGetVolume(, microphoneName ) + 20 ; checking sound device available
if trymiccheck
	micddl.text := microphoneName
else
{
	triggers.Show()
	Notify.Show('Please Select Microphone')
	return
}


if (settingsFileExists) 
{
    winPositionX := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_x",0)
    winPositionY := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_y",0)
    IF winPositionY
        sGui.Show("x" . winPositionX . " y" . winPositionY)
    else
        sGui.Show()
} 
else 
{
    sGui.Show()
}
; Get the current window position
GetWindowPosition()


; Create settings file if it doesn't exist
if (!settingsFileExists) {

    configContent := "
    (
    [Main]
    Record=^+r
    Stop=^+s

    [Settings]
    fps_cap=30
    type=mp4
    microphone_name=Microphone
    microphone_number=1
    )" . "`n"

    configContent .= "window_position_x=" . winPositionX . "`n"
    configContent .= "window_position_y=" . winPositionY . "`n"
    
    FileAppend(configContent, A_ScriptDir "\settings.ini")
}

UpdateRecordingSettings() ; running this function instead following to read settings from the INI file
/* 
; Read settings from INI file
hotkeyRecord := IniRead(A_ScriptDir "\settings.ini", "Main", "Record", "^+r")
hotkeyStop := IniRead(A_ScriptDir "\settings.ini", "Main", "Stop", "^+s")
settingsFps := IniRead(A_ScriptDir "\settings.ini", "Settings", "fps_cap", "30") ; 20,30,40,50,60
settingsType := IniRead(A_ScriptDir "\settings.ini", "Settings", "type", "mp4")  ; mp4,mkv
; microphoneName := IniRead(A_ScriptDir "\settings.ini", "Settings", "microphone_name", false)
; microphoneNumber := IniRead(A_ScriptDir "\settings.ini", "Settings", "microphone_number", "1")
winPositionX := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_x", winPositionX)
winPositionY := IniRead(A_ScriptDir "\settings.ini", "Settings", "window_position_y", winPositionY)

; Convert settings to appropriate types
settingsFps := Integer(settingsFps)
; microphoneNumber := Integer(microphoneNumber) 
*/

Start(*)
{
    global hasRecorded

    Record()
    Sleep(3000) ; Wait for 3 seconds before starting the timer
	sGui.StartTickCount := A_TickCount - sGui.BalanceTime 
	SetTimer(Watching, 10)
    hasRecorded := true
}

StopRecording(*)
{
    global hasRecorded

    if (hasRecorded)
    {
        hasRecorded := false
        Coptime()
        sGui['Time'].value := '00:00'
        sGui.DisplayTime := a_yyyy A_MM a_DD
        sGui.BalanceTime := 0
        sGui.StartTickCount := A_TickCount
        SetTimer(Watching, 0)
        Stop()
    }
}


Watching(*)
{
	If ((A_TickCount - sGui.StartTickCount) >= 1000)       		; if current tickcount - StartTickCount >= 1000 (i.e. 1 second)
	{ 
		sGui.StartTickCount += (1000)
		sGui.DisplayTime := DateAdd(sGui.DisplayTime, 1, 'Seconds')
		sGui['Time'].value  := FormatTime(sGui.DisplayTime, 'mm:ss')  ;    format ElapsedTime to mm:ss
	}
}

Coptime(*)
{
	Notify.Show({
		HDText: "Time recorded",
		BDText: sGui['Time'].value,
		BDFontSize: 24,
		GenIcon: script.iconfile ',15',
        GenDuration: 5
	})
}

GetWindowPosition(*)
{
    global winPositionX, winPositionY
    WinGetPos(&winPositionX, &winPositionY,,, "Recorder")
    IniWrite(winPositionX,A_ScriptDir "\settings.ini", "Settings", "window_position_x")
	IniWrite(winPositionY,A_ScriptDir "\settings.ini", "Settings", "window_position_y")
}

;---------------------------------------------------------------------------

; Set up the coordinate mode for tooltips
CoordMode "ToolTip", "Screen"
/* 
; Set up hotkeys
Hotkey hotkeyRecord, RecordHandler
Hotkey hotkeyStop, StopHandler

; Set up OnExit handler
OnExit ExitHandler

; Handler functions for menu and hotkeys
RecordHandler(*) {
    Record()
}

StopHandler(*) {
    Stop()
}
 */
; ToggleGifHandler(*) {
;     global createGif
    
;     ; Flip the state
;     createGif := !createGif
    
;     ; Update INI file
;     IniWrite(createGif ? "1" : "0", A_ScriptDir "\settings.ini", "Settings", "create_gif")
    
;     ; Update menu state
;     if (createGif)
;         A_TrayMenu.Check("Create GIF")
;     else
;         A_TrayMenu.Uncheck("Create GIF")
    
;     ; Show notification
;     Notify.Show({
;         HDText: "GIF Creation " (createGif ? "Enabled" : "Disabled"),
;         BDText: createGif ? "GIFs will be created after recording" : "GIFs will not be created after recording",
;         GenDuration: 2,
;         GenSound: "Information",
;         GenIcon: "Information",
;         GenLoc: "C"
;     })
; }

/*
ListAudioDevicesHandler(*) {
    ListAudioDevices()
}

SelectMicrophoneHandler(*) {
    SelectMicrophone()
} 
*/

OpenSettingsHandler(*) {
    OpenSettings()
}

ExitHandler(*) {
    CleanupAndExit()
    ExitApp
}

; Start recording function
Record() {
    global processId, fileName, countdownActive, settingsType
    global secondsLeft

    ; Don't allow starting a new recording if one is already in progress
    if (processId != 0)
        return
        
    ; Don't allow multiple countdowns
    if (countdownActive)
        return
        
    ; Generate timestamp for the filename in the requested format
    fileName := A_ScriptDir "\" FormatTime(, "yyyy-MM-dd-HH-mm") "." settingsType
    
    ; Show countdown
    countdownActive := true
    secondsLeft := 3
    
    ; Using Notify for countdown
    Notify.CloseLast() ; Close any existing notifications
    
    ; Show first countdown notification
    DisplayCountdown()
    
    ; Start countdown timer
    SetTimer(DisplayCountdown, 1000)
}

; Display countdown notification
DisplayCountdown() {
    global secondsLeft, hotkeyStop, countdownActive
    
    if (secondsLeft > 0) {
        ; Show notification with countdown - set to auto-close after 1 second
        ; Using 'C' for the GenLoc parameter to position it in the center of the screen
        Notify.Show({
            HDText: "Recording will start soon",
            BDText: "Recording will start in " secondsLeft " seconds.`nPress " hotkeyStop " to stop recording.",
            GenDuration: 1, ; Auto-close after 1 second
            GenSound: "Exclaim",
            GenIcon: "Information",
            GenLoc: "C" ; Position in center of screen
        })
        secondsLeft--
    } else {
        ; Cancel the timer
        SetTimer(DisplayCountdown, 0)
        countdownActive := false
        
        ; Start the actual recording without showing a notification
        StartRecording()
    }
}

; Function to start the recording after countdown
StartRecording() {
    global processId, ffWinId, fileName, settingsFps, settingsType, hotkeyStop, microphoneName
    settingsFps  := IniRead(triggers.ini, "Settings", "fps_cap", "30" )  ; 20,30,40,50,60
    settingsType := IniRead(triggers.ini, "Settings", "type"   , "mp4")  ; mp4,mkv
    ; Create a command-line session to run FFmpeg
    cmd := A_ComSpec " /k " ; Use A_ComSpec instead of ComSpec
    
    ; Set up FFmpeg parameters - using quotes for better readability
    ffParams := "ffmpeg -f gdigrab -video_size " A_ScreenWidth "x" A_ScreenHeight 
               . " -framerate " settingsFps 
               . " -i desktop"
               . " -f dshow -i audio=`"" microphoneName "`""
               . " -c:v libx264 -preset ultrafast"
               . " -c:a aac -b:a 128k"
               . " -pix_fmt yuv420p"
               . " `"" fileName "`""
    
    ; Run FFmpeg in a visible command window that we can send stop signals to
    Run cmd . ffParams, A_ScriptDir, "Min", &processId
    
    ; Store the window ID for later use to send the stop command
    if (processId) {
        ; Set priority
        ProcessSetPriority "High", processId
        
        ; Wait for the window to appear
        WinWait "ahk_pid " processId
        
        ; Store the window ID
        ffWinId := WinGetID("ahk_pid " processId)
    } else {
        Notify.Show({
            HDText: "Error Starting Recording",
            BDText: "Failed to start FFmpeg process.",
            GenDuration: 5,
            GenSound: "Critical",
            GenIcon: "Critical",
            GenLoc: "C"
        })
    }
}

; Stop function that works by sending 'q' to the FFmpeg window
Stop() {
    global processId, ffWinId, fileName
    
    if (processId == 0 || !ffWinId)
        return
    
    ; Show that we're stopping the recording
    Notify.Show({
        HDText: "Stopping Recording",
        BDText: "Please wait while the recording is being finalized...",
        GenDuration: 0, ; Stay until closed
        GenSound: "Information",
        GenIcon: "Information",
        GenLoc: "C"
    })
    
    ; Try multiple methods to stop FFmpeg gracefully
    
    ; Method 1: Make the window visible and send 'q' (the proper FFmpeg quit command)
    if (WinExist("ahk_id " ffWinId)) {
        WinShow("ahk_id " ffWinId)
        WinActivate("ahk_id " ffWinId)
        SendInput("q")
        Sleep(500)
    }
    
    ; Method 2: If still running, try sending Ctrl+C to the window
    if (ProcessExist(processId)) {
        if (WinExist("ahk_id " ffWinId)) {
            ControlSend("^c",, "ahk_id " ffWinId)
            Sleep(1000)
        }
    }
    
    ; Method 3: If still running, try to close it more forcefully
    if (ProcessExist(processId)) {
        RunWait("taskkill /PID " processId,, "Hide")
        Sleep(1000)
    }
    
    ; Wait for the process to close with timeout
    timeout := 5
    startTime := A_TickCount
    while (ProcessExist(processId) && A_TickCount - startTime < timeout * 1000) {
        Sleep(200)
    }
    
    ; Reset process ID and window ID
    processId := 0
    ffWinId := ""
    
    ; Close the notification
    Notify.CloseLast()
    
    ; Check if the file was created successfully
    if (!FileExist(fileName) || FileGetSize(fileName) < 1000) { ; Less than 1KB is probably not a valid video
        MsgBox("Error: Recording file was not created or is too small. FFmpeg may have encountered an error.", "Recording Error", "Icon!")
        return
    }
    
    ; Copy the file path to clipboard
    A_Clipboard := fileName
    
    ; Prepare message text for the MessageBox
    messageText := "Recording saved to:`n" fileName "`n`nThe file path has been copied to your clipboard."
    
    ; Add question about opening the file
    messageText .= "`n`nWould you like to open the file now?"
    
    ; Show MessageBox asking if they want to run the file
    result := MsgBox(messageText, "Recording Complete", "YesNo Icon!")
    
    ; If user clicked Yes, run the file
    if (result = "Yes") {
        Run fileName
    }
}

; Settings function
OpenSettings() {
    Run A_ScriptDir "\settings.ini"
}

; Clean up and exit function
CleanupAndExit() {
    global processId
    
    ; Close FFmpeg process if it's running
    if (processId != 0) {
        ProcessClose processId
        WinWaitClose "ahk_pid " processId
    }
}

; Hotkey functions
^+Escape::ExitApp ;Control Shift + Escape will Exit the app
