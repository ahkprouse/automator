#SingleInstance
#Requires Autohotkey v2.0-
;--
/**
 * ============================================================================ *
 * @Author   : Taran Van Hemert                                                 *
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey Udemy courses.                                 *
 * They're structured in a way to make learning AHK EASY                        *
 * Right now you can  get a coupon code here: https://the-Automator.com/Learn   *
 * ============================================================================ *
 */

ActivateGroup(exeFile := "notepad.exe")
{
	SplitPath(exeFile,,,,&Name)
	if !WinExist("ahk_exe " exeFile)
	{
		Run exeFile
		Winwait "ahk_exe " exeFile
		GroupAdd Name "Group", "ahk_class " WinGetClass("ahk_exe " exeFile)
		
	}
	else
	{
		GroupAdd Name "Group", "ahk_class " WinGetClass("ahk_exe " exeFile)
		GroupActivate Name "Group", "R"
	}
}