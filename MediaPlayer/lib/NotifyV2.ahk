#Requires Autohotkey v2.0-
/*
* ============================================================================ *
* Want a clear path for learning AutoHotkey?                                   *
* Take a look at our AutoHotkey courses here: the-Automator.com/Learn          *
* They're structured in a way to make learning AHK EASY                        *
* And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
* ============================================================================ *
*/

/*
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;Notify AHK V2;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Header, Body, and Background colors supported: Black,Silver,Gray,White,Maroon,Red,Purple,Fuchsia,Green,Lime,Olive,Yellow,Navy,Blue,Teal,Aqua

	'Duration' is how long you want the notice to be displayed before it disappears.
	It should be number, Use 0 to leave it on screen indefintiely until user clicks.

	Be sure to Include this library when using from another script.
	Example:  #Include <Notifyv2>

*/

For arg in A_ARGS
{
	if A_Index &1
	{
		; msgbox arg "`n" A_ARGS[A_Index + 1]
		switch arg {
		case '-BDText':
			msg := A_ARGS[A_Index + 1]
		Case '-Link':
			;msgbox arg "`n" A_ARGS[A_Index + 1]
			href := A_ARGS[A_Index + 1]

			if !A_IsCompiled
			&& href ~= '"'
				href := RegExReplace(href,'\"+','"')
			else if !A_IsCompiled
			&& href ~= '"' == false
				href := RegExReplace(href,'<a href=(.*?)>','<a href="$1">')

			msg := {link: href}
		case '-GenIcon', '-HDFontSize', '-BDFontSize','-GenDuration','-GenIconSize':
			Notify.Default.%StrReplace(Trim(arg), '-')% := number(A_ARGS[A_Index + 1])
		case '-HDText', '-HDFontColor','-HDFont','-BDText','-BDFontColor', '-BDFont','-GenBGColor','-GenSound':
			Notify.Default.%StrReplace(Trim(arg), '-')% := A_ARGS[A_Index + 1]
		default:
		}
	}
}
if IsSet(msg)
{
	Notify.show(msg)
}

