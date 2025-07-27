#Requires Autohotkey v1.1.33+
/* Title:	TCwdx
			Functions to work with Total Commander content plugins
*/

/*
 Function:	FindIni
			Find full path of the TC wincmd.ini.

 Returns:	
			Path to wincmd.ini if it is found or nothing otherwise.
*/
TCwdx_FindIni() {
	RegRead, ini, HKEY_CURRENT_USER, Software\Ghisler\Total Commander, IniFileName
	if FileExist(ini)
		return ini

	EnvGet COMMANDER_PATH, COMMANDER_PATH
	if (COMMANDER_PATH != ""){
		ini = %COMMANDER_PATH%\wincmd.ini
		if FileExist(ini)
			return ini
	}
}

/*
 Function:	GetPluginsFromDir
			Get list of plugins from directory (no wincmd.ini is used).

 Parameters:
			Root - Root path. Plugnins are searched recursivelly from this path.

 Returns:	
			String in Ini_ format: name=path.
*/
TCwdx_GetPluginsFromDir( Root ) {
	loop, %Root%\*.wdx, ,1
		res .= SubStr(A_LoopFileName,1,-4) "=" A_LoopFileLongPath "`n"
	return SubStr(res, 1, -1)
}

/*
 Function:  GetPlugins
			Get list of installed tc plugins.

 Parameters:
			pIni	-	TC wincmd.ini path or "" to try to get ini location from registry or using
						machine environment variable COMMANDER_PATH

 Returns:	
			String in Ini_ format: name=path or ERR if ini can not be found
 */
