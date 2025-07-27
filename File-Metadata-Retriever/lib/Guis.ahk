#Requires AutoHotkey v2.0
pGui := Gui()
pGui.SetFont('s12')
pGui.AddText('y15','File Path:')
pathCtrl := pGui.AddEdit('x+m w500 yp-4 h30 +readonly','')
selBtn := pGui.AddButton('x+m yp-2','Select File')

; cb := pGui.AddCheckbox('xm +checked','Include FilexPro')

LV := pGui.AddListView('xm w700 r15',['Property Name','Property Value'])
pGui.Show()

pGui.OnEvent('DropFiles',Dropfiles)
selBtn.OnEvent('click',SelectaFile)
LV.OnEvent('DoubleClick',GenCode)


SelectaFile(*)
{
	sFile := FileSelect('s1',,'Select file')
	if !sFile
	&& !Fileexist(sFile)
		return
	BuildFilexProLV(sfile)
}

Dropfiles(GuiObj, GuiCtrlObj, Files, X, Y)
{
	sfile := files[1]
	if FileExist(sfile)
		BuildFilexProLV(sfile)
}

BuildFilexProLV(sfile)
{
	LV.Delete()
	pathCtrl.value := sFile
	for propname, PropVal in FileExProAll(sfile) 
		LV.Add(,propname,PropVal)
	LV.ModifyCol(1,300)
}

