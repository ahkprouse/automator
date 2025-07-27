/**
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover       *
 * They're structured in a way to make learning AHK EASY                        *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!        *
 * ============================================================================ *
 * @Author   : Rizwan                                                          *
 * @Homepage : the-automator.com                                               *
 *                                                                             *
 * @Created  : Dec 04, 2024                                                    *
 * ============================================================================ *

This work by the-Automator.com is licensed under CC BY 4.0

Attribution — You must give appropriate credit , provide a link to the license,
and indicate if changes were made.
You may do so in any reasonable manner, but not in any way that suggests the licensor
endorses you or your use.
No additional restrictions — You may not apply legal terms or technological measures that
legally restrict others from doing anything the license permits.
*/
;@Ahk2Exe-SetVersion     0.0.1
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName Power Plan Swapper
;@Ahk2Exe-SetDescription Power Plan Swapper
;--
#SingleInstance
#Requires Autohotkey v2.0+
Persistent
#include <NotifyV2>
#include <ScriptObject>

OS := StrSplit(A_OSVersion,".")
IF (OS[1] < 10) 
{
    Notify.Show({HDText:"This tool require windows 10 or higher",
        HDFontSize  : 20,
        HDFontColor : "Black",
        HDFont      : "Impact",
        GenIcon:"Critical",
        GenDuration : 0})
    return
}

script := {
	        base : ScriptObj(),
	     version : "0.0.1",
	        hwnd : 0,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "",
	     moddate : "",
	   resfolder : A_ScriptDir "\res",
	    ; iconfile : 'res\ocr2.ico' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	         ini : A_ScriptDir "\settings.ini",
	homepagetext : "Power Plan Swapper",
	homepagelink : "the-Automator.com/PowerPlanSwapper?src=app",
	donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}
ini := script.ini
main := Gui(,'Power Plan Swapper')
SectionNames := IniRead(ini,,,"NotAssign")
AssignHK := ShowGui()
PowerPlansHotkeys := map()
Create_TrayMenu()
ActivePowerPlanCheck
;powerSchemes := GetPowerSchemes()
;PowerPlansArray := GetPowerPlans()
; maingui := 0
; Pvalue := GetProcessorsMinMax()
; maingui := 1


TraySetIcon("C:\WINDOWS\system32\wmploc.dll", 72)


Create_TrayMenu()
{
    SectionNames := IniRead(ini,,,"NotAssign")
	global tray := A_TrayMenu
	tray.Delete()
    tray.add('Open Folder',(*)=>Run(A_ScriptDir))
    tray.SetIcon("Open Folder","shell32.dll",4)
    tray.Add("About",(*) => Script.About())
	tray.Add("Preferences`t",(*) => main.Show())
        
    for k, PowerPlans in StrSplit(SectionNames,'`n')
    {
        hk := IniRead(ini,PowerPlans,'HK','NotAssign')
        if (hk = "NotAssign")
            continue

        PowerPlansHotkeys[PowerPlans] := hk
        Hotkey(hk,ChangeProfile,'on')

        tray.Add(PowerPlans '`t' HKToString(hk),ShowHK)
    }
    tray.Add("Exit`t",(*) => Exitapp())
}


ActivePowerPlanCheck()
{
    global powerSchemes := GetPowerSchemes()
    global PowerPlansArray := GetPowerPlans()
    for ProfileName, HK in PowerPlansArray
    {        
        hk := IniRead(ini,PowerPlansArray[A_Index],'HK','NotAssign')
        if (hk = 'NotAssign')
            continue

        tray.UnCheck(PowerPlansArray[A_Index] '`t' HKToString(hk))
    }

    hk := IniRead(ini,PowerPlansArray[1],'HK','NotAssign')
    if (hk = 'NotAssign')
        return

    tray.Check(PowerPlansArray[1] '`t' HKToString(hk))
}

