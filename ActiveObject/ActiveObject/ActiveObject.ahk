;******************************************************************************
; Want a clear path for learning objects and classes in AutoHotkey?           *
; Take a look at our AutoHotkey Classes & Objects course.                     *
; It is structured in a way to make learning Objects really  EASY             *
; Right now you can watch it here: https://the-Automator.com/Objects          *
;******************************************************************************
#Persistent
#Include <ObjRegisterActive>
OnExit("Revoke")
ObjRegisterActive(worker, "{4F301623-7051-4534-B7D1-9F51AD6A7308}")

return


class worker {
	isRunning := false

	start()
	{
		if worker.newVar
			Msgbox, % "New Var is set / Called from: " A_ScriptName
		
		worker.isRunning := true
		SetTimer, showToolTip, 10
	}

	stop()
	{
		worker.isRunning := false
		SetTimer, showToolTip, Off
		ToolTip
	}
}

showTooltip()
{
	MouseGetPos, x, y
	ToolTip, % x "," y
}

Revoke(ExitReason, ExitCode)
{
	worker.stop()
	ObjRegisterActive(worker, "")
	ExitApp, ExitCode
}