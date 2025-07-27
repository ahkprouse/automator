; Line No. 36 and 37 Enable fro the GetLicense
/*
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */
 
 /*
 This work by the-Automator.com is licensed under CC BY 4.0
 
 Attribution — You must give appropriate credit , provide a link to the license,and indicate if changes were made.
 You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
 No additional restrictions — You may not apply legal terms or technological measures that legally restrict others from doing anything the license permits.
 */
 #Include <ScriptObject>
 #Include <NotifyV2>
 #SingleInstance Force
 #MaxThreads 1
script := {
      base      : ScriptObj(),
   version      : "0.0.2",
      hwnd      : '',
   author       :  "the-Automator",
   email        : "joe@the-automator.com",
   crtdate      : 'April 22, 2024',
   moddate      : 'April 27, 2024',
   homepagetext : "Toggle Between Monitors",
   homepagelink : "https://the-Automator.com/ToggleBetweenMonitors?src=app",
   VideoLink    : "https://www.youtube.com/watch?v=JDvEo1QeSXw",
   DevPath      : "S:\ToggleWindowBetweenMonitors\V2\Toggle between Monitors.ahk",
   donateLink   : '',
}
TraySetIcon("imageres.dll","112")
; ScriptObj.eddID := "97575"
; if !ScriptObj.GetLicense()
;       return

;************************Toggle between monitors*******************************.

MonitorCount := MonitorGetCount()
msg := "We only detected 1 monitor and this script requires multiple.`n`nPlease add an additional monitor(s) and relaunch the script"
IF (MonitorCount = 1)
{
   Notify.show({HDtext:"Error",BDtext: msg,HDFontSize:25,GenLoc:'C',GenIcon:"Critical",GenIconSize:50,GenCallback:(*) => exitapp()})
      return
}


MonitorDDL := []
Loop MonitorCount 
{
   MonitorDDL.Push(A_Index)
}
   

MouseKeys := map('Left Mouse Button','LButton',
'Right Mouse Button','RButton',
'Middle Mouse Button','Mbutton',
'Special Mouse Button 1','XButton1',
'Special Mouse Button 2','XButton2')

Mousekey := []
for k , v in Mousekeys
{
   if (a_index = 1)
      Mousekey.InsertAt(1,"None")
   Mousekey.Push(k)
}

global myGui := Gui("+AlwaysOnTop")
The_TrayMenu()
ini := A_ScriptDir "\Config.ini"
if !FileExist(ini)
{
   iniDidntExist := true
   IniWrite '!Rbutton', ini, "Hotkeys" ,'HK'
   IniWrite '1' , ini, "Monitor", '1st'
   IniWrite '2' , ini, "Monitor", '2nd'
}

myGui.oldHK := IniRead(ini, "Hotkeys", 'HK' ,'!Rbutton')
hkCtrl.value := RegExReplace(myGui.oldHK, '[!+^#]*')
StrLength := StrLen(hkCtrl.value)

if !(StrLength = 1)
{
   for k , v in Mousekeys
   {
      if InStr(v,hkCtrl.value)   
         ChoseMouse := k
   }
}

DDL_LIST := []
last_Setting := IniRead(ini, "Monitor")
last_Setting := StrSplit(last_Setting, "`n", "`r")
for data in last_Setting
{
   last_Setting := StrSplit(data,'=')
   DDL_LIST.PUSH(last_Setting[2])   
}

Hotkey(MyGui.oldHK,MoveMouse,'off')
myGui.SetFont("s12")

MyGui.Add("GroupBox", "xm w410 h130 vGropBoxHide", "Toggle Monitors")
M1DDL := MyGui.Add("DropDownList", "xp+10 yp+30 vMonitorList1 w100 +ReadOnly", MonitorDDL)
M1DDL.OnEvent('Change',ChangeDDL)

myGui.AddText('x+m v1stToggleText','1st Toggle Monitor')
M2DDL := MyGui.Add("DropDownList", "xp-115 yp+40 vMonitorList2 w100", MonitorDDL)
M2DDL.OnEvent('Change',ChangeDDL)
myGui.AddText('x+m yp+3 v2ndToggleText','2st Toggle Monitor')

if (MonitorGetCount() > 2)
{
   MyGui.Add("GroupBox", "xm yp+60 w410 h220", "Hotkey")
   M1DDL.Choose(DDL_LIST[1])
   M2DDL.Choose(DDL_LIST[2])      
}
else
{
   MonitorArry := [1,2]
   MyGui.Add("GroupBox", "xm yp-60 w410 h220", "Hotkey")
   HideGroupBoxToggleMonitoring()
   M1DDL.Choose(MonitorArry[1])
   M2DDL.Choose(MonitorArry[2])
}

