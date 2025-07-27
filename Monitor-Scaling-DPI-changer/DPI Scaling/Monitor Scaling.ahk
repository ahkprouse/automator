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
tray.add( "Open Gui", GuiReSHow)
tray.default := "Open Gui"
tray.add()
tray.AddStandard()

Prefix := "Ctrl"
MonitorsIni := A_ScriptDir "\DisplayScale.ini"
;DPI_ENUM, LV
Displays := []
DisplayPath := Map()
Displays.Push("\\.\ActiveDisplay")
DisplayPath["\\.\ActiveDisplay"] := "null"
for k, dsp in GetEnumDisplays()
{
	Displays.Push(dsp.Name)
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

ToolName := "Display Scalings"

MyGui := Gui("+ToolWindow",ToolName)
MyGui.OnEvent('Close', ProceedSetting)
MyGui.OnEvent('Escape', ProceedSetting)

MyGui.Add("CheckBox", "xm ym+3 w55 vWinKey", "Win")
myPrefix := MyGui.Add("Hotkey", "x+m ym w100 vHotkey")


MyGui.Add("Text", "xp+164 Section w60", "Monitor ID:")
MyDDL := MyGui.Add("DropDownList"," yp w155 vDisplay  Choose1", Displays)

MyDDL.ToolTip := "Choose a Display from the drop-down list."

MyGui.Add("Button", "xm+65", "Add Configuration").OnEvent("Click", AddHotkey)

MyGui.Add("Text", "x+m xs w60", "Scale:")
MyScale := MyGui.Add("DropDownList","yp vScale Choose1", DPI)

;MyDDL.OnEvent("Change",onSelectDisplay)
;MyScale.OnEvent("Change",onSelectDisplay)


LV := MyGui.Add("ListView", "xm h200 w450",["Display","DPI Scale","Hotkey"])
LV.OnEvent("Click", LVEvent)
DeleteBtn := MyGui.Add("Button", "xm+350 Disabled", "Delete")
DeleteBtn.OnEvent("Click", DeletLVRow)
MyButton := MyGui.Add("Button","yp w55 default","Save").OnEvent("Click", ProceedSetting)

if FileExist(MonitorsIni)
{
	for i, HotkeyDpiDisplay in StrSplit(IniRead(MonitorsIni,"ScaleHotkeys",,""),"`n")
	{
		RegExMatch(HotkeyDpiDisplay,"(.*)=(.*)",&HDD) ; HDD = 'H'otkey'D'pi'D'isplay
		RegExMatch(HDD[2],"(.*)\|(.*)",&DPIDisplay)
		if DisplayPath.has(DPIDisplay[2]) ; adding only available displays to listview
			LV.Add(,DPIDisplay[2],DPIDisplay[1],HDD[1])
		try Hotkey HDD[1], "ON"
	}
}
loop LV.GetCount("Column")
	LV.ModifyCol(a_index,"autoHdr")
MyGui.Show()
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



CloseThis(*)
{
	;Exitapp
	mygui.Hide()
}

AddHotkey(obj,info)
{
	Saved := MyGui.Submit(false)
	hotkey := (Saved.Winkey ? "#" : "") Saved.Hotkey
	NewEntry := hotkey "|" MonitorsIni,Saved.Display "|" Saved.Scale
	Rows := LV.GetCount()
	Loop Rows
	{
		if Saved.Hotkey = "None" or Saved.Hotkey = ""
		{
			msgbox "Hotkey is required..!"
			return
		}

		existingEntry := LV.GetText(a_index,3) "|" MonitorsIni,LV.GetText(a_index,1) "|" LV.GetText(a_index,2)

		if existingEntry = NewEntry
		{
			Msgbox "Hotkey: '" hotkey "' for Display: '" Saved.Display "' and Scale: '" Saved.Scale "' exists already"
			return
		}

		if hotkey = LV.GetText(a_index,3)
		{
			msgbox "Hotkey: '" hotkey "' has already asigned`nPlease delete existing entry"
			return
		}
	}

	LV.Add(,Saved.Display, Saved.Scale,hotkey)
	LV.ModifyCol
}

ProceedSetting(*)
{
	if FileExist(MonitorsIni)
		FileDelete(MonitorsIni)
	Rows := LV.GetCount()
	Loop Rows
	{
		IniWrite(LV.GetText(a_index,2) "|" LV.GetText(a_index,1), MonitorsIni,"ScaleHotkeys", LV.GetText(a_index,3) )
		Hotkey LV.GetText(a_index,3), (ThisHotkey) => SetScaleFactor(ThisHotkey), "ON"
	}
	MyGui.Hide()
}

SetScaleFactor(ThisHkey)
{
	CoordMode "Mouse", "Screen"
	MouseGetPos &x, &y
	DpiDisplay := IniRead(MonitorsIni,"ScaleHotkeys",ThisHkey)
	RegExMatch(DpiDisplay,"(.*)\|(.*)",&DD)
	if DD[2] = "\\.\ActiveDisplay"
	{
		setDPI(getCurrentDisplayPathByMouse(), DPI_ENUM[DD[1]])
		MouseMove x, y
		return 
	}
	;DisplayPath := GetDisplayPath(regexreplace(DD[2],"\d+:\s"))
	setDPI(DisplayPath[DD[2]], DPI_ENUM[DD[1]])
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
	DisplayArray := EnumDisplayDevices()
	for Display in DisplayArray
		Displays.Push({Name:'Monitor ' A_Index, Path:Display["DeviceID"]})

	return Displays
}


EnumDisplayDevices(dwFlags:=1)    {
	Static   EDD_GET_DEVICE_INTERFACE_NAME := 0x00000001
	         ,byteCount              := 4+4+((32+128+128+128)*2)
	         ,offset_cb              := 0
	         ,offset_DeviceName      := 4                            ,length_DeviceName      := 32
	         ,offset_DeviceString    := 4+(32*2)                     ,length_DeviceString    := 128
	         ,offset_StateFlags      := 4+((32+128)*2)
	         ,offset_DeviceID        := 4+4+((32+128)*2)             ,length_DeviceID        := 128
	         ,offset_DeviceKey       := 4+4+((32+128+128)*2)         ,length_DeviceKey       := 128

	DISPLAY_DEVICEA:=""
	if (dwFlags!=0 && dwFlags!=EDD_GET_DEVICE_INTERFACE_NAME)
		return false
	lpDisplayDevice:=Buffer(byteCount,0)            ,Numput("UInt",byteCount,lpDisplayDevice,offset_cb)

	displayArray := []
	loop MonitorGetCount()
	{
		mon_index := RegExReplace(MonitorGetName(A_Index), '\D')
		if !DllCall("EnumDisplayDevices", "Ptr",0, "UInt", mon_index - 1, "Ptr",lpDisplayDevice.Ptr, "UInt",0)
			return false
		if (dwFlags==EDD_GET_DEVICE_INTERFACE_NAME)    {
			DeviceName:=StrGet(lpDisplayDevice.Ptr+offset_DeviceName, length_DeviceName)
			lpDisplayDevice.__New(byteCount,0)          ,Numput("UInt",byteCount,lpDisplayDevice,offset_cb)
			lpDevice:=Buffer(length_DeviceName*2,0)     ,StrPut(DeviceName, lpDevice,length_DeviceName)
			DllCall("EnumDisplayDevices", "Ptr",lpDevice.Ptr, "UInt",0, "Ptr",lpDisplayDevice.Ptr, "UInt",dwFlags)
		}
		For property in (DISPLAY_DEVICEA:=Map("cb",0,"DeviceName","","DeviceString","","StateFlags",0,"DeviceID","","DeviceKey",""))    {
			Switch property
			{
				case "cb","StateFlags":                 DISPLAY_DEVICEA[property]:=NumGet(lpDisplayDevice, offset_%property%,"UInt")
				default:                                DISPLAY_DEVICEA[property]:=StrGet(lpDisplayDevice.Ptr+offset_%property%, length_%property%)
			}
		}

		displayArray.Push(DISPLAY_DEVICEA)
	}
	return displayArray
}