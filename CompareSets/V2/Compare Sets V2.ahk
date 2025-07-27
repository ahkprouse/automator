#Requires Autohotkey v2.0+
#SingleInstance Force
/*
	* ============================================================================ *
	* Want a clear path for learning AutoHotkey?                                   *
	* Take a look at our AutoHotkey courses here: the-Automator.com/Discover          *
	* They're structured in a way to make learning AHK EASY                        *
	* And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
	* ============================================================================ *
*/

#Include <NotifyV2>

TraySetIcon A_ScriptDir '\res\Venn-Diagram.ico'

myGui := Gui()
;myGui.BackColor := "White"
myGui.Opt("+Resize")
myGui.SetFont("cRed")
Edit1 := myGui.Add("Edit", "x2 y40 w265 h395", "one`ntwo`nthree`nfour`nfive`n  Six  `nseven")
myGui.SetFont("cBlue")
Edit2 := myGui.Add("Edit", "x2 y483 w265 h395", "Six`nSeven`neight`nnine`nten")

myGui.SetFont("c0xFF0000")
myGui.Add("Text", "x310 y20 w150 h23 +0x200", "A Not B   Control+shift+A")
LV_AnotB := myGui.Add("ListView", "x272 y40 w244 h395 +LV0x4000 +Grid -Hdr", ["A Not B"])

myGui.SetFont("cBlue")
myGui.Add("Text", "x310 y463 w150 h23 +0x200", "B Not A   Control+shift+B")
LV_BnotA := myGui.Add("ListView", "x269 y483 w244 h395 +LV0x4000 +Grid -Hdr", ["B Not A"])

myGui.SetFont("cPurple")
myGui.Add("Text", "x570 y90 w150 h23 +0x200", "A and B   Control+shift+C")
LV_AandB := myGui.Add("ListView", "x522 y112 w222 h716 +LV0x4000 +Grid -Hdr", ["A and B"])

;======================================A=========================================
myGui.SetFont("s12 Bold c0xFF0000")
myGui.Add("Text", "x8 y8 w14 h23 +0x200", "A")
myGui.SetFont("s9 c0xFF0000")
ACount := myGui.Add("Text", "vcounta x120 y8 w120 h23 +0x200", "Count :")
;======================================A=========================================

;======================================B=========================================
myGui.SetFont("s12 Bold c0x0000FF")
myGui.Add("Text", "x8 y448 w14 h23 +0x200", "B")
myGui.SetFont("s9 c0x0000FF")
BCount := myGui.Add("Text", "x120 y448 w120 h23 +0x200", "Count :")
;======================================B=========================================

myGui.SetFont("s9 cblack")
Wtrim := myGui.Add("CheckBox", "x630 y10 w120 h23", "Trim Whitespace")
CSensitive := myGui.Add("CheckBox", "x630 y40 w120 h23", "Case Sensitive")

;======================================C=========================================
myGui.SetFont("s9 c0xFF0000") 
Alv := myGui.Add("Text", "x344 y0 w120 h23 +0x200", "Count :")
myGui.SetFont("s9 c0x0000FF")
Blv := myGui.Add("Text", "x328 y440 w120 h23 +0x200", "Count :")
myGui.SetFont("s9 cPurple")
Clv := myGui.Add("Text", "x600 y70 w120 h23 +0x200", "Count :")
;======================================C=========================================

ogcButtonRUN := myGui.Add("Button", "x568 y8 w41 h25", "RUN")
;Edit1.OnEvent("Change", Crunch_Data)
;Edit2.OnEvent("Change", Crunch_Data)
ogcButtonRUN.OnEvent("Click", Crunch_Data)
myGui.OnEvent('Close', (*) => ExitApp())
myGui.Title := "Compare Sets"
myGui.Show("w750 h900")


List_Data(data,D1,D2)
{
	A_Count := d1.Count
	A_Not_B_count := data[2].Count
	LV_AnotB.Delete()
	
	for k, v in data[2]
	{
		LV_AnotB.Add("", k)
		Alv.Value := "Count : " format("{:02}", A_Index)
	}
	
	LV_BnotA.Delete()
	for k, v in data[3]
	{
		LV_BnotA.Add("", k)
		Blv.Value := "Count : " format("{:02}", A_Index)
	}
	
	LV_AandB.Delete()
	for k, v in data[1]
	{
		LV_AandB.Add("", k)
		Clv.Value := "Count : " format("{:02}", A_Index)
	}
}


