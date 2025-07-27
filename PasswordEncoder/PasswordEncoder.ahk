/**
 * ============================================================================ *
 * @Author   : Joe Gline                                                        *
 * @Homepage : the-automator.com                                                *
 *                                                                              *
 * @Created  : May 17, 2024                                                     *
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

Converted to V2 by Xeo786
*/
;@Ahk2Exe-SetVersion     0.1.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#SingleInstance
#Requires Autohotkey v2.0+
#include <NotifyV2>
#include <ScriptObject>
; hIcon := LoadPicture("C:\Windows\system32\mstsc.exe", "Icon4", &imgType)

Notify.Default.GenLoc := 'C'
Notify.Default.GenDuration := '3'

script := {
	        base : ScriptObj(),
	     version : '0.1.0',
	      author : "Joe Gline",
	       email : "joe@the-automator.com",
	     crtdate : 'May 07, 2024',
	     moddate : 'May 07, 2024',
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'mstsc.exe' , 
	      config : A_ScriptDir '\Path.ini',
	homepagetext : "the-automator.com/PassEncode",
	homepagelink : "the-automator.com/PassEncode?src=app",
	 donateLink : ""
}
TraySetIcon(script.iconfile,4)

tray := A_TrayMenu
tray.Delete()
tray.Add('About', (*)=> script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()

ini := script.config 
width := 300
eGui := Gui(,'Password Encoder Utility')
eGui.SetFont('s12')
eGui.AddText('','Seed Number:')
eGui.AddEdit('x+m vseed w' width - 120)
eGui.AddUpDown('range1-999',Random(1,999))
eGui.AddText('xm','Word to change')
eGui.AddEdit('xm +multi h100 vIn w' width,'')
eGui.AddButton('x+-30 y+m w30 vxpend','>>').onEvent('Click', ExpendGui)
eGui.AddText('xm yp+4','Converted')
eGui.AddEdit('xm +multi h100 vout w' width,'')

xloc := 75 * 2 + eGui.MarginX
eGui.AddButton('x+-' xloc ' y+m w75 ','Encode').onEvent('click',Encodestr)
eGui.AddButton('x+m w75','Decode').onEvent('click',DecodeStr)
textwidth := 77
eGui.AddGroupBox('ym w310 h220','Location')
eGui.AddText('xp+20 yp+30 section right w' textwidth,'File Path:')
eGui.AddEdit('x+m-10 yp-3 +readonly vFolder w' width -110,'')
eGui['Folder'].value := IniRead(ini,'Location','Folder','')
eGui.AddButton('xs+160 vSelFolder','Select Folder').OnEvent('click', SelectFolder)
eGui.AddText('xs right w' textwidth,'File Name:')
eGui.AddEdit('x+m-10 yp-3 vFilename w' width -110,'')
eGui['Filename'].value := IniRead(ini,'Location','file','')
eGui.AddText('xs right w' textwidth,'Var Name:')
eGui.AddEdit('x+m-10 yp-3 vKey w' width -110,'')
eGui.AddButton('xs+220','Save').OnEvent('click', Createini)

eGui.AddGroupBox('xs-20 y+m w310 h110','Export Function')
eGui.AddText('xp+20 yp+30 right section','Select Hotkey:')
eGui.AddHotkey('x+m-10 yp-3 vhk w170',)
eGui.AddButton('x+-100 y+m w100','Copy Code').OnEvent('click', CopyCode)
eGui.Show('w330')
;eGui.Show()
OnMessage(0x0200, WM_MOUSEMOVE)

SelectFolder(*)
{
	dir := FileSelect('D', A_ScriptDir,'Select Save Folder')
	if Dir
	&& FileExist(Dir)
		eGui['Folder'].value := Dir
}

Createini(*)
{
	input := eGui['In'].value 
	if !input
	{
		eGui['In'].Focus()
		return Notify.show('Please enter a valid input')
	}
	
	seed := eGui['Seed'].value
	if !seed
	& !IsNumber(seed)
	{
		eGui['Seed'].Focus()
		return Notify.show('Please Provide Seed Number')
	}

	Encodestr()
	out := eGui['out'].value

	dir := eGui['Folder'].value 
	if !dir
	|| !FileExist(dir)
	{
		eGui['SelFolder'].Focus()
		return Notify.show('Please select a valid folder')
	}
	
	File := eGui['Filename'].value
	if !File
	{
		eGui['Filename'].Focus()
		return Notify.show('Please enter a valid file name')
	}

	Key := eGui['Key'].value
	if !Key
	{
		eGui['Key'].Focus()
		return Notify.show('Please enter a valid key name')
	}
	
	IniWrite(dir,ini,'Location','Folder')
	IniWrite(file,ini,'Location','file')
	Passini := dir '\' file


	IniWrite(out,Passini,'Main',Key)
	; else
	; {
	; 	result := IniRead(Passini,'Main',Key,0)
	; 	return (result = out ? 1:0)
	; }
}

CopyCode(*)
{
	static script := 
	(
		'#SingleInstance
		#include <DecodeSessionTimeout>
		#Requires Autohotkey v2.0+
		{1}:: ;{3}
		{
			send DecodeSessionTimeout(IniRead("{2}","Main","{3}",0),{4})
		}'
	)

	static Function := 
	(
		'
		DecodeSessionTimeout(OutputVar,seed:=100){
		Loop Parse, OutputVar, "a" 
		{
			if A_LoopField
				gen .= (Chr(A_LoopField+seed))
		}
		return gen
		}
		'
	)
	Createini()
	HK   := eGui['HK'].value
	if !HK
	{
		eGui['HK'].Focus()
		return Notify.show('Please assign a Hotkey to the function')
	}

	File  := eGui['Filename'].value
	dir   := eGui['Folder'].value 

	; parameter recpectively
	ini   := dir '\' file
	Key   := eGui['Key'].value
	seed  := eGui['Seed'].value

	; input := eGui['In'].value 
	; out   := eGui['out'].value
	Libpath := A_MyDocuments "\Autohotkey\Lib\DecodeSessionTimeout.ahk"
	if !FileExist(Libpath)
	{
		FileAppend(Function,Libpath)
	}
	A_Clipboard := Format(script,HK,ini,Key,seed)
	Notify.show({HDText:'The following is now on your clipboard',BDText:A_Clipboard,GenDuration:5})
}


ExpendGui(ctrl,*)
{
	static Colaspe := '<<', Expend := '>>'
	switch ctrl.text
	{
		case Colaspe:
			eGui.show('w330')
			ctrl.text := Expend
		case Expend:
			eGui.show('AutoSize')
			ctrl.text := Colaspe
	}
}

Encodestr(*)
{
	seed := eGui['Seed'].value
	Word := eGui['In'].value
	if !Word
	{
		eGui['out'].value := ''
		return Notify.show('Please enter a Word to convert')
	}
	Encoded := EncodeSessionTimeout(Word,seed)
	eGui['out'].value := Encoded
}

EncodeSessionTimeout(Var,seed:=100)
{
	Loop Parse, Var
	{
		Var := Ord(A_LoopField)
		Var-=seed, 
		NewVar.=Var . "a"
	}
	Return NewVar
}

DecodeStr(*)
{
	seed := eGui['Seed'].value
	Word := eGui['In'].value
	try Decoded := DecodeSessionTimeout(Word,seed)
	catch 
		return eGui['out'].value := 'failed'
	eGui['out'].value := Decoded

}

DecodeSessionTimeout(OutputVar,seed:=100){
	Loop Parse, OutputVar, 'a' 
	{
		if A_LoopField
			Decrypted.= (Chr(A_LoopField+seed))
	}
	return Decrypted
}

WM_MOUSEMOVE(wParam, lParam, msg, hwnd)
{
	; x := eGui['tAudio'].Hwnd
	; OutputDebug x " | " hwnd '`n'
	switch hwnd
	{
		Case eGui['seed'].Hwnd  :
			ToolTip("Choose a random number between 1-999 to seed the encryption")
		Case eGui['In'].Hwnd  :
			ToolTip("Enter the word you want to Encode")
		Case eGui['out'].Hwnd  :
			ToolTip("Encoded version displayed here")
		Case eGui['SelFolder'].hwnd :
			ToolTip("Select the folder you want to save the file`nWe suggest a folder not normally shared")
		Case eGui['Filename'].Hwnd  :
			ToolTip("Any filename will do. Doesn't have to be an .ini")
		Case eGui['Key'].Hwnd  :
			ToolTip("A unique variable name to store the encoded string")
		Case eGui['xpend'].Hwnd  :
			ToolTip("Expend to create files and Hotkey")		
		Case eGui['hk'].Hwnd  :
			ToolTip("Choose a hotkey which will send the decoded password")		
		Default:ToolTip()
	}
}