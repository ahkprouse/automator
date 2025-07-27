#SingleInstance
#Requires Autohotkey v2.0-
;--
;@Ahk2Exe-SetVersion     0.1.0
; @Ahk2Exe-SetMainIcon    res\main.ico
; @Ahk2Exe-SetProductName
; @Ahk2Exe-SetDescription
/**
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Learn          *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */
tray := A_TrayMenu
tray.delete()
tray.add("Open Gui", GuiReSHow)
tray.default := "Open Gui"
tray.add()
tray.AddStandard()

Persistent
TraySetIcon A_WinDir '\system32\shell32.dll', 23

Prefix := "Ctrl"
MonitorsIni := A_ScriptDir "\ActiveDisplayScale.ini"

;DPI_ENUM, LV
;Displays := GetMonitors()

Displays := []
DisplayPath := Map()
for k, dsp in GetEnumDisplays()
{
	DisplayPath[dsp.Name] := dsp.Path
}

DPI := ["dpi_recommended","dpi_100","dpi_125","dpi_150","dpi_175"]
DPI_ENUM := map(
"dpi_recommended",-1,
"dpi_100",0,
"dpi_125",1,
"dpi_150",2,
"dpi_175",3,
"dpi_200",4,
"dpi_225",5,
"dpi_250",6,
"dpi_300",7,
"dpi_350",8,
"dpi_400",9,
"dpi_450",10,
"dpi_500",11
)

ToolName := "Active Display Scalings"
FirstRun := 1
MyGui := Gui("",ToolName)
MyGui.OnEvent('Close', ProceedSetting)
MyGui.OnEvent('Escape', ProceedSetting)

MyGui.Add("CheckBox", "xm y8 vWinKey", "Win")
myPrefix := MyGui.Add("Hotkey", "x+5 y5 w60 vHotkey")

MyGui.Add("Text", "x+m yp+3", "Scale:")
MyScale := MyGui.Add("DropDownList","y5 vScale Choose1", DPI)

LV := MyGui.Add("ListView", "xm h100 w300",["Hotkey","DPI Scale"])
LV.OnEvent("Click", LVEvent)
DeleteBtn := MyGui.Add("Button", "xm+90 Disabled", "Delete")
DeleteBtn.OnEvent("Click", DeletLVRow)
MyGui.Add("Button", "yp", "Add Configuration").OnEvent("Click", AddHotkey)
MyButton := MyGui.Add("Button","yp w55 default","Save").OnEvent("Click",ProceedSetting)

if FileExist(MonitorsIni)
{
	for i, HotkeyDpi in StrSplit(IniRead(MonitorsIni,"ScaleHotkeys",,""),"`n")
	{
		RegExMatch(HotkeyDpi,"(.*)=(.*)",&HD) ; HDD = 'H'otkey'D'pi'D'isplay
		LV.Add(,HD[1],HD[2])
		try Hotkey HD[1], "ON"
	}
}
else
	FirstRun := 0

loop LV.GetCount("Column")
	LV.ModifyCol(a_index,"autoHdr")

if FirstRun
	ProceedSetting()
return

LVEvent(GuiCtrlObj, Info)
{
	Saved := MyGui.Submit(false)
	if LV.GetCount("s") > 0
		Deletebtn.Enabled := true
	else
		Deletebtn.Enabled := false
}

DeletLVRow(*)
{
	rownumber := 0
	rownumber := LV.GetNext(rownumber)
	LV.Delete(rownumber)
	CountNumber := LV.GetCount()
	if( CountNumber = 0)
	{
		Deletebtn.Enabled := false
		return
	}
	else if( CountNumber < rownumber)
		rownumber := CountNumber
	else if rownumber = 0
		rownumber := 1
	LV.Modify(rownumber, "Select")
}

GuiReShow(*)
{
	if FileExist(MonitorsIni)
	{
		; disabling hotkey before showing
		for i, HotkeyDpiDisplay in StrSplit(IniRead(MonitorsIni,"ScaleHotkeys",,""),"`n")
		{
			RegExMatch(HotkeyDpiDisplay,"(.*)=(.*)",&HDD) ; HDD = 'H'otkey'D'pi'D'isplay
			RegExMatch(HDD[2],"(.*)\|(.*)",&DPIDisplay)
			try Hotkey HDD[1], "off"
		}
	}
	loop LV.GetCount("Column")
		LV.ModifyCol(a_index,"autoHdr")
	MyGui.Show()
}

