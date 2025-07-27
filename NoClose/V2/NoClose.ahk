#Requires AutoHotkey v2.0
; Disable the Close button (X) of selected windows
; Specify Rules for selected windows
; Source = https://www.dcmembers.com/skrommel/download/noclose/

Ini := A_ScriptDir "/Settings.ini"
if !FileExist(Ini)
	FileAppend "", Ini

DisableCHotkey      := IniRead(ini,"Hotkeys","Disable","^1")
EnableCHotkey       := IniRead(ini,"Hotkeys","Enable","^+1")
AutoDisableHotkey   := IniRead(ini,"Hotkeys","AutoDisable","!1")
ExEnableHotkey      := IniRead(ini,"Hotkeys","Exclusions","!+1")

A_TrayMenu.delete()
A_TrayMenu.Add("Disable Close: " DisableCHotkey,(*) => 0)
A_TrayMenu.Add("Enable Close : " EnableCHotkey,(*) => 0)

A_TrayMenu.Add("Auto Disable : " AutoDisableHotkey,(*) => 0)
A_TrayMenu.Add("Add Exclusion: " ExEnableHotkey,(*) => 0)

A_TrayMenu.Add()
A_TrayMenu.Add( "Settings", NoCLoseSettings)
A_TrayMenu.default := "Settings"
A_TrayMenu.Add( "Exit", (*) => Exitapp())

MySettings  := Gui("-MinimizeBox +AlwaysOnTop","Screen Dimming Settings")
MyTab := MySettings.Add("Tab3",, ["General","AutoDisable List","Exclusions List"])
MyTab.UseTab(1)
MySettings.Add("Text","xs+10 y+m w90","Disable Close:")
DisableWin :=  MySettings.Add("CheckBox", "x+m yp+3 vDeWinKey", "Win")
DisableHK  := MySettings.Add("Hotkey", "x+5 yp-3 w90 vDeHotkey")

MySettings.Add("Text","xs+10 y+m w90","Enable Close:")
EnableWin := MySettings.Add("CheckBox", "x+m yp+3 vEnWinKey", "Win")
EnableHK  := MySettings.Add("Hotkey"  , "x+5 yp-3 w90 vEnHotkey")

MySettings.Add("Text","xs+10 y+m w90","AutoDisable:")
AutoDisableWin :=  MySettings.Add("CheckBox", "x+m yp+3 vDeAutoWinKey", "Win")
AutoDisableHK  := MySettings.Add("Hotkey", "x+5 yp-3 w90 vDeAutoHotkey")

MySettings.Add("Text","xs+10 y+m w90","Exclusions:")
ExcludeEnableWin := MySettings.Add("CheckBox", "x+m yp+3 vEnEXWinKey", "Win")
ExcludeEnableHK  := MySettings.Add("Hotkey"  , "x+5 yp-3 w90 vEnExHotkey")

;MySettings.Add("Button","y+m w40 Default","OK").OnEvent("click",SaveChanges)
;MySettings.Add("Button","x+m w40 ","Cancel").onEvent("click",toReEnableHotkey)

MyTab.UseTab(2)
AutoLv      := MySettings.Add("ListView", "h200 w400" , ["Title","Class"])
AutoLv.OnEvent("ItemSelect", onAutoLVSelect)
MySettings.Add("Button","y+m w40 ","Add") ;.OnEvent("AddAuto",)
AutoLVDelBtn := MySettings.Add("Button","x+m w40 +Disabled","Delete") ;.OnEvent("DelAuto",)
AutoLVDelBtn.OnEvent("click",AutoLVDeleteRows)
;MySettings.Add("Button","x+m w40 Default","OK").OnEvent("click",SaveChanges)
;MySettings.Add("Button","x+m w40 Default","Cancel").onEvent("click",toReEnableHotkey)

MyTab.UseTab(3)
ExcludeLV   := MySettings.Add("ListView", "h200 w400" , ["Title","Class"])
ExcludeLV.OnEvent("ItemSelect", onExcludeLVSelect)
MySettings.Add("Button","y+m w40 ","Add") ;.OnEvent("AddExclude",)
AutoExcludeDelBtn := MySettings.Add("Button","x+m w40 +Disabled","Delete") ;.OnEvent("DelExclude",)
AutoExcludeDelBtn.OnEvent("click",ExcludeLVDeleteRows)
MyTab.UseTab(0)
MySettings.Add("Button","y+m w40 Default","OK").OnEvent("click",SaveChanges)
MySettings.Add("Button","x+m w40 ","Cancel").onEvent("click",toReEnableHotkey)

MySettings.onEvent("Close",ReEnableHotkey)

for titleclasses in StrSplit(IniRead(Ini,"AutoDisable",,""),"`n")
{
	if titleclasses
	{
		TC := StrSplit(titleclasses,"=")
		AutoLv.Add(,TC[1],TC[2])
	}
}