MyGui.SetFont("cPurple")
myGui.AddText('xp+20 yp+30 w80','Modifires').SetFont("cBlack Bold")
MyGui.AddCheckbox('xp yp+40 vSet_Win','Win')

myGui.AddText('xp+120 yp h20 +Center','Mouse').SetFont("cred")
Mouse_DDL := MyGui.Add("DropDownList", " vMousekey xp+80 w180", Mousekey)
if StrLength = 1 or (hkCtrl.value = "CapsLock")
   Mouse_DDL.Choose('None')
else
   Mouse_DDL.Choose(ChoseMouse)

Mouse_DDL.OnEvent('Change',MouseCtrl)

MyGui.AddCheckbox('xp-200 yp+40 vSet_Shift','Shift')

myGui.AddText('xp+60 yp-20 W80 H80 '," &&").SetFont("s40 cBlack")
myGui.AddText('xp+210 yp+20 w30','OR').SetFont("cBlack Bold")

MyGui.AddCheckbox('xp-270 yp+40 vSet_Ctrl','Ctrl')

myGui.AddText('xp+120 yp h20 ','Keyboard').SetFont("cBlue")
myGui.AddHotkey('xp+80 yp-5 vHK ',).OnEvent('change',hkCtrl)

myGui.AddCheckbox('xp-200 yp+50 vSet_Alt','Alt')

myGui.Add("Button", "xm w100 vok", "OK").OnEvent('click',Writehkini)
myGui.Add("Button", "x+m w100","Cancel").OnEvent('click', (*) => (myGui.hide(),CloseAllNotify()) )
if Isset(iniDidntExist)
   myGui.Show()
else
   myGui.hide()
Hotkey(myGui.oldHK,MoveMouse, 'on')

if StrLength = 1 or (hkCtrl.value = 'CapsLock')
   MyGui['HK'].value := hkCtrl.value

if InStr(MyGui.oldHK,"#")
   MyGui['Set_Win'].value := true
else
   MyGui['Set_Win'].value := false

if InStr(MyGui.oldHK,"^")
   MyGui['Set_Ctrl'].value := true
else
   MyGui['Set_Ctrl'].value := false

if InStr(MyGui.oldHK,"+")
   MyGui['Set_Shift'].value := true
else
   MyGui['Set_Shift'].value := false

if InStr(MyGui.oldHK,"!")
   MyGui['Set_Alt'].value := true
else
   MyGui['Set_Alt'].value := false
return 

HideGroupBoxToggleMonitoring()
{
   myGui['GropBoxHide'].opt('+hidden')
   myGui['MonitorList1'].opt('+hidden')
   myGui['MonitorList2'].opt('+hidden')
   myGui['1stToggleText'].opt('+hidden')
   myGui['2ndToggleText'].opt('+hidden')
}