; CloseThis(*)
; {
; 	;Exitapp
; 	for i, HotkeyDpiDisplay in StrSplit(IniRead(MonitorsIni,"ScaleHotkeys",,""),"`n")
; 	{
; 		RegExMatch(HotkeyDpiDisplay,"(.*)=(.*)",&HDD) ; HDD = 'H'otkey'D'pi'D'isplay
; 		RegExMatch(HDD[2],"(.*)\|(.*)",&DPIDisplay)
; 		try Hotkey HDD[1], "ON"
; 	}
; 	mygui.Hide()
; }

AddHotkey(obj,info)
{
	Saved := MyGui.Submit(false)
	hotkey := (Saved.Winkey ? "#" : "") Saved.Hotkey
	Rows := LV.GetCount()
	Loop Rows
	{
		if Saved.Hotkey = "None" or Saved.Hotkey = ""
		{
			msgbox "Hotkey is required..!"
			return
		}

		if  LV.GetText(a_index,2) = Saved.Scale
		{
			Msgbox "Hotkey for Scale: '" Saved.Scale "' exists already"
			return
		}

		if hotkey = LV.GetText(a_index,1)
		{
			msgbox "Hotkey: '" hotkey "' has already asigned"
			return
		}
	}

	LV.Add(,hotkey, Saved.Scale)
	LV.ModifyCol
}

ProceedSetting(*)
{
	if FileExist(MonitorsIni)
		FileDelete(MonitorsIni)
	Rows := LV.GetCount()
	Loop Rows
	{
		IniWrite(LV.GetText(a_index,2), MonitorsIni,"ScaleHotkeys", LV.GetText(a_index,1) )
		Hotkey key:=LV.GetText(a_index,1), (ThisHotkey) => SetScaleFactor(ThisHotkey), 'ON'
	}
	MyGui.Hide()
}

SetScaleFactor(ThisHkey)
{
	CoordMode "Mouse", "Screen"
	MouseGetPos &x, &y
	DpiDisplay := IniRead(MonitorsIni,"ScaleHotkeys",ThisHkey)
	setDPI(getCurrentDisplayPathByMouse(), DPI_ENUM[DpiDisplay])
	MouseMove x, y
}

getCurrentDisplayPathByMouse()
{
	CoordMode("Mouse","Screen")
	MouseGetPos(&mx,&my)
	Loop MonitorGetCount()
	{
		MonitorGet(a_index, &Left, &Top, &Right, &Bottom)
		if (Left <= mx && mx <= Right && Top <= my && my <= Bottom)
			Return DisplayPath[MonitorGetName(a_index)]
	}
	Return 1
}

; by FuPeiJiang
setDPI(monitorDevicePath, dpi_enum_value) {
	static QDC_ONLY_ACTIVE_PATHS := 0x00000002

	DllCall("GetDisplayConfigBufferSizes", "Uint", QDC_ONLY_ACTIVE_PATHS, "Uint*",&pathsCount:=0, "Uint*",&modesCount:=0)
	DISPLAYCONFIG_PATH_INFO_arr:=Buffer(72*pathsCount)
	DISPLAYCONFIG_MODE_INFO_arr:=Buffer(64*modesCount)
	DllCall("QueryDisplayConfig",
			"Uint" , QDC_ONLY_ACTIVE_PATHS,
			"Uint*", &pathsCount,
			"Ptr"  , DISPLAYCONFIG_PATH_INFO_arr,
			"Uint*", &modesCount,
			"Ptr"  , DISPLAYCONFIG_MODE_INFO_arr,
			"Ptr"  ,0)

	i_:=0
	end:=DISPLAYCONFIG_PATH_INFO_arr.Size
	DISPLAYCONFIG_TARGET_DEVICE_NAME:=Buffer(420)
	NumPut("Int",2,DISPLAYCONFIG_TARGET_DEVICE_NAME,0) ;2=DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME
	NumPut("Uint",DISPLAYCONFIG_TARGET_DEVICE_NAME.Size,DISPLAYCONFIG_TARGET_DEVICE_NAME,4)
	while (i_ < end) {
		adapterID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+0, "Uint64")
		sourceID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+8, "Uint")
		targetID:=NumGet(DISPLAYCONFIG_PATH_INFO_arr, i_+28, "Uint")

		NumPut("Uint64",adapterID,DISPLAYCONFIG_TARGET_DEVICE_NAME,8)
		NumPut("Uint",targetID,DISPLAYCONFIG_TARGET_DEVICE_NAME,16)
		DllCall("DisplayConfigGetDeviceInfo", "Ptr",DISPLAYCONFIG_TARGET_DEVICE_NAME)
		temp_monitorDevicePath:=StrGet(DISPLAYCONFIG_TARGET_DEVICE_NAME.Ptr + 164, "UTF-16")

		if (temp_monitorDevicePath==monitorDevicePath) {

			DISPLAYCONFIG_SOURCE_DPI_SCALE_GET:=Buffer(32)
			NumPut("Int",-3,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,0) ;-3=DISPLAYCONFIG_DEVICE_INFO_GET_DPI_SCALE
			NumPut("Uint",DISPLAYCONFIG_SOURCE_DPI_SCALE_GET.Size,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,4)
			NumPut("Uint64",adapterID,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,8)
			NumPut("Uint",sourceID,DISPLAYCONFIG_SOURCE_DPI_SCALE_GET,16)
			DllCall("DisplayConfigGetDeviceInfo", "Ptr",DISPLAYCONFIG_SOURCE_DPI_SCALE_GET)
			minScaleRel:=NumGet(DISPLAYCONFIG_SOURCE_DPI_SCALE_GET, 20, "Int")
			recommendedDpi:=Abs(minScaleRel)
			dpiRelativeVal:=0
			if (dpi_enum_value!==-1) {
				dpiRelativeVal:=dpi_enum_value - recommendedDpi
			}


			DISPLAYCONFIG_SOURCE_DPI_SCALE_SET:=Buffer(24)
			NumPut("Int",-4,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,0) ;-4=DISPLAYCONFIG_DEVICE_INFO_SET_DPI_SCALE
			NumPut("Uint",DISPLAYCONFIG_SOURCE_DPI_SCALE_SET.Size,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,4)
			NumPut("Uint64",adapterID,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,8)
			NumPut("Uint",sourceID,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,16)
			NumPut("Int",dpiRelativeVal,DISPLAYCONFIG_SOURCE_DPI_SCALE_SET,20)
			DllCall("DisplayConfigSetDeviceInfo", "Ptr",DISPLAYCONFIG_SOURCE_DPI_SCALE_SET)

			break
		}


		i_+=72
	}
}