ShowHK(ItemName, ItemPos, MyMenu)
{
    ItemName := StrSplit(ItemName,'`t')
    Create_TrayMenu
    ApplySettings(ItemName[1])
    Notify_Messege(ItemName[1])
}


main.SetFont('S14')
main.AddText('','Power Plan')
ddl := main.AddDropDownList('x+m Choose1',PowerPlansArray)
ddl.OnEvent('Change',UpdateHK)
main.AddButton('w100 h30 xm yp+40','Edit').OnEvent('click',EditPowerPlan)
main.AddText('vPPMin x+m+10 yp+3 w70')
main.AddText('vPPMax x+m+20 yp w90 ')

; triggers.AddHotkey(ChangePowerPlan,'HotKey to Change Power Plan','^f1')
main.AddGroupBox('w330 h80 xm y+30','HotKey to Change Power Plan')
WinKey := main.AddCheckbox('vWinKey xp+20 yp+35 section','Win')
ChosenHotkey := main.AddHotkey('vChosenHotkey x+m yp-3 w170')

main.AddButton('w100 h35 xm','Apply').OnEvent('click',MainApply)
main.AddButton('w100 h35 x+m','Cancel').OnEvent('Click',(*) => main.Hide())
if !AssignHK
    main.Show()
else
    main.hide()

UpdateHK
;main['PPMin'].Value := "Min " Pvalue.Power_min 
;main['PPMax'].Value := "Max " Pvalue.Power_max 

PGui := Gui()
PguiLength := 300
PGui.SetFont('S14')
PGui.AddText('vPowerPlan center h50 w' PguiLength).SetFont('S25 cBlue')
PGui.AddText('yp+43 w' PguiLength ,'Processor State').SetFont('S15')

PGui.AddText('','Minimum  %') ;.SetFont('cRed')
PGui.AddEdit('x+m w70') ;.SetFont('cgreen')
MinValue := PGui.AddUpDown('vMinValue xm Range0-100',100)
PGui.AddText('xm','Maximum %') ;.SetFont('cRed')
PGui.AddEdit('x+m w70') ;.SetFont('cgreen')
MaxValue := PGui.AddUpDown('vMaxValue xm Range0-100',100)
PGui.AddButton('w100 h35 xm yp+60','Apply').OnEvent('Click',ApplyValues)
PGui.AddButton('w100 h35 x+m','Cancel').OnEvent('Click',PGuiCancel)