Class Notify
{
	; do not modify this variable directly because
	; it would cause the main script to break
	static _Default := {
		HDText        : "",
		HDFontSize    : 16,
		HDFont        : "Impact",
		HDFontColor   : "0x298939",
		BDText        : "Click to Callback",
		BDFontSize    : 12,
		BDFontColor   : "Black",
		BDFont        : "Book Antiqua",
		GenBGColor    : "0xFFD23E",
		GenDuration   : 3,
		GenSound      : "",
		GenIcon	      : "",
		GenIconSize   : 30,
	}

	Static Default
	{
		set => Notify._default := value
		get {
			static default_props := Map(
			'HDText'        , "",
			'HDFontSize'    , 14,
			'HDFont'        , "Impact",
			'HDFontColor'   , "Black",
			'BDFontSize'    , 10,
			'BDFontColor'   , "0x298939",
			'BDFont'        , "Book Antiqua",
			'GenBGColor'    , "0xFFD23E",
			'GenDuration'   , 3,
			'GenSound'      , "",
			'GenIcon'       , "",
			'GenIconSize'   , 30,
			)
			for prop in default_props
				if !Notify._Default.HasProp(prop)
					Notify._Default.%prop% := default_props[prop]

			return Notify._default
		}
	}
	Static wavList := "Sound List:`nName" ; `t`t Path"
	Static wav := Notify.GetSoundFiles()

	static Show(Input)
	{
		Switch(Type(Input))
		{
		Case "String":
			this.HDText      := Notify.Default.HDText
			this.HDSize      := Notify.Default.HDFontSize
			this.HDColor     := Notify.Default.HDFontColor
			this.HDFont      := Notify.Default.HDFont
			this.Text        := input
			this.BDSize      := Notify.Default.BDFontSize
			this.BDColor     := Notify.Default.BDFontColor
			this.BDFont      := Notify.Default.BDFont
			this.Duration    := Notify.Default.GenDuration
			this.Color       := Notify.Default.GenBGColor
			this.Sound       := Notify.Default.GenSound
			this.GenIcon     := Notify.Default.GenIcon
			this.GenIconSize := Notify.Default.GenIconSize
			this.Link        := ""
			this.Callback    := 0
		Case "Object":
			this.HDText      := input.HasOwnProp("HDText")      ? input.HDText      : Notify.Default.HDText
			this.HDSize      := input.HasOwnProp("HDFontSize")  ? input.HDFontSize  : Notify.Default.HDFontSize
			this.HDColor     := input.HasOwnProp("HDFontColor") ? input.HDFontColor : Notify.Default.HDFontColor
			this.HDFont      := input.HasOwnProp("HDFont")      ? input.HDFont      : Notify.Default.HDFont
			this.BDSize      := input.HasOwnProp("BDFontSize")  ? input.BDFontSize  : Notify.Default.BDFontSize
			this.BDColor     := input.HasOwnProp("BDFontColor") ? input.BDFontColor : Notify.Default.BDFontColor
			this.BDFont      := input.HasOwnProp("BDFont")      ? input.BDFont      : Notify.Default.BDFont
			this.Color       := input.HasOwnProp("GenBGColor")    ? input.GenBGColor    : Notify.Default.GenBGColor
			this.Duration    := input.HasOwnProp("GenDuration") ? input.GenDuration : Notify.Default.GenDuration
			this.Sound       := input.HasOwnProp("GenSound")    ? input.GenSound    : Notify.Default.GenSound
			this.GenIcon     := input.HasOwnProp("GenIcon")      ? input.GenIcon      : Notify.Default.GenIcon
			this.GenIconSize := input.HasOwnProp("GenIconSize")  ? input.GenIconSize  : Notify.Default.GenIconSize
			this.Link        := input.HasOwnProp("Link")        ? input.Link        : ""
			this.Callback    := input.HasOwnProp("GenCallback") ? input.GenCallback : 0
			this.Text        := input.HasOwnProp("BDText")      ? input.BDText      : ""
		}
		Notify.Play(this.Sound)
		this.Notice := MultiGui(this)
		if this.Duration != 0
			this.Close()
		return this
	}

	Static CloseLast()
	{
		try Notify.Notice.Close()
	}

	Static Close()
	{
		fn := ObjBindMethod(this, "animation", this.Notice)
		Settimer fn, -(this.Duration * 1000)
	}

	static animation(Notice) => Notice.close()

	static Play(Sound)
	{
		if RegExMatch(Sound,'^\*\-?\d+')
		|| FileExist(Sound)
			return Soundplay(Sound)
		try SoundFile := Notify.wav[Sound]
		catch
			return
		if FileExist(SoundFile)
			Soundplay(SoundFile)
		return
	}

	Static GetSoundFiles()
	{
		wav := map()
		loop files, "C:\Windows\Media\*.wav"
		{
			name := RegExReplace(A_LoopFileName,"Windows |notify |Hardware |.wav")
			if InStr(name," ")
				continue
			this.wavList .= "`n"  name  ;(InStr(name,"Alarm") ? "`t" : StrLen(name) < 8 ? "`t`t":"`t" ) ": " A_LoopFileName
			wav[name] := A_LoopFileFullPath
		}

		loop files, A_ScriptDir "\res\*.wav"
		{
			name := StrReplace(A_LoopFileName,".wav")
			this.wavList .= "`n"  name ;(StrLen(name) < 8 ? "`t`t":"`t" ) ": " A_LoopFileName
			wav[name] := A_LoopFileFullPath
		}
		return wav
	}


	; method to list all supported Alert Sounds
	Static SoundList() => this.Show({HDText:"GenSound list`nSupported by Notify",BDText:'Copied to clipboard`n' A_Clipboard := this.wavList,GenDuration:0,GenSound:"Insert"})
	; method to List all Color
	Static ColorList()
	{
		Colors :="
		(
			Black
			Silver
			Gray
			White
			Maroon
			Red
			Purple
			Fuchsia
			Green
			Lime
			Olive
			Yellow
			Navy
			Blue
			Teal
			Aqua
		)"
		this.Show({HDText:"HD BD and Gen Colors`nSupported by Notify",BDText:'Copied to clipboard`n' A_Clipboard := Colors,GenDuration:0,GenSound:"Remove"})
	}
	; method to list all GenIcons
	Static GenIconList()
	{
		GenIconHelp :=
		(
'GenIcon can be:
â€‚â€‚â€¢â€‚Integer from Shell32.dll
â€‚â€‚â€¢â€‚Image/Icon Path
â€‚â€‚â€¢â€‚Any of the following strings:
	o Critical
	o Question
	o Exclamation
	o Information
	o Security

GenIconSize: is number where the hight and width are the same'
		)
		Notify.Show({
			HDText:"GenIcon List`nGenIcons number or address should be passed",
			BDFontSize:16,
			GenDuration:10,
			GenIcon:96,
			GenIconSize:50,
			BDText: GenIconHelp
		})
	}


	static IconPicker()
	{
		Count := 329, Shell := 1, Image := 0, icoFile := "shell32.dll", Height := A_ScreenHeight - 170 ;Define constants
		iGui := Gui('-MinimizeBox -MaximizeBox','Notify Icon Picker')
		iGui.OnEvent('Close',exit)
		LV := iGui.AddListView('h' Height ' w400 +Icon',['Number'])
		LV.OnEvent('click',ListClick)
		ImageListID := IL_Create(Count,10,true)
		LV.SetImageList(ImageListID)
		loop Count
		{
			pos := IL_Add(ImageListID,icoFile,A_Index)
			LV.Add("Icon" pos,A_index)
		}
		LV.ModifyCol(1,'autohdr')  ; Auto-adjust the column widths.
		LV.ModifyCol(2,'autohdr integer Center')  ; Auto-adjust the column widths.
		iGui.Show()
		return

		ListClick(obj,info){
			n := LV.getText(info )
			a_Clipboard := n ; "Menu, Tray, Icon, %A_WinDir%\system32\" IcoFile "," info " `;Set custom Script icon`n"
			tooltip 'Copied Icon Number ' n
			SetTimer( ToolTip, -800  )
		}

		exit(*)
		{
			iGui.Destroy()
		}
	}

}