Crunch_Data(*)
{
	D1 := map(), D2 := map() ;create empty objects
	d1.CaseSense := CSensitive.Value
	d2.CaseSense := CSensitive.Value
	current_values1 := sort(Edit1.Value,"U") ;remove duplicates
	current_values2 := sort(Edit2.Value,"U") ;remove duplicates
	
	for values in [current_values1, current_values2]
	{
		var_num := A_Index
		loop parse, values, '`n', '`r' ;loop thru rows and covert to objects
		{
			if !A_Loopfield
				continue
			
			if Wtrim.Value
				D%var_num%[A_index] := Trim(A_LoopField)
			else
				D%var_num%[A_index] := A_LoopField
		}
	}
	
	ACount.Value := "Count : " format("{:02}", d1.Count)    
	BCount.Value := "Count : " format("{:02}", d2.Count)
	data := Compare_Sets(D1,D2) ;call function
    ;**********************breakout returned objects*********************************
	for k, v in data[1]
		A_and_B.=k "`r"
	
	for k, v in data[2]
		A_not_B.=k "`n"
	
	for k, v in data[3]
		B_not_A.=k "`r"
	
    ;~ clipboard:= B_Not_A
	List_Data(data,D1,D2)
}


;**********************functions*********************************
;**********************functions*********************************
Compare_Sets(SetA,SetB){
	Temp := MAP(), Temp2 := Map(), B_not_A := Map(), A_and_B := Map() , A_not_B := MAP()
	Temp.CaseSense := CSensitive.value
	Temp2.CaseSense := CSensitive.value
	B_not_A.CaseSense := CSensitive.value
	A_and_B.CaseSense := CSensitive.value
	A_not_B.CaseSense := CSensitive.value
	
  ;**********************B not A*********************************    
	for i, val in SetA
		Temp[val] := true ;create key with true / false
	
	for i, val in SetB ;iterate through set b
		if !Temp.Has(val) ;if the key does not exist
			B_not_A.Set(val, true) ;add to B_not_A
	
  ;**********************A and B*********************************	
	for i, val in SetB ;iterate through set b
		if Temp.Has(val) ;if the key does exist
			A_and_B.Set(val, true) ;add to A_and_B
	
  ;**********************A_not_B*********************************
	for i, val in SetB
		Temp2[val] := true ;create key with true / false
	
	for i, val in SetA ;iterate through set a
		if !Temp2.has(val) ;if the key does not exist
			A_not_B.Set(val,true) ;insert into A_not_B
	
	Return [A_and_B, A_not_B, B_Not_A]  ;returns multiple objects
}


^+a::
{
	Copy := []
	A_Clipboard := "" ; Empty the clipboard
	newclip := ''
	Loop LV_AnotB.GetCount()
	{
		LV_AnotB_DATA := LV_AnotB.GetText(A_Index)
		newclip .= LV_AnotB_DATA '`n'
		Copy.Push(LV_AnotB_DATA '`n')
	}
	A_Clipboard := newclip
	Notify_Copy(Copy,"Red","A")    
}

^+b::
{
	Copy := []
	A_Clipboard := "" ; Empty the clipboard
	newclip := ''
	Loop LV_BnotA.GetCount()
	{
		LV_BnotA_DATA := LV_BnotA.GetText(A_Index)
		newclip .= LV_BnotA_DATA '`n'
		Copy.Push(LV_BnotA_DATA '`n')
	}
	A_Clipboard := newclip
	Notify_Copy(Copy,"Blue","B")
}

^+c::
{
	Copy := []
	A_Clipboard := "" ; Empty the clipboard
	newclip := ''
	Loop LV_AandB.GetCount()
	{
		LV_AandB_DATA := LV_AandB.GetText(A_Index)
		newclip .= LV_AandB_DATA '`n'
		Copy.Push(LV_AandB_DATA '`n')
	}
	A_Clipboard := newclip
	Notify_Copy(Copy,"Purple","C")
}

;rizwan
Notify_Copy(Copy,Color,abc)
{
	static Row_Limit := 10
	for k, v in Copy
	{
		if (k > Row_Limit )
		{
			if (Row_Limit => k)
				Acopy .= "......"
			Break
		}   
		else
			Acopy .= Trim(v)
	}

	if isset(Acopy)	
		Notify.Show({HDText:"You Copied " abc,HDFontColor : Color,BDText : Trim(Acopy,'`n'), BDFontColor:Color, GenBGcolor:"Yellow", BDFontSize:"15"})
	else
		Notify.Show({HDText:"User did not hit Run"})
}