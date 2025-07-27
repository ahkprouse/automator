/**
 * ============================================================================ *
 * @Author   : Xeo786                                                          *
 * @Homepage : the-automator.com                                                                 *
 *                                                                              *
 * @Created  : May 17, 2024                                                   *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 */

/*
	This work by the-Automator.com is licensed under CC BY 4.0

	Attribution — You must give appropriate credit , provide a link to the license,
	and indicate if changes were made.
	You may do so in any reasonable manner, but not in any way that suggests the licensor
	endorses you or your use.
	No additional restrictions — You may not apply legal terms or technological measures that
	legally restrict others from doing anything the license permits.
*/

;@Ahk2Exe-SetVersion     1.2.2
;@Ahk2Exe-SetMainIcon    C:\Windows\system32\mmcndmgr.dll,42
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#SingleInstance
#Requires Autohotkey v2.0+
#include %A_LineFile%\..\lib\ScriptObject.ahk
#include %A_LineFile%\..\lib\Pref_gui.ahk

script := {
	        base : ScriptObj(),
	     version : '1.2.1',
	      author : 'Xeo786',
	       email : '',
	     crtdate : 'March 14, 2024',
	     moddate : 'August 27, 2024',
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'mmcndmgr.dll' , 
	      config : A_ScriptDir "\Checklist.ini",
	homepagetext : "the-automator.com/checklist",
	homepagelink : "the-automator.com/checklist?src=app",
	 donateLink : ""
}

TraySetIcon(script.iconfile,42)
ini := script.config
tray := A_TrayMenu
tray.Delete()
list := GetList(IniRead(ini,"Templates","List",pGui['List'].value))

tGui := Gui('+resize','Checklist: ' pGui['Tmp'].Text)
tGui.OnEvent('size',resizeGui)
; tGui.OnEvent('Close',(*)=>ExitApp())

script.hwnd := tGui.Hwnd

tGui.OnEvent('Close',(*)=>tGui.Hide())
tGui.SetFont("s12")

MainSel := tGui.AddDropDownList('x10 y13',AllTemplates)
tGui.AddButton('x+m yp-3','Add/Edit List').OnEvent('click',ShowListEdit)
tGui.AddButton('x+m+100 yp-3','Preferences').OnEvent('click',(*) => (tGui.Hide(),sleep( 100),p2Gui.Show()))
tGui.AddButton('x+m','Exit').OnEvent('click',(*)=>ExitApp())
LV := tGui.AddListView("xm w500 h600 checked -hdr", ["Tasks","Time"])

LV.OnEvent("ItemCheck",StrikethroughLV)
try MainSel.Text := sel
catch
	MainSel.Choose(1)
MainSel.OnEvent('Change',(*)=>(IniWrite(tGui.Title := 'Checklist: ' MainSel.Text ,ini,"Selected","List"),ControlChooseString(MainSel.Text, pGui['Tmp'], pGui),BuildLV()))
BuildLV()

tray.Add('Show Check List`t' HKToString(p2Gui.oldHK),(*)=>tGui.Show())
tray.Default := 'Show Check List`t' HKToString(p2Gui.oldHK)
tray.Add('Preference',(*)=>(tGui.Hide(),p2Gui.Show()))
tray.Add()
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.Add('Exit',(*)=>ExitApp)
; tray.AddStandard()

if InStr(startcheck,'+')
	tGui.Show()

; f1::pGui.show() ; testing

resizeGui(GuiObj, MinMax, Width, Height)
{
	LV.move(,,Width-50,Height-70)
	LV.Redraw()
	for ctrl in tGui
	{
		switch X := type(ctrl), 0
		{
			Case 'Gui.Listview':
				ctrl.move(,,Width-30,Height-70)
			; Case 'Gui.Button':
			; 	ctrl.Move(,Height-40)
		}
	}
	
}

BuildLV()
{
	tmp := pGui['Tmp'].Text
	if !tmp
		return
	LV.Delete()
	;for k, bullet in GetList(IniRead(ini,"Templates",tmp,pGui['List'].value))
	for k, bullet in T:=GetList(IniRead(ini,"Templates",tmp,pGui['List'].value))
	{
		; if IniRead(ini, "Tasks", bullet, 0)
		if state := IniRead(ini,MainSel.text, bullet, 0)
		{
			LV.Add('+check',Strike(bullet),state)
		}
		else
			LV.Add('-check',bullet)
	}
	LV.ModifyCol()
}

StrikethroughLV(obj, item, state)
{
	text := LV.GetText(item)
	; IniWrite(state, ini, "Tasks",unstrike(text) )
	if (state)
	{
		lv.Modify(item,,,state :=  FormatTime( a_now, 'MMM-dd@h:mm tt' ))
		LV.Modify(item,, Strike(text))
	}
	else
	{
		lv.Modify(item,,," ")
		LV.Modify(item,, unstrike(text))
	}
	IniWrite(state, ini, MainSel.text,unstrike(text) )
	LV.ModifyCol()
	; tooltip LVgetAllColWidth()s
}

unstrike(str) => StrReplace(str, Chr(0x336))

Strike(str)
{
	out .= Chr(0x336)
	Loop parse, str
	out .= A_LoopField Chr(0x336)
	return out
}

LVgetAllColWidth()
{
	ColWidth := 0
	Loop LV.GetCount("Column")
	{
		ColWidth += SendMessage(0x101D, A_Index - 1, 0, LV)  ; 0x101D is LVM_GETCOLUMNWIDTH.
	}
	return ColWidth
}

; https://www.autohotkey.com/board/topic/16625-function-gettextsize-calculate-text-dimension/
TextWidth(String,Typeface,Size)
{
    static hDC := DllCall("GetDC","UPtr",0,"UPtr"), hFont := 0, Extent
	; OutputDebug String '`n' main.MaxStr  '`n' Typeface " " Size "`n" 
    If !hFont
    {
        Height := -DllCall("MulDiv","Int",Size,"Int",DllCall("GetDeviceCaps","UPtr",hDC,"Int",90),"Int",72)
        hFont := DllCall("CreateFont","Int",Height,"Int",0,"Int",0,"Int",0,"Int",400,"UInt",False,"UInt",False,"UInt",False,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"UInt",0,"Str",Typeface)
        hOriginalFont := DllCall("SelectObject","UPtr",hDC,"UPtr",hFont,"UPtr")
		Extent := Buffer(8)
    }
    DllCall("GetTextExtentPoint32","Ptr",hDC,"Str",String,"Int",StrLen(String),"Ptr",Extent)
    Return NumGet(Extent,0,'Int')
}