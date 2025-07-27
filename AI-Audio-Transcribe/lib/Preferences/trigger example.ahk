#Requires AutoHotkey v2.0
#include Triggers.ahk
Persistent

triggers.AddHotkey(takescreenshot,"Take screenshot")
triggers.SetDDL(takescreenshot,['Mouse','Keyboard','Disable'])
triggers.DisableModiers(takescreenshot)
triggers.AddHotkey(action2,"Take action 2")

checkboxes := map(
	'allways on top',1,
	'Start up',1,
	'check update',1,
	'autoupdate',0
)

triggers.addCheckbox(action4,'Tool Config',checkboxes,2)

;triggers.AddHotkey(action2,"action 2")
triggers.FinishMenu()
triggers.tray.AddStandard
; if !FileExist(A_ScriptDir '\settings.ini')
	triggers.show()


takescreenshot(*)
{
	msgbox 'taking screen shot'
}

action2(*)
{
	msgbox A_ThisFunc
}
action4(*)
{
	msgbox A_ThisFunc
}