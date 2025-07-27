;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey Udemy courses.  They're structured in a way to make learning AHK EASY
; Right now you can  get a coupon code here: https://the-Automator.com/Learn
;==================================================
;slight modification of: get DST (daylight-saving time) start/end dates/times in UTC - AutoHotkey Community
;https://www.autohotkey.com/boards/viewtopic.php?f=5&t=28355&p=162191#p162191 with each DropDownList/Text pair, horizontal, instead of vertical
;==================================================
;show clocks for various time zones:;UTC, local, New York, London, Paris, Munich

#SingleInstance force

vYear := SubStr(A_NowUTC, 1, 4)
vUseMui := 0
if vUseMui
{
	vPath := "C:\Windows\System32\tzres.dll"
	hModule := DllCall("kernel32\LoadLibrary", "Str",vPath, "Ptr")
	vPfx := "MUI_"
}
else
	vPfx := ""

vTemp := 0
SetTimer, UpdateTimestamps, 1000

(oTemp := {}).SetCapacity(200)
(oArray := {}).SetCapacity(200)
;note: registry loop retrieves items in reverse order
Loop Reg, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones", % "K"
{
	vTimeZoneKeyName := A_LoopRegName
	RegRead, vIsObsolete, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, IsObsolete
	if vIsObsolete
		continue
	RegRead, vDisplay, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, % vPfx "Display"

	if vUseMui
	{
		vNum := RegExReplace(vDisplay, ".*-")
		VarSetCapacity(vDisplay, 1024)
		DllCall("user32\LoadString", "Ptr",hModule, "UInt",vNum, "Str",vDisplay, "Int",1024)
	}
	else
		vNum := RegExReplace(vDisplay, "\(UTC|\+|:|\).*")

	;note: vNum will be used to sort items
	(vNum = "") && (vNum := 0)
	oTemp.Push((vNum+50000) vDisplay)

	;oArray[vDisplay] := vTimeZoneKeyName
	oArray[vDisplay] := JEE_TimeZoneGetInfo(vTimeZoneKeyName, vYear, vUseMui)
	InStr(vDisplay, "(UTC)") && (vDisplayUTC := vDisplay)
	InStr(vDisplay, "Eastern Time") && (vDisplayNewYork := vDisplay)
	InStr(vDisplay, "London") && (vDisplayLondon := vDisplay)
	InStr(vDisplay, "Paris") && (vDisplayParis := vDisplay)
	InStr(vDisplay, "Berlin") && (vDisplayMunich := vDisplay)
}
vOutput := ""
VarSetCapacity(vOutput, 10000*2)
Loop % oTemp.Length()
	vOutput .= oTemp[oTemp.Length()+1-A_Index] "|"
Sort, vOutput, D|
vOutput := RegExReplace(vOutput, "(^|\|)\K.{5}")

RegRead, vTimeZoneKeyName, HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation, TimeZoneKeyName
RegRead, vDisplay, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, Display
vOptGUI := "w240"
vFontSize1 := "s10"
vFontSize2 := "s14"

oDDL := []
oDDL.1 := StrReplace(vOutput, vDisplayUTC "|", vDisplayUTC "||")
oDDL.2 := StrReplace(vOutput, vDisplay "|", vDisplay "||")
oDDL.3 := StrReplace(vOutput, vDisplayNewYork "|", vDisplayNewYork "||")
oDDL.4 := StrReplace(vOutput, vDisplayLondon "|", vDisplayLondon "||")
oDDL.5 := StrReplace(vOutput, vDisplayParis "|", vDisplayParis "||")
oDDL.6 := StrReplace(vOutput, vDisplayMunich "|", vDisplayMunich "||")

for vKey, vValue in oDDL
{
	Gui, Font, % vFontSize1
	Gui, Add, DropDownList, % vOptGUI " w420 x5 y+10", % vValue
	Gui, Font, % vFontSize2
	Gui, Add, Text, % vOptGUI " xp+430"
}

Gui, Show,, time zones
return

;==================================================

UpdateTimestamps:
vTemp++
WinGet, hWnd, ID, time zones ahk_class AutoHotkeyGUI
vNow := A_NowUTC
if !(vYear = SubStr(vNow, 1, 4))
{
	Reload
	return
}
Loop 6
{
	vDate := vNow
	ControlGetText, vText, % "ComboBox" A_Index, % "ahk_id " hWnd
	vTemp := ((vDate < oArray[vText].date1) || (vDate >= oArray[vText].date2)) ? 1 : 2
	EnvAdd, vDate, % -oArray[vText, "offset" vTemp], Minutes
	vTimeZone := oArray[vText, "name" vTemp]
	;~ FormatTime, vDate, % vDate, ddd yyyy-MM-dd HH:mm:ss ;orig
	;~ FormatTime, vDate, % vDate, MMM-dd HH:mm ;Joe
	FormatTime, vDate, % vDate, h:mm tt ;Joe
	ControlSetText, % "Static" A_Index, % vDate " " vTimeZone, % "ahk_id " hWnd
}
return

;==================================================