;iniread hk with hk intead 
;if instr(#) strreplace 
;than update chosenHotkey
UpdateHK(*)
{
    Pvalue := GetProcessorsMinMax()
    main['PPMin'].Value := "Min " Pvalue.Power_min 
    main['PPMax'].Value := "Max " Pvalue.Power_max 

    ; main['PPMin'].Value := "Min " IniRead(ini,ddl.text,'Min',100)
    ; main['PPMax'].Value := "Max " IniRead(ini,ddl.text,'Max',100)
    
    Avalablehk := IniRead(ini,ddl.text,'HK','NotAssign')
    if Avalablehk = "NotAssign"
    {
        main['WinKey'].value := false
        main['ChosenHotkey'].value := ""
        return
    }

    if InStr(Avalablehk,"#")
    {
        main['WinKey'].value := true 
        Avalablehk := StrReplace(Avalablehk,"#")
    }
    else
    {
        main['WinKey'].value := false
    }
    main['ChosenHotkey'].value := Avalablehk    
}

ShowGui(*)
{
    AssignHK := 0
    for k, PowerPlans in StrSplit(SectionNames,'`n')
    {
        hk := IniRead(ini,PowerPlans,'HK','NotAssign')
        if (hk = "NotAssign")
            continue
        else return AssignHK := 1
    }
}

ApplyValues(*)
{        
    main.Opt("+AlwaysOnTop")
    IniWrite(Pgui['MinValue'].Value,ini,ddl.text,'Min')
    IniWrite(Pgui['MaxValue'].Value,ini,ddl.text,'Max')
    main['PPMin'].Value := "Min " IniRead(ini,ddl.text,'Min',100)
    main['PPMax'].Value := "Max " IniRead(ini,ddl.text,'Max',100)
    PGui.Hide()
    ;SetHktoChangePowerPlan
    ;Notify_Messege(ddl.text)
    main.Opt("-AlwaysOnTop")
    main.Opt('-Disabled')
    Create_TrayMenu
}

PGuiCancel(*)
{
    main.Opt('-Disabled')
    PGui.Hide()
}

EditPowerPlan(*)
{
    Pvalue := GetProcessorsMinMax()
    PGui.Title := ddl.text
    Pgui['MinValue'].Value := Pvalue.Power_min
    Pgui['MaxValue'].Value := Pvalue.Power_max
    Pgui['PowerPlan'].value := ddl.text
    main.Opt('+Disabled')

    X := 0, Y := 0, W := 0, H := 0
    WinGetPos(&XShow, &YShow, &MWidth, &MHeight, "ahk_id " Main.Hwnd)
    PGUI.Show('X' XShow+MWidth-10  'Y' YShow)
}

;ini read profile name ddl.text >> hk off >> Gui HK on dd.text >> iniwrite
ApplyNewHK(*)
{
    oldHK := IniRead(ini,ddl.text,'HK','NotAssign')
    if (oldHK != "NotAssign")
        Hotkey(oldHK,ChangeProfile,'off')

    Pvalue := GetProcessorsMinMax()
    main['PPMin'].Value := "Min " Pvalue.Power_min
    main['PPMax'].Value := "Max " Pvalue.Power_max
    
    if main['WinKey'].value
        NewHK := "#" main['ChosenHotkey'].value 
    else
        NewHK := main['ChosenHotkey'].value 
    Hotkey(NewHK,ChangeProfile,'on')
    IniWrite(NewHK,ini,ddl.text,'HK')

    ; IniWrite(Pvalue.Power_min,ini,ddl.text,'Min')
    ; IniWrite(Pvalue.Power_max,ini,ddl.text,'Max')
    Create_TrayMenu
}

ChangeProfile(*)
{
    for ProfileName, HK in PowerPlansHotkeys
    {
        hk := IniRead(ini,ProfileName,'HK','NotAssign')
        if (hk = "NotAssign")
            continue

        if (A_ThisHotkey = HK)
        {
            Notify_Messege(ProfileName)
            ApplySettings(ProfileName)
        }
    }
}

MainApply(*)
{
    if !main['ChosenHotkey'].value
    {
        Notify.Show({HDText:"Assign a Hotkey",BDText:"Please Assign a Hotkey",BDFont:"book antiqua",BDFontColor:"black",BDfontSize:13,HDFontSize  : 20,HDFontColor : "Black",HDFont:"Impact",GenDuration : 3,GenLoc: 'center'})
        return
    }
    else
    {
        main.hide()
        if main['WinKey'].value
            HKSetup := "#" main['ChosenHotkey'].value
        else
            HKSetup := main['ChosenHotkey'].value

        for Powername , HKSeted in PowerPlansHotkeys
        {
            if (ddl.text = Powername)
                continue

            if (HKSeted = HKSetup)
            {
                Notify.Show({HDText:"Hotkey Duplicated",BDText:"Choose a Different hotkey",BDFont:"book antiqua",BDFontColor:"black",BDfontSize:13,HDFontSize  : 20,HDFontColor : "RED",HDFont:"Impact",GenDuration : 3,GenLoc: 'center'})
                return
            }   
        }
    }

    RegExMatch(main['PPMin'].Value,"\d+",&minValue)
    RegExMatch(main['PPMax'].Value,"\d+",&maxValue)
    IniWrite(minValue[0],ini,ddl.text,'Min')
    IniWrite(maxValue[0],ini,ddl.text,'Max')

    ApplyNewHK
    Create_TrayMenu
    for Powername , HKSeted in PowerPlansHotkeys
    {
        hk := IniRead(ini,Powername,'HK','NotAssign')
        Powernames .=  HKToString(hk) '  ' Powername "`n"
    }

    Powernames := RTrim(Powernames, "`n")
    Notify.Show({HDText:Powernames ,HDFontSize  : 15,HDFontColor : "black",HDFont:"book antiqua",GenDuration : 4})
    ApplySettings(ddl.text)
}

SetHktoChangePowerPlan(*)
{
    if WinKey
        IniWrite('#' main['ChosenHotkey'].value,ini,ddl.text,'HK')
    else
        IniWrite(main['ChosenHotkey'].value,ini,ddl.text,'HK')

    IniWrite(MinValue.value,ini,ddl.text,'Min')
    IniWrite(MaxValue.value,ini,ddl.text,'Max')

    ApplySettings(ddl.text)
    ;UpdateHK()
    ;msgbox 'changing power plan  ' ddl.text
}

RunHide(Command) {
    ; Create a hidden command prompt and capture output
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows(true)
    
    Run(A_ComSpec " /c " Command,, "Hide", &pid)
    
    ; Wait for the process to complete
    WinWait("ahk_pid " pid)
    WinWaitClose("ahk_pid " pid)
    
    ; Get the output from a temporary file
    ;FileEncoding("UTF-8")
    output := FileRead("cmd.out",'UTF-8')
    

    while FileExist("cmd.out")
    {
        Sleep 100
        FileDelete("cmd.out")
    }

    ;try FileDelete("cmd.out")
    
    DetectHiddenWindows(dhw)
    return output
}

GetPowerSchemes() {
    schemes := Map()
    try {
        ; Redirect output to a temporary file
        output := RunHide("powercfg /list > cmd.out")

        ; Parse the output to get GUIDs and names
        Loop Parse, output, "`n", "`r"
        {
            ;msgbox A_Clipboard := A_LoopField
            if (RegExMatch(A_LoopField, "([a-fA-F0-9-]{36})\s*\((.*?)\).*", &match))
            {             
                    schemes[match[2]] := match[0]
            }
        }
    } catch Error as e {
        MsgBox("Error getting power schemes: " e.Message)
    }
    return schemes
}


ApplySettings(SelectedDDl)
{
    ; Get selected scheme GUID
    selectedScheme := SelectedDDl
    RegExMatch(powerSchemes[selectedScheme], '(?<id>\w+-\w+-\w+-\w+-\w+).*', &PowerGuid)
    schemeGUID := PowerGuid['id']
    
    ; Processor power management GUIDs
    processorSubgroupGUID := "54533251-82be-4824-96c1-47b60b740d00"
    minProcessorGUID := "893dee8e-2bef-41e0-89c6-b55d0929964c"
    maxProcessorGUID := "bc5038f7-23e0-4960-96da-33abaf5935ec"
    
    MinValue := IniRead(ini,SelectedDDl,'Min',100)
    MaxValue := IniRead(ini,SelectedDDl,'Max',100)

    minValue := MinValue 
    maxValue := MaxValue
    
    ; Apply settings
    success := true
    success := success && ModifyPowerSettings(schemeGUID, processorSubgroupGUID, minProcessorGUID, minValue)
    success := success && ModifyPowerSettings(schemeGUID, processorSubgroupGUID, maxProcessorGUID, maxValue)
    
    if (success) {
        ; Force the changes to take effect
        RunWait('powercfg /setactive scheme_current', , "Hide")
        RunWait('powercfg /setactive ' schemeGUID, , "Hide")
        ;MsgBox("Settings applied successfully to " selectedScheme " power plan!")
    }
    ActivePowerPlanCheck
}

ModifyPowerSettings(schemeGUID, subgroupGUID, settingGUID, value) {
    try {
        RunWait('powercfg /setacvalueindex ' schemeGUID ' ' subgroupGUID ' ' settingGUID ' ' value, , "Hide")
        RunWait('powercfg /setdcvalueindex ' schemeGUID ' ' subgroupGUID ' ' settingGUID ' ' value, , "Hide")
        return true
    } catch Error as e {
        MsgBox("Error modifying power settings: " e.Message)
        return false
    }
}


Notify_Messege(PowerPlans)
{
    Notify.Show({
        HDText      : PowerPlans ' :',
        HDFontSize  : 20,
        HDFontColor : "Black",
        HDFont      : "Impact",
        BDText      : 'Min ' IniRead(ini,PowerPlans,'Min',100) '%`nMax ' IniRead(ini,PowerPlans,'Max',100) '%',
        BDFontSize  : 18,
        BDFontColor : "0x046614",
        BDFont      : "Consolas",
        GenBGColor  : "0xFFD23E",
        GenDuration : 3 
    })
}

GetPowerPlans()
{
    pp := []
    for name, guid in powerSchemes
    {
        if RegExMatch(guid,"[)]\s[*]$")
            pp.Push(name)
    }
    
    for name, guid in powerSchemes
    {
        if !RegExMatch(guid,"[)]\s[*]$")
            pp.Push(name)
    }
    Return PP
}

HKToString(hk)
{
	; removed logging due to performance issues
	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'started', 'none')

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

	; Log.Add(DEBUG_ICON_INFO, A_Now, A_ThisFunc, 'ended', 'none')
	return (fixedMods ?? '') StrUpper(hk)
}


