/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automator                                                  *
 * @version     0.1.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     YYYY-DD-MM                                                     *
 * @modified    YYYY-DD-MM                                                     *
 * @description                                                                *
 * =========================================================================== *
 * @license     CC BY 4.0                                                      *
 * =========================================================================== *
   This work by the-Automator.com is licensed under CC BY 4.0

   Attribution — You must give appropriate credit , provide a link to the license,
   and indicate if changes were made.

   You may do so in any reasonable manner, but not in any way that suggests the licensor
   endorses you or your use.

   No additional restrictions — You may not apply legal terms or technological measures that
   legally restrict others from doing anything the license permits.
 */
   ;@Ahk2Exe-SetVersion     "0.1.0"
   ;@Ahk2Exe-SetMainIcon    res\main.ico
   ;@Ahk2Exe-SetProductName FlipTextForTeleprompter
   ;@Ahk2Exe-SetDescription 
   #Requires Autohotkey v2.0+
   #SingleInstance
   #Include <ScriptObject>

   script := {
	base         : ScriptObj(),
	version      : "0.1.0",
	hwnd         : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "",
	moddate      : "",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'compstui.dll' , ;A_ScriptDir "\res\UltimateSpybg512.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "FlipTextForTeleprompter",
	homepagelink : "www.the-automator.com/teleprompt",
	DevPath		 : "S:\Teleprompter\v2\FlipTextForTeleprompter.ahk",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}
TraySetIcon(script.iconfile, 25)
tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()
; #Include "S:\lib\v2\ResizableGUI\ResizableGUI.ahk"

if FileExist("prevText.txt")
	prevText := FileRead('prevText.txt', 'utf-8')

prompt := Gui()
script.hwnd := prompt.hwnd
prompt.SetFont('s12')
prompt.Addtext('','Enter the text you want to show:')
prompt.Addedit('w800 r20 y+10 vtext', prevText)
prompt.Addbutton('w75', 'Save').OnEvent('Click', PromptButtonSave)
prompt.Show()
return

PromptButtonSave(*)
{
	prompt.submit()

	hFile := FileOpen("prevText.txt", "w")
	hFile.Write(text := prompt['text'].value)
	hFile.Close()
	text := regexreplace(text, "\n", "<br / >`n")
	; IE:=FixIE(11)
	swidth := A_ScreenWidth - 200
	sheight := A_ScreenHeight - 200
	
	flipped := Gui('-DPIScale')
	global wb := flipped.AddActiveX('w' swidth ' h' sheight, 'about:<meta http-equiv="X-UA-Compatible" content="IE=edge">').value
	flipped.AddSlider('range100-180 tickinterval20 h' sheight ' x+10 yp vertical invert vsizeSlider', 50)
	       .OnEvent('Change', Zoom)

	while(wb.ReadyState!=4)
		Sleep 10
	HTML:=
	(
		'<Body Style="Background:Black;Color:White;font-size:4em">
		<div id="text">' text '</div>
		<Style>
			div{
				/*border: 5px solid red;*/
				-ms-transform:scale(-1,1);
				text-align: left;
				margin: 0 1% 0% 9%;
				width: 90%;
				font-size:100%;
			}
		</Style>'
	)
	Doc:=wb.Document
	Doc.Body.outerHTML:=HTML

	flipped.Show()
}

Escape::ExitApp()

zoom(slider, info) => Tooltip(wb.document.getElementbyID("text").style.fontSize := slider.value "%")