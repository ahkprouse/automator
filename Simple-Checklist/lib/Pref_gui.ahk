#Requires AutoHotkey v2.0
ini := A_ScriptDir "\Checklist.ini"
pGui := Gui(,'Add/Edit List')
pGui.backcolor := 0xffb7ffe3
pGui.OnEvent('Close',(*)=>(pGui.Hide(),tGui.Show()))
; pGui.OnEvent('show',onListeditshow)
pGui.SetFont("s12")
sel := IniRead(ini,"Selected","templet","Default")
List := MultiLine(IniRead(ini,"Templates",sel,"Task 1¶Task 2¶Task 3"))
AllTemplates := []
try templestList := IniRead(ini,"Templates")
if !IsSet(templestList)
{
	IniWrite("Task 1¶Task 2¶Task 3",ini,"Templates","Default")
	IniWrite("Task A¶Task B¶Task C",ini,"Templates","Example")
	templestList := IniRead(ini,"Templates")
}

for k, v in StrSplit(templestList,'`n')
{
	RegExMatch(v,'(.*)=(.*)',&t)
	AllTemplates.Push(t[1])
}

pGui.AddText("xm ",'List Name:')
pGui.AddComboBox('x+m yp-3 vTmp ',AllTemplates).OnEvent('change',ChangeList)
pGui['tmp'].text := sel
pGui.AddButton('x+m h29 disabled vAdd section' ,'Add List').OnEvent('click',AddTemplate)
; pGui.AddGroupBox('xp-1 h29 w30') ; groupbox does not take onmouse event
pGui.AddButton('x+m h29 vDel','Remove List').OnEvent('click',DelTemplate)
pGui.AddButton('xs h29 vApply','Update List').OnEvent('click',ApplySettings)
pGui.AddButton('x+m h29','Cancel').OnEvent('click',(*)=>(pGui.Hide(),sleep( 100),tGui.Show()))

pGui.AddText("xm yp+8 vChklText w200",'Modify Check list:')
pGui.AddEdit("xm +multi w500 h500 vList",List).OnEvent('change',ChangeList)
; pGui.SetFont('cgreen')

p2Gui := Gui(,'Preferences')
p2Gui.SetFont("s12")
p2Gui.AddGroupBox('xm w300 h80 cred','Show/Hide')
p2Gui.AddHotkey("xp+20 yp+30 vHK section",)
p2Gui.AddCheckBox( "x+m vWK yp+3", "Win") ;.onEvent('click',eventhandler)

startcheck := IniRead(ini,'Settings','Show',1) ? '+Checked' : '-Checked'

startctrl := p2Gui.AddCheckbox('xm vShow ' startcheck, 'Display on Startup')
startctrl.OnEvent('click',(*)=>IniWrite(startctrl.value,ini,'Settings','Show'))

startupcheck := IniRead(ini,'Settings','StartupRun',1) ? '+Checked' : '-Checked'
startupctrl := p2Gui.AddCheckbox('xm ' startupcheck, 'Add to Windows Startup')

p2Gui.AddButton('xm+155','Apply').OnEvent('click',ApplyPreferences)
p2Gui.AddButton('x+m','Cancel').OnEvent('click',(*)=>(tGui.Show(),p2Gui.Hide()))


WK := p2Gui['WK'].value := IniRead(ini,'Hotkeys','WK',0)
p2Gui['HK'].value := HK :=  IniRead(ini,'Hotkeys','HK','NumpadMult')
if HK
&& WK
	HK := '#' HK
p2Gui.oldHK := HK
if HK
	Hotkey(HK,Showhide,'on')
; pGui.SetFont('cBlack')
; pGui.Show()
OnMessage(0x0200, WM_MOUSEMOVE)
WM_MOUSEMOVE(wParam, lParam, msg, hwnd)
{
	switch hwnd
	{
		; Case pGui['Add'].Hwnd  :
		; 		ToolTip("Please Add Tasks/Lines to add new List ",,,20)
		Case pGui['List'].Hwnd  :
			if pGui['List'].value = ''
				ToolTip("Please Add Tasks/Lines to add new List ",,,20)
		Default:ToolTip(,,,20)
	}
}

AddTemplate(*)
{
	List := pGui['List'].value := Trim(RegExReplace(pGui['List'].value, '(^|\R)\K\s+'),'`n')
	if !pGui['List'].value
		return
	
	tmp := pGui['Tmp'].Text
	if !tmp
		return

	for k, v in AllTemplates
		if v = tmp
			return
	IniWrite(SingleLine(List),ini,"Templates",tmp)
	AllTemplates.push(tmp)
	pGui['Tmp'].Delete()
	MainSel.Delete()
	pGui['Tmp'].Add(AllTemplates)
	MainSel.Add(AllTemplates)
	pGui['Tmp'].text := tmp
	MainSel.text := tmp
	pGui['add'].opt('+Disabled')
	pGui['apply'].opt('-Disabled')
	pGui['Del'].opt('-Disabled')
}