for titleclasses in StrSplit(IniRead(Ini,"AutoExclude",,""),"`n")
{
	if titleclasses
	{
		TC := StrSplit(titleclasses,"=")
		ExcludeLV.Add(,TC[1],TC[2])
	}
}
AutoLv.ModifyCol()
ExcludeLV.ModifyCol()
if InStr(DisableCHotkey,"#")
{
	DisableCHotkey := StrReplace(DisableCHotkey,"#")
	DisableWin.Value := 1
}

if InStr(EnableCHotkey,"#")
{
	EnableCHotkey := StrReplace(EnableCHotkey,"#")
	EnableWin.value := 1
}

if InStr(AutoDisableHotkey,"#")
{
	AutoDisableHotkey := StrReplace(AutoDisableHotkey,"#")
	AutoDisableWin.Value := 1
}

if InStr(ExEnableHotkey,"#")
{
	ExEnableHotkey := StrReplace(ExEnableHotkey,"#")
	ExcludeEnableWin.value := 1
}

DisableHK.value := DisableCHotkey
EnableHK.value  := EnableCHotkey
AutoDisableHK.value := AutoDisableHotkey
ExcludeEnableHK.value  := ExEnableHotkey
Hotkey DisableCHotkey, Add, "on" 
Hotkey EnableCHotkey, Swap, "on"
Hotkey AutoDisableHotkey, DisableNAdd2Autolist, "on" 
Hotkey ExEnableHotkey, EnablenAdd2Excludelist, "on"
SetTimer ApplySettings, 250

onAutoLVSelect(GuiCtrlObj, Item, Selected)
{
	AutoLVDelBtn.enabled := GuiCtrlObj.GetNext() ? true : false
}

onExcludeLVSelect(GuiCtrlObj, Item, Selected)
{
	AutoExcludeDelBtn.enabled := GuiCtrlObj.GetNext() ? true : false
}

AutoLVDeleteRows(*)
{
	RowNumber := 0
	Loop
	{
		RowNumber := AutoLV.GetNext(RowNumber)
		if not RowNumber
			break
		Title := AutoLV.GetText(RowNumber)
		AutoLV.Delete(RowNumber)
		IniDelete Ini, "AutoDisable", Title
	}
}

ExcludeLVDeleteRows(*)
{
	RowNumber := 0
	Loop
	{
		RowNumber := ExcludeLV.GetNext(RowNumber)
		if not RowNumber
			break
		Title := ExcludeLV.GetText(RowNumber)
		ExcludeLV.Delete(RowNumber)
		IniDelete Ini, "AutoExclude", Title
	}
}

NoCLoseSettings(*)
{
	MySettings.Show()
	Disablehotkey()
}

Disablehotkey()
{
	DisableCHotkey      := IniRead(ini,"Hotkeys","Disable","^1")
	EnableCHotkey       := IniRead(ini,"Hotkeys","Enable","^+1")
	AutoDisableHotkey   := IniRead(ini,"Hotkeys","AutoDisable","!1")
	ExEnableHotkey      := IniRead(ini,"Hotkeys","Exclusions","!+1")

	Hotkey DisableCHotkey, Add, "off" 
	Hotkey EnableCHotkey, Swap, "off"
	Hotkey AutoDisableHotkey, DisableNAdd2Autolist, "off" 
	Hotkey ExEnableHotkey, EnablenAdd2Excludelist, "off"
	SetTimer ApplySettings, 0
}
toReEnableHotkey(*)
{
	MySettings.Submit()
	ReEnableHotkey()    
}

ReEnableHotkey(*)
{
	DisableCHotkey := iniread(Ini,"Hotkeys","Disable")
	EnableCHotkey := iniread(Ini,"Hotkeys","Enable")
	AutoDisableHotkey := iniread(Ini,"Hotkeys","AutoDisable")
	ExEnableHotkey := iniread(Ini,"Hotkeys","Exclusions")

	Hotkey DisableCHotkey, Add, "on" 
	Hotkey EnableCHotkey, Swap, "on"
	Hotkey AutoDisableHotkey, DisableNAdd2Autolist, "on" 
	Hotkey ExEnableHotkey, EnablenAdd2Excludelist, "on"
	SetTimer ApplySettings, 250
}