JEE_TimeZoneGetInfo(vTimeZoneKeyName, vYear:="", vUseMui:=0)
{
	local
	static vIsReady := 0, vPfx := ""
	if vUseMui & !vIsReady
	{
		vPath := "C:\Windows\System32\tzres.dll"
		hModule := DllCall("kernel32\LoadLibrary", "Str",vPath, "Ptr")
		vPfx := "MUI_"
		vIsReady := 1
	}

	(vYear = "") && (vNow := A_NowUTC, vYear := SubStr(vNow, 1, 4))
	RegRead, vDlt, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, % vPfx "Dlt"
	RegRead, vStd, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, % vPfx "Std"
	RegRead, vHex, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName "\Dynamic DST", % vYear
	if (vHex = "")
		RegRead, vHex, % "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\" vTimeZoneKeyName, TZI

	if vUseMui
	{
		vNum := RegExReplace(vDlt, ".*-")
		VarSetCapacity(vDlt, 1024)
		DllCall("user32\LoadString", "Ptr",hModule, "UInt",vNum, "Str",vDlt, "Int",1024)
		vNum := RegExReplace(vStd, ".*-")
		VarSetCapacity(vStd, 1024)
		DllCall("user32\LoadString", "Ptr",hModule, "UInt",vNum, "Str",vStd, "Int",1024)
	}

	vChars := 88, vSize := 44
	;CRYPT_STRING_HEX := 0x4
	;CRYPT_STRING_HEXRAW := 0xC ;(not supported by Windows XP)
	DllCall("crypt32\CryptStringToBinary", "Ptr",&vHex, "UInt",vChars, "UInt",0x4, "Ptr",0, "UInt*",vSize, "Ptr",0, "Ptr",0)
	VarSetCapacity(REG_TZI_FORMAT, vSize, 0)
	DllCall("crypt32\CryptStringToBinary", "Ptr",&vHex, "UInt",vChars, "UInt",0x4, "Ptr",&REG_TZI_FORMAT, "UInt*",vSize, "Ptr",0, "Ptr",0)

	vBias := NumGet(&REG_TZI_FORMAT, 0, "Int") ;Bias
	vBias2 := NumGet(&REG_TZI_FORMAT, 4, "Int") ;StandardBias
	vBias1 := NumGet(&REG_TZI_FORMAT, 8, "Int") ;DaylightBias
	;StandardDate and DaylightDate:
	Loop 2
	{
		vOffset := &REG_TZI_FORMAT + (A_Index=1?12:28)
		vMonth := NumGet(vOffset+0, 2, "Short") ;wMonth
		vDayOfWeek := NumGet(vOffset+0, 4, "Short") ;wDayOfWeek ;XXXday
		vDay := NumGet(vOffset+0, 6, "Short") ;wDay ;e.g. 1=first XXXday of month, 5=last XXXday of month
		vHour := NumGet(vOffset+0, 8, "Short") ;wHour
		vMinute := NumGet(vOffset+0, 10, "Short") ;wMinute

		vDate := Format("{:04}{:02}01{:02}{:02}00", vYear, vMonth, vHour, vMinute)
		FormatTime, vWDay, % vDate, WDay
		EnvAdd, vDate, % Mod(8+vDayOfWeek-vWDay,7)+(vDay-1)*7, Days
		EnvAdd, vDate, % vBias + vBias%A_Index%, Minutes
		if !(SubStr(vDate, 5, 2) = vMonth)
			EnvAdd, vDate, -7, Days
		vDate%A_Index% := vDate

		(vMonth = 0) &&	(vBias%A_Index% := 0)
	}
	oArray := {}
	;date1 is date DST ends, date2 is date DST starts,
	;offset1 is offset when not DST, offset2 is offset when is DST
	if (vDate1 < vDate2) ;period between dates is not DST
		oArray := {date1:vDate1, date2:vDate2, offset1:vBias+vBias1, offset2:vBias+vBias2, name1:vDlt, name2:vStd}
	else ;period between dates is DST
		oArray := {date1:vDate2, date2:vDate1, offset1:vBias+vBias2, offset2:vBias+vBias1, name1:vStd, name2:vDlt}
	return oArray
}

;==================================================

;links (registry keys/structs/MUI):

;_TIME_ZONE_INFORMATION | Microsoft Docs
;https://docs.microsoft.com/en-us/windows/desktop/api/timezoneapi/ns-timezoneapi-_time_zone_information
;DYNAMIC_TIME_ZONE_INFORMATION (timezoneapi.h) | Microsoft Docs
;https://docs.microsoft.com/en-gb/windows/desktop/api/timezoneapi/ns-timezoneapi-dynamic_time_zone_information
;Dynamic daylight saving time provides support for time zones whose boundaries for daylight saving time change from year to year.
;Multilingual User Interface - Windows applications | Microsoft Docs
;https://docs.microsoft.com/en-gb/windows/desktop/Intl/multilingual-user-interface

;registry keys:

;HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation
;HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones

;structs:

;[size: 172]
;typedef struct _TIME_ZONE_INFORMATION {
;  LONG       Bias;
;  WCHAR      StandardName[32];
;  SYSTEMTIME StandardDate;
;  LONG       StandardBias;
;  WCHAR      DaylightName[32];
;  SYSTEMTIME DaylightDate;
;  LONG       DaylightBias;
;} TIME_ZONE_INFORMATION, *PTIME_ZONE_INFORMATION, *LPTIME_ZONE_INFORMATION;

;[size: 44]
;typedef struct _REG_TZI_FORMAT
;{
;    LONG Bias;
;    LONG StandardBias;
;    LONG DaylightBias;
;    SYSTEMTIME StandardDate;
;    SYSTEMTIME DaylightDate;
;} REG_TZI_FORMAT;

;==================================================

