#SingleInstance
#Requires AutoHotkey v2.0
;Source for V1 Script https://www.dcmembers.com/skrommel/download/dimscreen/
; V1 Script was limited to Default Display in case of multiple monitors

;#include <Notify\NotifyV2>
#include <NotifyV2>
; ^esc:: ; safe Escape plan incase anything goes wrong
; {
; 	exitapp
; }

ToolName := "DimScreen"
Ini := A_ScriptDir "\Settings.ini"
Guis := []
if !FileExist(ini)
{
	Loop MonitorGetCount()
		iniwrite("0%",Ini,"Dimming","Monitor" a_index)
	iniwrite("^#up",Ini,"Dimming","Increase")
	iniwrite("^#Down",Ini,"Dimming","Decrease")
	iniwrite("1",Ini,"Dimming","NotifyTime")
}
IncreaseHotkey  := iniread(Ini,"Dimming","Increase","^#up")
DecreaseHotkey  := iniread(Ini,"Dimming","Decrease","^#Down")
NotifyTime      := iniread(Ini,"Dimming","NotifyTime","3")

Hotkey IncreaseHotkey, Increase, "on"
Hotkey DecreaseHotkey, Decrease, "on"

Notify.Default :=
{
	HDText     :"DimScreen",
	GenBGColor  :"0xFFD23E",
	HDFont     :"Impact",
	HDFontColor:"Black",
	HDFontSize :"20",
	BDFont     :"Consolas",
	BDFontColor:"0x298939",
	BDFontSize :"16",
	GenDuration   :NotifyTime,
}

Loop MonitorGetCount() ; from here we can manage multiple display
{
	MonitorGet A_Index, &L, &T, &R, &B
	;MonitorGetWorkArea(a_index, &Left, &Top, &Right, &Bottom)
	VirtualWidth := SysGet(78)
	VirtualHeight := SysGet(79)
	MyGui := Gui("+ToolWindow -Disabled -SysMenu -Caption +E0x20 +AlwaysOnTop")
	MyGui.BackColor := "000000"
	Dimming := iniread(Ini,"Dimming","Monitor" A_Index,"0%")
	WinSetTransparent(x := CalcDim(Dimming) ,MyGui)
	X := L
	Y := T
	W := abs(L - R)
	H := abs(T - B)
	MyGui.Show("X" X " Y" Y " W" W "H" . H)
	Guis.Push(MyGui)
}

MySettings  := Gui("-MinimizeBox +AlwaysOnTop","Screen Dimming Settings")
MySettings.Add("Text","xm y+m w50","Increase:")
IncreaseWin :=  MySettings.Add("CheckBox", "x+m yp+3 vInWinKey", "Win")
IncreaseHK  := MySettings.Add("Hotkey", "x+5 yp-3 w90 vINHotkey")

MySettings.Add("Text","xm y+m w50","Decrease:   ")
DecreaseWin := MySettings.Add("CheckBox", "x+m yp+3 vDeWinKey", "Win")
DecreaseHK  := MySettings.Add("Hotkey"  , "x+5 yp-3 w90 vDeHotkey")

MySettings.Add("Text","xm y+m","Notify Time:")
MyNotifyTime := MySettings.Add("Edit","x+5 vDelayTime")
MySettings.Add("UpDown","Range1-10")

MySettings.Add("Button","y+m w40 Default","OK").OnEvent("click",SaveChanges)

MySettings.onEvent("Close",ReEnableHotkey)

IncreaseHK.value  := StrReplace(IncreaseHotkey,"#",,,&IwinCount)
DecreaseHK.value  := StrReplace(DecreaseHotkey,"#",,,&DwinCount)
IncreaseWin.Value := IwinCount
DecreaseWin.value := DwinCount

MyNotifyTime.value  := NotifyTime

Starting := Notify.show({
	BDText:"Press " IncreaseHotkey " to Increase Brightness`n"
	    . "Press " DecreaseHotkey " to Decrease Brightness",
	GenCallback:Settingup
})

SetTimer((*) => Starting.notice.Close(), -1000)
A_TrayMenu.delete()
; A_TrayMenu.Add()  ; Creates a separator line.
; Loop 10
;     A_TrayMenu.Add( A_Index*10-10 "%" , MenuHandler,"+Radio")
;     ;Menu,Tray,Add,% "&" A_Index*10-10 "%",CHANGE
; A_TrayMenu.Check(Dimming)
A_TrayMenu.Add(MySettings.lastuphk := "Brightness: " IncreaseHotkey,(*) => 0)
A_TrayMenu.Add(MySettings.LastDownhk := "Darkness:   " DecreaseHotkey,(*) => 0)
A_TrayMenu.Add()
A_TrayMenu.Add( "Settings", Settingup)
A_TrayMenu.default := "Settings"
A_TrayMenu.Add( "Exit", (*) => Exitapp())

return


Settingup(*)
{
	try Notify.DestroyLastGui()
	MySettings.Show()
	; MySettings.GetPos(&W, &H)
	; tooltip w "`n" h
	Disablehotkey()
}