Class MultiGui
{
	static Guis := array()
	Static Taskbar := MultiGui.GetTaskBarPos()
	Static LastPOs := {x:0,y:0,w:0,h:0}
	Static ShellDll := A_WinDir "\System32\shell32.dll"
	Static user32Dll := A_WinDir "\system32\user32.dll"
	Static Warning := Map(
		"Exclamation",2,
		"Question",3,
		"Critical",4,
		"Information",5,
		"Security",7
	)
	__new(info)
	{
		MyGui := Gui("-Caption +AlwaysOnTop +Owner +LastFound")
		MyGui.MarginX := 5
		MyGui.MarginY := 5
		MyGui.BackColor := info.Color
		if (Type(Info.GenIcon) = "Integer")
			MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize " Icon" Info.GenIcon + 0, MultiGui.ShellDll)
		else if FileExist(Info.GenIcon)
			MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize,Info.GenIcon )
		else if Info.GenIcon && InStr("Critical,Question,Exclamation,Information,Security",Info.GenIcon)
			MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize " Icon" MultiGui.Warning[Info.GenIcon], MultiGui.user32Dll)

		MyGui.SetFont("c" info.HDColor " s" info.HDSize , info.HDFont )
		if info.HDText
			MyGui.Add("Text","x+m", info.HDText)
		MyGui.SetFont(opts := "c" info.BDColor " s" info.BDSize , info.BDFont )
		if info.Link
			MyGui.AddLink(, info.Link)
		else if info.Text
			MyGui.AddText("vText y+m",info.Text ) ;"xp yp+" this.Header.Font.Size +9.5, this.Body.Text)
		MyGui.Show("Hide")
		This.MyGui := MyGui
		WinGetPos(&x,&y,&w,&h,MyGui)

		clickArea := MyGui.Add("Text", "x0 y0 w" . W . " h" . H . " BackgroundTrans")
		if info.Callback
		{
			clickArea.OnEvent("Click",     info.Callback )
		    Info.Duration := 0
		}


		if Info.Duration = 0
			clickArea.OnEvent("Click",     ObjBindMethod(this,"Close",MyGui) )

		MultiGui.Guis.Push(MyGui)
		if MultiGui.Guis.Length > 1 ;IsSet(LastNote)
		{
			Switch MultiGui.Taskbar.Docked
			{
				Case "B":
				if (MultiGui.LastPOs.HasProp('y'))
				&& ( (MultiGui.LastPOs.y - h) > 0)
					POS := "x" A_ScreenWidth - w " y" MultiGui.LastPOs.y - h -1
				else
					POS := "x" MultiGui.LastPOs.x - w " y" A_ScreenHeight - MultiGui.TaskBar.h - h
				Case "R":
				if( (MultiGui.LastPOs.y - h) > 0)
					POS := "x" MultiGui.LastPOs.x " y" MultiGui.LastPOs.y - h - 1
				else
					POS := "x" MultiGui.LastPOs.x - w " y" A_ScreenHeight - h
			}
		}
		else
		{
			Switch MultiGui.Taskbar.Docked
			{
				Case "B":
				POS := "x" A_ScreenWidth - w " y" A_ScreenHeight - MultiGui.TaskBar.h - h
				Case "R":
				POS := "x" A_ScreenWidth - w - MultiGui.TaskBar.w " y" A_ScreenHeight - h
				default:
				POS := "x" A_ScreenWidth - w " y" A_ScreenHeight - h
			}
		}

		MyGui.Show(POS " NoActivate")
		WinGetPos(&x,&y,&w,&h,MyGui)
		MultiGui.LastPOs := {x:x,y:y,w:w,h:h}
	}

	Close(*)
	{
		delete := 0
		for i, Gui in MultiGui.Guis
		{
			if this.MyGui.Hwnd = Gui.Hwnd
			{
				MultiGui.Guis.RemoveAt(i)
				MyGui := Gui
				try WinGetPos(&x,&y,&w,&h,MultiGui.Guis[i-1])
				catch
					try WinGetPos(&x,&y,&w,&h,MultiGui.Guis[i])
				delete := 1
			}
		}
		if Delete = 0
			return
		WinGetPos(&ix,&iy,&w,&h,MyGui)
		loop 50
		{
			If (!Mod(A_index, 18))
			{
				WinSetTransColor("Blue " 255 - A_index * 5,MyGui)
				MyGui.Move(iX += 10, iY)
				sleep 50
			}
		}

		this.MyGui.Destroy()
		if IsSet(x)
			MultiGui.LastPOs := {x:x,y:y,w:w,h:h}
		else
			MultiGui.LastPOs := {x:0,0:0,w:0,h:0}
	}

	Static GetTaskBarPos()
	{
		WinGetPos(&x,&y,&w,&h, "ahk_class Shell_TrayWnd")
		if x = 0 && y = 0 && w = A_ScreenWidth
			Docked := "T"
		else if x = 0 && y = 0 && h = A_ScreenHeight
			Docked := "L"
		else if x = 0 &&  y > 0 && w = A_ScreenWidth
			Docked := "B"
		else if x > 0 && y = 0 && h = A_ScreenHeight
			Docked := "R"
		return {x:x,y:y,w:w,h:h,Docked:Docked}
	}
}