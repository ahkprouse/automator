#Requires AutoHotkey v2.0
#SingleInstance
#include <UIA>
#include <ScriptObject>

/**
 * ============================================================================ *
 * @Author   : Xeo786                                                          *
 * @Homepage : the-automator.com                                                                 *
 *                                                                              *
 * @Created  : March 14, 2024                                                   *
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
;@Ahk2Exe-SetVersion     0.0.0
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName
;@Ahk2Exe-SetDescription
;--
#SingleInstance
#Requires Autohotkey v2.0+

script := {
	        base : ScriptObj(),
	     version : '0.1.0',
	      author : "Joe Gline",
	       email : "joe@the-automator.com",
	     crtdate : 'May 17, 2024',
	     moddate : 'May 17, 2024',
	   resfolder : A_ScriptDir "\res",
	    iconfile : 'ieframe.dll' , 
	      config : A_ScriptDir '\Path.ini',
	homepagetext : "the-automator.com/ActiveSciteTab",
	homepagelink : "the-automator.com/ActiveSciteTab?src=app",
	 donateLink : ""
}

; hIcon := LoadPicture("C:\Windows\system32\ieframe.dll", "Icon50", &imgType)
TraySetIcon(Script.iconfile, 50)
tray := A_TrayMenu
tray.Delete()
tray.Add('About', (*)=> script.About())
tray.Add()
tray.AddStandard()


windowname := "ahk_exe SciTE.exe"
calltrycatch()

calltrycatch()
{
	WinWaitActive(windowname)
	try highlighttab()	
	catch
	{
		; msgbox 'exittings'
		if WinExist(windowname)
			calltrycatch()
		else
		{
			WinWait(windowname)
			calltrycatch()
		}
		
	}
}


highlighttab()
{
	SciTEEl := UIA.ElementFromHandle(windowname)

	tabbar := SciTEEl.ElementFromPath(3) ; .Highlight()
	i := 0
	loop 
	{
		for k, tab in tabbar.Children
		{
			if tab.GetPattern(UIA.Pattern.SelectionItem).IsSelected
			&& WinActive(windowname)
			{
				tab.Highlight()
			}	
		}
	}
	
}