SaveChanges(*)
{
	;Global IncreaseHotkey, DecreaseHotkey
	Settings := MySettings.Submit()
	IncreaseHotkey  := (Settings.InWinkey ? "#" : "") Settings.InHotkey
	DecreaseHotkey  := (Settings.DeWinkey ? "#" : "") Settings.DeHotkey
	iniwrite(IncreaseHotkey,Ini,"Dimming","Increase")
	iniwrite(DecreaseHotkey,Ini,"Dimming","Decrease")
	iniwrite(Settings.DelayTime,Ini,"Dimming","NotifyTime")
	Hotkey IncreaseHotkey, Increase, "on"
	Hotkey DecreaseHotkey, Decrease, "on"
	
	A_TrayMenu.Rename(MySettings.lastuphk   , MySettings.lastuphk   := HKToString(IncreaseHotkey))
	A_TrayMenu.Rename(MySettings.LastDownhk , MySettings.LastDownhk := HKToString(DecreaseHotkey))
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

Disablehotkey(*)
{
	IncreaseHotkey := iniread(Ini,"Dimming","Increase")
	DecreaseHotkey := iniread(Ini,"Dimming","Decrease")
	Hotkey IncreaseHotkey, Increase, "off"
	Hotkey DecreaseHotkey, Decrease, "off"
}

ReEnableHotkey(*)
{
	IncreaseHotkey := iniread(Ini,"Dimming","Increase")
	DecreaseHotkey := iniread(Ini,"Dimming","Decrease")
	Hotkey IncreaseHotkey, Increase, "on"
	Hotkey DecreaseHotkey, Decrease, "on"
}

; MenuHandler(ItemName, ItemPos, MyMenu)
; {
;     global Dimming
;     if InStr(ItemName,"%")
;     {
;         A_TrayMenu.Uncheck(Dimming)
;         A_TrayMenu.Check(Dimming := ItemName)    
;         WinSetTransparent(CalcDim(Dimming) ,MyGui)
;     }
; }

CalcDim(MenuName, Step := 0)
{
	x := StrReplace(MenuName,"%") + Step
	return round(255*x/100 ,0)
}

Decrease(*)
{
	global Guis
	n := getCurrentDisplayNumberByMouse()
	; Notify.CloseLast() ; deleting previous Notification as we do not want staking here
	Dimming := iniread(Ini,"Dimming","Monitor" n,"0%")
	;A_TrayMenu.Uncheck(Dimming)
	if Dimming != "90%"
	{
		WinSetTransparent(x := CalcDim(Dimming, 10),Guis[n])
		iniwrite(round(x*100/255,0) "%",Ini,"Dimming","Monitor" n)
	}

    ; looping through all the Gui matching if anyone has word volume in it then change volume in there
    for i, Gui in MultiGui.Guis
    {
        try ctrlText := Gui['text'].value
        catch 
            ctrlText := 0
		OutputDebug ctrlText
        if InStr(ctrlText,"Brighness:")
        {
			if Dimming = "90%"
				Gui['text'].value := "Brighness: 0%`nAlready"
			else
				Gui['text'].value := "Brighness: " round(100 - (x*100/255),0) "%" ; changing the text of the Gui
            return sleep(300)
        }
    }

	if Dimming = "90%"
	{
		Notify.show({
			HDText    :"Display : " n,
			BDText    :"Brighness: 0%`nAlready",
			GenMonitor: n
		})
		return
	}
	;A_TrayMenu.Check(Dimming := round(x*100/255,0) "%")
	Notify.show({
		HDText     :"Display : " n,
		BDText     :"Brighness: " round(100 - (x*100/255),0) "%",
		GenMonitor : n
	})
}

Increase(*)
{
	global Guis
	;Notify.CloseLast() ; deleting previous Notification as we do not want staking here
	n := getCurrentDisplayNumberByMouse()
	Dimming := iniread(Ini,"Dimming","Monitor" n,"0%")
	;A_TrayMenu.Uncheck(Dimming)
	n := getCurrentDisplayNumberByMouse()
	if Dimming != "0%"	
	{
		WinSetTransparent(x := CalcDim(Dimming, -10),Guis[n])
		iniwrite(round(x*100/255,0) "%",Ini,"Dimming","Monitor" n)
	}

	; looping through all the Gui matching if anyone has word volume in it then change volume in there
	for i, Gui in MultiGui.Guis
	{
		try ctrlText := Gui['text'].value
		catch 
			ctrlText := 0
		OutputDebug ctrlText
		if InStr(ctrlText,"Brighness:")
		{
			if Dimming = "0%"
				Gui['text'].value := "Brighness: 100%`nAlready"
			else
				Gui['text'].value := "Brighness: " round(100 - (x*100/255),0) "%" ; changing the text of the Gui
			return sleep(300)
		}
	}

	if Dimming = "0%"
	{
		Notify.show({
			HDText     :"Display : " n,
			BDText     :"Brighness: 100%`nAlready",
			GenMonitor : n
		})
		return
	}
	Notify.show({
		HDText     :"Display : " n,
		BDText     :"Brighness: " round(100 - (x*100/255),0) "%",
		GenMonitor : n
	})
	;A_TrayMenu.Check(Dimming := round(x*100/255,0) "%")
}


getCurrentDisplayNumberByMouse()
{
	CoordMode("Mouse","Screen")
	MouseGetPos(&mx,&my)
	Loop MonitorGetCount()
	{
		MonitorGet(a_index, &Left, &Top, &Right, &Bottom)
		if (Left <= mx && mx <= Right && Top <= my && my <= Bottom)
			Return A_Index
	}
	Return 1
}

; GetMonitorHW()
; {
;     WMI := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\wmi")
;     For Monitor in  WMI.ExecQuery("Select * from WmiMonitorID")
;     {
;         msgbox Monitor.resolution
;     }
; }