TCwdx_GetPlugins( pIni="" ) {
	if pIni =
		pIni := TCwdx_FindIni()
	if !FileExist(pIni)
		return "ERR"

	VarSetCapacity(dest, 512) 

	inSec := 0
	Loop, read, %pIni%
	{
		s := A_LoopReadLine
		if (!inSec){
		   inSec := InStr(s,"[ContentPlugins]")
		   continue
		}
		
		if SubStr(s, 1,1) = "["
			break

		j:=InStr(s, "="), n := SubStr(s, 1, j-1), v:= SubStr(s, j+1)
		if n is Integer	
		{
			DllCall("ExpandEnvironmentStrings", "str", v, "str", dest, "int", 512)
			VarSetCapacity(dest, -1), v := dest
			if !FileExist(v)
				continue
			res .= SubStr(v, InStr(v, "\", false, 0)+1, -4) "=" v "`n"
		}
	}
	return SubStr(res, 1, -1)
}
/*
 Function:  LoadPlugin
			Load plugin dll into the memory	and sets its default parameters.

 Parameters:
			Path2Wdx - Path to TC content plugin.

 */		
TCwdx_LoadPlugin(Path2Wdx) {
	h := DllCall("LoadLibrary", "str", Path2Wdx),  TCwdx_SetDefaultParams(Path2Wdx)
 	return 	h
}

/*
 Function: UnloadPlugin
			Unloads plugin dll

 Parameters:
			hWdx	- Handle returned by LoadPlugin function.
 */
TCwdx_UnloadPlugin(hWdx){
	return 	DllCall("FreeLibrary", "UInt", hWdx) 
}

/*
 Function: GetPluginFields
			Get list of plugin fields.

 Parameters:
			Path2Wdx	-	Path to TC content plugin.
			Format		-	If omited, only field names will be returned, if set to "ini" string will be in Ini_ format, field=index|unit1|unit2...|unitN
						or field=index if there is no unit for given field, if "menu", string will be in ShowMenu format with "|" as item separator and root 
						of the menu named "tcFields".

 Returns:	
			String with fields on each line									 
 */
TCwdx_GetPluginFields( Path2Wdx, Format="" ) {
	Format := Format = "" ? 0 : Format = "ini" ? 1 : 2

	if !(adr := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", Path2Wdx), "astr" , "ContentGetSupportedField")) {
		MsgBox, 64, , Can't find ContentGetSupportedField export in dll`n: %Path2Wdx%
		return
	}
		
	VarSetCapacity(name,256), VarSetCapacity(units,256)	
	loop {
		r := DllCall(adr, "int", A_Index-1, "uint", &name, "uint", &units, "uint", 256)
		IfEqual, r, 0, break										;ft_nomorefields=0
		name := StrGet(&name, "cp0"),	units := StrGet(&units, "cp0")

		IfEqual, r, 7, SetEnv, units								;ft_multiplechoice, multiple fields are not units

		if Format = 0
			res .= name "`n"
		else if Format = 1
			res .= name "=" A_Index-1 (units !="" ? "|" units : "")  "`n"
		else 
			if (units != "") 
				 res .= name "=<" name ">|",   resu .= "[" name "]`n" units "`n" 				;!!!for show menu mod <> instead []
			else res .= name "|"
	}

	StringTrimRight, res, res, 1
	if Format = 2
		res := "[tcFields]`n" res "`n" resu

	return res
}

/*
 Function:  GetField
			Get field data.

 Parameters:
			FileName	 -	File name for which info is to be retreived.
			Path2Wdx	 -	Path to TC content plugin.
			FieldIndex	 -	Field index, by default 0.
			UnitIndex	 -  Unit index, by default 0.

 Returns:	
			Field data.

 Remarks:
			Function first checks for ContentGetValueW function, and if it doesn't exist then ContentGetValue.
			It will do so only once and cache adresses for faster subsequent calls.
 */
TCwdx_GetField(FileName, Path2Wdx, FieldIndex=0, UnitIndex=0){
	static i=0, info, st, adrCache

	if !i
		VarSetCapacity(info,256), VarSetCapacity(st, 16), adrCache := Object(), i++

	if !adrCache[ Path2Wdx ]
	{
		adrCache[ Path2Wdx ] := Object()
		adr := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", Path2Wdx), "astr" , "ContentGetValueW"), type := "str"
		if !adr
			adr := DllCall("GetProcAddress", "uint", DllCall("GetModuleHandle", "str", Path2Wdx), "astr", "ContentGetValue"), type := "astr"
		ifEqual, adr, 0, return A_ThisFunc "> Invalid TC plugin"
		
		adrCache[ Path2Wdx ].adr := adr, adrCache[ Path2Wdx ].type := type
	}

	type := DllCall(adrCache[ Path2Wdx ].adr, adrCache[ Path2Wdx ].type, FileName, "int", FieldIndex, "int", UnitIndex, "uint", &info, "int", 256, "int", 0)

	if (type <=0 or type=9) 
		return
	goto TCwdx_Type_%type%

	TCwdx_Type_1:									;ft_numeric_32
	TCwdx_Type_6:
		return NumGet(info, 0, "Int")		
	TCwdx_Type_2:									;ft_numeric_64	A 64-bit signed number
		return NumGet(info, 0, "Int64")
	TCwdx_Type_3:									;ft_numeric_floating	A double precision floating point number
		return NumGet(info, 0, "Double")
	TCwdx_Type_4:									;ft_date	A date value (year, month, day)
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCwdx_Type_5:									;A time value (hour, minute, second). Date and time are in local time.
		return NumGet(info, 0, "UShort") "." NumGet(info, 2, "UShort") "." NumGet(info, 4, "UShort")
	TCWdx_Type_7:
	TCwdx_Type_8:
		return StrGet(&info, "cp0")
	TCwdx_Type_10:									;A timestamp of type FILETIME, as returned e.g. by FindFirstFile(). It is a 64-bit value representing the number of 100-nanosecond.
		r := DllCall("FileTimeToSystemTime", "uint", &info, "uint", &st)
		ifEqual r, 0, return
		return NumGet(st, 0, "UShort") "." NumGet(st, 2, "UShort") "." NumGet(st, 6, "UShort") " " NumGet(st, 8, "UShort") "." NumGet(st, 10 ,"UShort") "." NumGet(st, 12, "UShort")
	TCwdx_Type_11:									;ft_stringw: FieldValue is a pointer to a 0-terminated wide string.
		VarSetCapacity(info,-1)
		return info
}

/*
 Function:  GetIndices
			Get index of the field and optionaly its unit.

 Parameters:
			Path2Wdx	-	Path to TC content plugin.
			Field		-	Field for which index is to be returned. If unit is to be returned, use "Field.Unit" notation.
			FieldIndex	-	Reference to variable to receive field index or empty string if field is not found.
			UnitIndex	-	Optional Reference to variable to receive unit index or empty string if field is not found.
							If unit is is not requested UI will be set to 0.
 */
TCwdx_GetIndices(Path2Wdx, Field, ByRef FieldIndex, ByRef UnitIndex="."){

	FieldIndex :=  UnitIndex := 0
	if j := InStr(Field, ".") 
		unit := SubStr(Field, j+1), Field := SubStr(Field, 1, j-1)

	VarSetCapacity(name,512), VarSetCapacity(units,512)
	loop {
		r := DllCall(Path2Wdx "\ContentGetSupportedField", "int", A_Index-1, "uint", &name, "uint", &units, "uint", 512)
		IfEqual, r, 0, return										;ft_nomorefields=0
		name := StrGet(&name, "cp0"), unit := StrGet(&unit, "cp0")

		if (name = Field) {
			FieldIndex := A_Index - 1
			if (UnitIndex != ".") and (unit != "") {
				VarSetCapacity(units,-1) 
				loop, parse, units, |
					if (A_LoopField = unit)
						return UnitIndex := A_Index - 1
						
				UnitIndex := ""
			}
			return
		}
	}	
}

/*
 Function:	SetDefaultParams
			Mandatory function for some plugins (like ShellDetails).

 Parameters:
			Path2Wdx	- Path to tc content plugin.
 */
TCwdx_SetDefaultParams(Path2Wdx){
	VarSetCapacity(dps, 272, 0)
	NumPut(272, dps, "Int"), NumPut(30, dps, 4), NumPut(1, dps, 8)

	SplitPath, Path2Wdx, , dir, , name
	name = %dir%\%name%.ini
	DllCall("lstrcpyA", "uint", &dps+12, "astr", name)
	return DllCall(Path2Wdx "\ContentSetDefaultParams", "uint", &dps)	
}

/*
	About:
		o 1.1 by majkinetor
		o Licensed under BSD <http://creativecommons.org/licenses/BSD/> 
*/