AddToStartup(status)
{
	; add startup ability
	if status
		RegWrite(A_ScriptFullPath, 'REG_SZ', 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run', A_ScriptName)
	else
		try RegDelete('HKCU\Software\Microsoft\Windows\CurrentVersion\Run\' A_ScriptName)
}

MouseCtrl(*)
{
   MyGui['HK'].value := ""
}

hkCtrl(*)
{
   hkCtrl.value := RegExReplace(myGui['HK'].Value, '[!+^]*')
   myGui['HK'].Value := hkCtrl.value
   Mouse_DDL.Choose('None')
}

ChangeDDL(*)
{
   if MyGui['MonitorList1'].Value = MyGui['MonitorList2'].Value
      MyGui['ok'].opt('+Disabled')
   else
      MyGui['ok'].opt('-Disabled')
}

HotkeySetting()
{

   Setkey := ""
   if (myGui['Set_Win'].Value = 1)
      Setkey .= "#"
   if (myGui['Set_Shift'].Value = 1)
      Setkey .= "+"
   if (myGui['Set_Ctrl'].Value = 1)
      Setkey .= "^"
   if (myGui['Set_Alt'].Value = 1)
      Setkey .= "!"
   
   THK := myGui['HK'].value
   HKMouse := myGui['Mousekey'].Text
   for k , v in Mousekeys
   {
      if InStr(k,myGui['Mousekey'].Text)
         HKMouse := v
   }
   
   return {Set:Setkey,HKM:HKMouse,KHK:THK}
}


Writehkini(*)
{   
   MonitorList1 := myGui['MonitorList1'].Value
   if (myGui['MonitorList2'].Value = MonitorList1)
   {
      Notify.Show({BDText:"Check Dropdownlist",HDText:"Toggle Between Monitors",GenIcon:"Critical"})
      ;MyGui['ok'].opt('+Disabled')
      Return
   }

   HK := HotkeySetting()
   IF !(HK.HKM = "None")
      hotkeySet := HK.Set HK.HKM
   else if HK.KHK
      hotkeySet := HK.Set HK.KHK
   
   if !IsSet(hotkeySet)
   {
      Notify.show({HDtext:"Warning",BDtext: 'Please select at least one Modifier key`n(Win, Shift, Alt, or Control) and Mouse or Keyboard' ,HDFontSize:25,GenLoc:'C',GenDuration : 5,GenIcon:"Critical"})
      return
   }
   else
   {
      IF (hotkeySet = "RButton") or (hotkeySet = "LButton")
      {
         Notify.show({HDtext:"Warning",BDtext: 'Please select at least one Modifier key`n(Win, Shift, Alt, or Control)' ,HDFontSize:25,GenLoc:'C',GenDuration : 5,GenIcon:"Critical"})
         return
      }
   }
   

   Hotkey(MyGui.oldHK,MoveMouse,'off')

   Setkey := ""
   if (myGui['Set_Win'].Value = 1)
      Setkey .= "#"
   if (myGui['Set_Shift'].Value = 1)
      Setkey .= "+"
   if (myGui['Set_Ctrl'].Value = 1)
      Setkey .= "^"
   if (myGui['Set_Alt'].Value = 1)
      Setkey .= "!"
   
   ; IF !Setkey
   ; {
   ;    Notify.show({HDtext:"Warning",BDtext: 'Please select at least one Modifier key`n(Win, Shift, Alt, or Control)' ,HDFontSize:25,GenLoc:'C',GenDuration : 5,GenIcon:"Critical"})
   ;    return
   ; }

   IniWrite myGui.oldHK := hotkeySet , ini, "Hotkeys" ,"HK"
   IniWrite myGui['MonitorList1'].value, ini, "Monitor" ,"1st"
   IniWrite myGui['MonitorList2'].value, ini, "Monitor" ,"2nd"
   
   ; switch myGui['AddToStrUp'].value
   ; {
   ;    case 1: 
   ;       IniWrite myGui['AddToStrUp'].value, ini, 'Settings','Startup'
   ;       AddToStartup(true)
   ;    default:
   ;       IniWrite myGui['AddToStrUp'].value, ini, 'Settings','Startup'
   ;       AddToStartup(false)
   ; }

   MyGui.HIDE()
   Hotkey(MyGui.oldHK,MoveMouse,'on')
   CloseAllNotify()
}

MoveMouse(*)
{  

   MonitorList1 := myGui['MonitorList1'].Value
   CoordMode("Mouse", "Screen")
   MouseGetPos(&xpos, &ypos)

   MonitorGet(MonitorList1, &MonitorPrimaryLeft, &MonitorPrimaryTop, &MonitorPrimaryRight, &MonitorPrimaryBottom)
   ;MouseMove(MonitorPrimaryLeft + 50, MonitorPrimaryTop + 50, 0) ;
   
   Mon2 := MonitorList1
   Mon1 := myGui['MonitorList2'].Value

   ;Mon2 := myGui['MonitorList2'].Value
   ;Mon1 := MonitorList1
   MonitorMove(Mon1,Mon2)
}

MonitorMove(Mon1,Mon2)
{
   
   MonitorGet(Mon1, &Mon1Left, &Mon1Top, &Mon1Right, &Mon1Bottom) ; Now grab correct screens
   MonitorGet(Mon2, &Mon2Left, &Mon2Top, &Mon2Right, &Mon2Bottom) ; Grab monitor number 3 create a Mon1 var

   MouseGetPos(, , &windowundermouse)
   WinGetPos(&x1, &y1, &w1, &h1, "ahk_id " windowundermouse)
   winstate := WinGetminmax("ahk_id " windowundermouse)

   m1 := (x1+w1/2>mon1left) and (x1+w1/2<mon1right) and (y1+h1/2>mon1top) and (y1+h1/2<mon1bottom) ? 1:2  ;works out if centre of window is on monitor 1 (m1=1) or monitor 2 (m1=2)
   m2:=m1=1 ? 2:1  ;m2 is the monitor the window will be moved to
   ratiox:=abs(mon%m1%right-mon%m1%left)-w1<5 ? 0:abs((x1-mon%m1%left)/(abs(mon%m1%right-mon%m1%left)-w1))  ;where the window fits on x axis
   ratioy:=abs(mon%m1%bottom-mon%m1%top)-h1<5 ? 0:abs((y1-mon%m1%top)/(abs(mon%m1%bottom-mon%m1%top)-h1))   ;where the window fits on y axis
   x2:=mon%m2%left+ratiox*(abs(mon%m2%right-mon%m2%left)-w1)   ;where the window will fit on x axis in normal situation
   y2:=mon%m2%top+ratioy*(abs(mon%m2%bottom-mon%m2%top)-h1)
   w2:=w1
   h2:=h1   ;width and height will stay the same when moving unless reason not to lower in script

   if abs(mon%m1%right-mon%m1%left)-w1<5 or abs(mon%m2%right-mon%m2%left-w1)<5   ;if x axis takes up whole axis OR won't fit on new screen
   {
      x2:=mon%m2%left
      w2:=abs(mon%m2%right-mon%m2%left)
   }
   if abs(mon%m1%bottom-mon%m1%top)-h1<5 or abs(mon%m2%bottom-mon%m2%top)-h1<5
   {
      y2:=mon%m2%top
      h2:=abs(mon%m2%bottom-mon%m2%top)
   }
   if winstate   ;move maximized window
   {
      WinRestore("ahk_id " windowundermouse)
      WinMove(mon%m2%left, mon%m2%top, , , "ahk_id " windowundermouse)
      WinMaximize("ahk_id " windowundermouse)
   }
   else
   {
      if (x1<mon%m1%left)
         x2:=mon%m2%left   ;adjustments for windows that are not fully on the initial monitor (m1)
      if (x1+w1>mon%m1%right)
         x2:=mon%m2%right-w2
      if (y1<mon%m1%top)
         y2:=mon%m2%top
      if (y1+h1>mon%m1%bottom)
         y2:=mon%m2%bottom-h2
      WinMove(x2, y2, w2, h2, "ahk_id " windowundermouse)   ;move non-maximized window
   }
   return
}


The_TrayMenu()
{
	global tray := A_TrayMenu
	tray.Delete()

	tray.Add("Preferences" ,NotifyShowMonitors)
   tray.add('Run at startup',RunwithStartup)
   tray.Add()
   tray.add('Open Folder',(*)=>Run(A_ScriptDir))
   tray.SetIcon("Open Folder","shell32.dll",4)
   tray.Add("Intro Video",(*) => Run(script.VideoLink))
	tray.Add("About",(*) => Script.About())
   tray.Add("Exit",(*) => ExitApp())
	; tray.Default := "Show`t" HKToString(MyGui.oldHK)
	; tray.ClickCount := 1

   tray.Default := "Preferences" ;myGui.Show()
	tray.ClickCount := 1

	tray.Add()
	tray.AddStandard()

   global ini := A_ScriptDir "\Config.ini"
   if IniRead(ini,"Run_at_startup" ,'Run',0)
      tray.Check "Run at startup"
   else
      tray.UnCheck "Run at startup"
}

RunwithStartup(*)
{
	if (IniRead(ini,"Run_at_startup" ,'Run',0) = 1)
	{
		tray.UnCheck "Run at startup"
		IniWrite false, ini, 'Run_at_startup', 'Run'
		Script.Autostart(false)
	}	
	else
	{
		tray.Check "Run at startup"
		IniWrite true, ini, 'Run_at_startup', 'Run'
		Script.Autostart(true)
	}
}

NotifyShowMonitors(*)
{
   for tempgui in MultiGui.Guis
      tempgui.Destroy() 
   MultiGui.LastPOs := map()

      myGui.Show()
   Loop MonitorGetCount()
   {
      ; if (MonitorGetCount() > 2)
         Notify.show({HDtext:'Monitor #' a_index ,HDFontSize:52,GenMonitor:a_index,GenLoc:'TL',GenDuration : 0})
   }
   
}


CloseAllNotify(*)
{
   for i, Gui in MultiGui.Guis
      Gui.Destroy()
}


HKToString(hk)
{
	; removed logging due to performance issues
	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'started', 'none')

	if !hk
		return

	temphk := []

	if InStr(hk, '#')
		temphk.Push('Win+')
	if InStr(hk, '^')
		temphk.Push('Ctrl+')
	if InStr(hk, '+')
		temphk.Push('Shift+')
	if InStr(hk, '!')
		temphk.Push('Alt+')

	hk := RegExReplace(hk, '[#^+!]')
	for mod in temphk
		fixedMods .= mod

	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'ended', 'none')
	return (fixedMods ?? '') StrUpper(hk)
}