GetProcessorsMinMax(*)
{
    if IsSet(ddl)
        ActiveText := ddl.text
    else
        ActiveText := PowerPlansArray[1]

    for name, guid in powerSchemes
    {
        if InStr(name,ActiveText)
            RegExMatch(guid, '(?<id>\w+-\w+-\w+-\w+-\w+).*', &g)
    }
    
    ; if maingui
    ; {
    ;     ActiveText := ddl.text
    ;     for name, guid in powerSchemes
    ;     {
    ;         if InStr(name,ActiveText)
    ;             RegExMatch(guid, '(?<id>\w+-\w+-\w+-\w+-\w+).*', &g)
    ;     }
    ; }
    ; else
    ; {
    ;     ActiveText := PowerPlansArray[1]
    ;     for name, guid in powerSchemes
    ;     {
    ;         RegExMatch(guid, '(?<id>\w+-\w+-\w+-\w+-\w+).*', &g)
    ;         Break
    ;     }
    ; }

    matches := []
    ;activeScheme := RunHide("powercfg /getactivescheme > cmd.out")   
    activeScheme := 'Power Scheme GUID: ' g['id'] '  (' ActiveText ')'
    if (RegExMatch(activeScheme, 'Power Scheme GUID:\s*(?<id>\w+-\w+-\w+-\w+-\w+).*', &guidMatch))
    {
        processorSettings := RunHide("powercfg /query " guidMatch['id'] " SUB_PROCESSOR > cmd.out")
        foundMatch := 0
        while (foundMatch := RegExMatch(processorSettings, "Current AC Power Setting Index: (?<Value>[0-9xA-Za-z]+)", &match, foundMatch + 1)) {
            matches.Push(match[1])
        }
        minState := ConvertHexToDec(matches[1])
        maxState := ConvertHexToDec(matches[matches.Length])
    }
    return {Power_min:minState,Power_max:maxState}
}

ConvertHexToDec(hexInput)
{    
    ; Remove any "0x" or "0X" prefix if present
    hexInput := RegExReplace(hexInput, "^(0x|0X)")
    
    ; Validate hex input
    if !RegExMatch(hexInput, "^[0-9A-Fa-f]+$") {
        MsgBox("Invalid hexadecimal number. Please enter a valid hex value.", "Error", 16)
        return
    }
    
    ; Convert to decimal
    try {
        decimalValue := Integer("0x" . hexInput)
        return decimalValue
    } catch as err {
        MsgBox("Conversion error: " . err.Message, "Error", 16)
    }
}