GetEnumDisplays()
{
	Displays := []
	Loop MonitorGetCount()
	{
		Name := MonitorGetName(a_index)
		Display := EnumDisplayDevices(a_index, 1)
		if InStr(Display["DeviceName"],Name)
			Displays.Push({Name:Name,Path:Display["DeviceID"]})

	}
	return Displays
}


EnumDisplayDevices(iDevNum, dwFlags:=0)    {
	Static   EDD_GET_DEVICE_INTERFACE_NAME := 0x00000001
			,byteCount              := 4+4+((32+128+128+128)*2)
			,offset_cb              := 0
			,offset_DeviceName      := 4                            ,length_DeviceName      := 32
			,offset_DeviceString    := 4+(32*2)                     ,length_DeviceString    := 128
			,offset_StateFlags      := 4+((32+128)*2)
			,offset_DeviceID        := 4+4+((32+128)*2)             ,length_DeviceID        := 128
			,offset_DeviceKey       := 4+4+((32+128+128)*2)         ,length_DeviceKey       := 128

	DISPLAY_DEVICEA:=""
	if (iDevNum~="\D" || (dwFlags!=0 && dwFlags!=EDD_GET_DEVICE_INTERFACE_NAME))
		return false
	lpDisplayDevice:=Buffer(byteCount,0)            ,Numput("UInt",byteCount,lpDisplayDevice,offset_cb)
	if !DllCall("EnumDisplayDevices", "Ptr",0, "UInt",iDevNum, "Ptr",lpDisplayDevice.Ptr, "UInt",0)
		return false
	if (dwFlags==EDD_GET_DEVICE_INTERFACE_NAME)    {
		DeviceName:=MonitorGetName(iDevNum)
		lpDisplayDevice.__New(byteCount,0)          ,Numput("UInt",byteCount,lpDisplayDevice,offset_cb)
		lpDevice:=Buffer(length_DeviceName*2,0)     ,StrPut(DeviceName, lpDevice,length_DeviceName)
		DllCall("EnumDisplayDevices", "Ptr",lpDevice.Ptr, "UInt",0, "Ptr",lpDisplayDevice.Ptr, "UInt",dwFlags)
	}

	DISPLAY_DEVICEA:=Map("cb",0,"DeviceName","","DeviceString","","StateFlags",0,"DeviceID","","DeviceKey","")
	For k in DISPLAY_DEVICEA {
		Switch k
		{
			case "cb","StateFlags": DISPLAY_DEVICEA[k]:=NumGet(lpDisplayDevice, offset_%k%,"UInt")
			default:                DISPLAY_DEVICEA[k]:=StrGet(lpDisplayDevice.Ptr+offset_%k%, length_%k%)
		}
	}
	return DISPLAY_DEVICEA
}