SaveChanges(*)
{

	Settings := MySettings.Submit()
	DisableCHotkey  := (Settings.DeWinkey ? "#" : "") Settings.DeHotkey
	EnableCHotkey  := (Settings.EnWinkey ? "#" : "") Settings.EnHotkey
	AutoDisableHotkey  := (Settings.DeAutoWinKey ? "#" : "") Settings.DeAutoHotkey
	ExEnableHotkey  := (Settings.EnEXWinKey ? "#" : "") Settings.EnExHotkey

	iniwrite(DisableCHotkey,Ini,"Hotkeys","Disable")
	iniwrite(EnableCHotkey,Ini,"Hotkeys","Enable")
	iniwrite(AutoDisableHotkey,Ini,"Hotkeys","AutoDisable")
	iniwrite(ExEnableHotkey,Ini,"Hotkeys","Exclusions")
	reload ; using reload to update Hotkey inside tray menu

	Hotkey DisableCHotkey, Add, "on" 
	Hotkey EnableCHotkey, Swap, "on"
	Hotkey AutoDisableHotkey, DisableNAdd2Autolist, "on" 
	Hotkey ExEnableHotkey, EnablenAdd2Excludelist, "on"
	
}

DisableNAdd2Autolist(*)
{
	Title := WinGetTitle("A")
	MyClass := WinGetClass(Title)
	iniwrite(MyClass,Ini,"AutoDisable",Title)
	AutoLV.Add(,Title,Class)
	id := WinGetID(Title)
	DISABLE(id)
}

EnablenAdd2Excludelist(*)
{
	Title := WinGetTitle("A")
	MyClass := WinGetClass(Title)
	iniwrite(MyClass,Ini,"AutoExclude",Title)
	ExcludeLV.Add(,Title,Class)
	id := WinGetID("A")
	ENABLE(id)
}

inAutoDisable(id)
{
	Title := WinGetTitle("ahk_id " id)
	MyClass := WinGetClass(Title)
	for titleclasses in StrSplit(IniRead(Ini,"AutoDisable",,""),"`n")
	{
		if titleclasses
		{
			TC := StrSplit(titleclasses,"=")
			if(title = TC[1]) and (Myclass = TC[2])
				return 1
			; ExcludeLV.Add(,TC[1],TC[2])
		}
	}
	return 0
}

inExclusions(id)
{
	Title := WinGetTitle("ahk_id " id)
	MyClass := WinGetClass(Title)
	for titleclasses in StrSplit(IniRead(Ini,"AutoExclude",,""),"`n")
	{
		if titleclasses
		{
			TC := StrSplit(titleclasses,"=")
			if(title = TC[1]) and (Myclass = TC[2])
				return 1
			; ExcludeLV.Add(,TC[1],TC[2])
		}
	}
	return 0
}

Add(*)
{
	id := WinGetID("A")
	if inExclusions(id)
	{
		SetTimer () => ToolTip("This window is listed in Exclusions"), -1000
		SetTimer () => ToolTip(), -2000 ; Remove the tooltip.
		return
	}
	DISABLE(id)
}

Swap(*)
{
	id := WinGetID("A")
	if inAutoDisable(id)
	{
		SetTimer () => ToolTip("This window is listed in AutoDisable"), -1000
		SetTimer () => ToolTip(), -2000 ; Remove the tooltip.
		return
	}
	ENABLE(id)
}

DISABLE(id,Effect:=1) ;By RealityRipple at http://www.xtremevbtalk.com/archive/index.php/t-258725.html
{
	menu:=DllCall("user32\GetSystemMenu","UInt",id,"UInt",0)
	DllCall("user32\DeleteMenu","UInt",menu,"UInt",0xF060,"UInt",0x0)
	if Effect
	{
		WinGetPos(&x,&y,&w,&h,id)
		WinMove(x+1,y+1,w,h-2,ID)
		WinMove(x,y,w,h,ID)
	}
}


ENABLE(id,Effect:=1) ;By Mosaic1 at http://www.xtremevbtalk.com/archive/index.php/t-258725.html
{
	menu:=DllCall("user32\GetSystemMenu","UInt",id,"UInt",1)
	DllCall("user32\DrawMenuBar","UInt",id)
	if Effect
	{
		WinGetPos(&x,&y,&w,&h,id)
		WinMove(x-1,y-1,w,h+2,ID)
		WinMove(x,y,w,h,ID)
	}
}

ApplySettings(*) ; settimer calling this
{
	for titleclasses in StrSplit(IniRead(Ini,"AutoDisable",,""),"`n")
	{
		if titleclasses
		{
			TC := StrSplit(titleclasses,"=")
			;AutoLv.Add(,TC[1],TC[2])
			try id := WinGetID(TC[1] " AHK_Class " TC[2] )
			catch error as e
				return
			DISABLE(id,0)
		}
	}
	
	for titleclasses in StrSplit(IniRead(Ini,"AutoExclude",,""),"`n")
	{
		if titleclasses
		{
			TC := StrSplit(titleclasses,"=")
			try id := WinGetID(TC[1] " AHK_Class " TC[2] )
			catch error as e
				return
			ENABLE(id,0)
		}
	}
}