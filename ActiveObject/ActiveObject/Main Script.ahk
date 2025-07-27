;******************************************************************************
; Want a clear path for learning objects and classes in AutoHotkey?           *
; Take a look at our AutoHotkey Classes & Objects course.                     *
; It is structured in a way to make learning Objects really  EASY             *
; Right now you can watch it here: https://the-Automator.com/Objects          *
;******************************************************************************

worker := ComObjActive("{4F301623-7051-4534-B7D1-9F51AD6A7308}")
return

F1::worker.Start()
F2::worker.Stop()
F3::MsgBox, % "The worker thread is " (!worker.isRunning ? "not" : "") " running"
F4::MsgBox, % worker.isRunning
F5::worker.newVar := "Test"
F6::worker.newVar := ""