DelTemplate(*)
{
	global sel
	tmp := pGui['Tmp'].Text

	msg := 'would you like to delete the template "' tmp '"?'
	if 'No' = MsgBox(msg, 'Delete Template','Y/N Icon?')
		return

	if !tmp 
	|| tmp = 'Default'
		return
	IniDelete(ini,"Templates",tmp)
	for k, v in AllTemplates
	{
		if v = tmp
		{
			AllTemplates.RemoveAt(k)
			if v = sel
				sel := 0
		}
	}
	
	pGui['Tmp'].Delete()
	pGui['Tmp'].Add(AllTemplates)

	MainSel.Delete()
	MainSel.Add(AllTemplates)
	MainSel.choose(1)
	pGui['Tmp'].choose(1)

	BuildLV()
	tGui.Show()
	sleep( 100)
	pGui.Hide()
}

ShowListEdit(*)
{
	tGui.Hide()
	sleep( 100)
	pGui.Show()
	; pGui['Tmp'].Text := MainSel.Text
	ControlChooseString(MainSel.Text, pGui['Tmp'], pGui) ; just to trigger event  this is why we are not using above line
	pGui['apply'].opt('+Disabled')
}

ChangeList(ctrl,*)
{
	static defaultList := "Task 1¶Task 2¶Task 3"
	tmp := pGui['Tmp'].Text
	if !tmp
		return
	list := IniRead(ini,"Templates",tmp,0)
	switch ctrl.name
	{
		case 'Tmp':
			pGui['add'].opt('+Disabled')
			pGui['Del'].opt('-Disabled')
			if list
			{
				pGui['List'].value := MultiLine(list)
				pGui['ChklText'].value := 'Modify Check list:'
				pGui['apply'].opt('+Disabled')
			}
			else
			{
				pGui['List'].value := ''
				pGui['ChklText'].value := 'Add New Check list:'
				pGui['apply'].opt('+Disabled')
				pGui['Del'].opt('+Disabled')
				
			}
		case 'List':
			if pGui['List'].value
			&& !list
				pGui['add'].opt('-Disabled')
			else
			{
				pGui['add'].opt('+Disabled')
				pGui['apply'].opt('-Disabled')
			}
	}
}

ApplyPreferences(*)
{
	if p2Gui.oldHK
		Hotkey(p2Gui.oldHK,Showhide,'off')
	IniWrite(startupctrl.value,ini,'Settings','StartupRun')
	script.Autostart(startupctrl.value)

	WK := p2Gui['WK'].value
	HK := p2Gui['HK'].value
	IniWrite(WK,ini,'Hotkeys','WK')
	IniWrite(HK,ini,'Hotkeys','HK')
	if HK
	&& WK
		HK := '#' HK

	if HK
	{
		tray.Rename('Show Check List`t' HKToString(p2Gui.oldHK),'Show Check List`t' HKToString(HK))
		Hotkey(p2Gui.oldHK := HK,Showhide,'on')
	}
	else
	{
		tray.Rename('Show Check List`t' HKToString(p2Gui.oldHK),'Show Check List`t' HKToString('None'))
	}
	
	p2Gui.Hide()
	tGui.Show()
}

ApplySettings(*) ; update check list 
{
	; if pGui['add'].Enabled
	; 	AddTemplate()
	List := pGui['List'].value := Trim(RegExReplace(pGui['List'].value, '(^|\R)\K\s+'),'`n')
	tmp := pGui['Tmp'].Text
	if !tmp
	|| !List
	{
		tooltip 'Error:Cannot add empty list'
		settimer tooltip, -2000
		return
	}
	IniWrite(tmp,ini,"Selected","templet")
	tGui.Hide()
	list := SingleLine(pGui['List'].value)
	IniWrite(list,ini,"Templates",tmp)
	; Hotkey(p2Gui.oldHK,Showhide,'off')

	; WK := pGui['WK'].value
	; HK := pGui['HK'].value
	; IniWrite(WK,ini,'Hotkeys','WK')
	; IniWrite(HK,ini,'Hotkeys','HK')
	; if WK
	; 	HK := '#' HK

	try MainSel.Text := tmp
	catch
		MainSel.choose(0)



	; tray.Rename('Show Check List`t' HKToString(pGui.oldHK),'Show Check List`t' HKToString(HK))
	; Hotkey(p2Gui.oldHK := HK,Showhide,'on')
	BuildLV()	
	pGui.Hide()
	p2Gui.Hide()
	tGui.Title := 'Checklist: ' tmp
	tGui.Show()
}

; SingleLine2(str) => StrReplace(StrReplace(str,'`n','¶'),'`r')
SingleLine(str) 
{
	newstr := ''
	for i, line in removeDuplicates(StrSplit(str,'`n','`r'))
		newstr.= line '`n'

	str := Trim(newstr,'`n')
	return StrReplace(StrReplace(str,'`n','¶'),'`r')
}

MultiLine(str)  => StrReplace(str,'¶','`n')

; GetList2(str) => StrSplit(MultiLine(str), "`n", "`r")
GetList(str)
{
	str := StrSplit(MultiLine(str), "`n", "`r")
	return removeDuplicates(str)
}


removeDuplicates(inputList) {
	existingValues := map()
	outputList := []
	for each, value in inputList {
		if (existingValues.has(value))
			continue
		existingValues[value] := 0
		outputList.Push(value)
	}
	return outputList
}

Showhide(*) => tGui.Show()

HKToString(hk)
{
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
	return (fixedMods ?? '') StrUpper(hk)
}
