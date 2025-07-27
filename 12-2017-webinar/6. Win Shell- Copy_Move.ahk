#Include <default_Settings> ;NoIndex ;RAlt::
global vObj:=[] ;Creates obj holder for variables
Browser_Forward::Reload ;RControl::
Browser_Back::
;**************************************
#NoEnv

FileToCopy := "C:\TEMP\Toy.story.that.time.forgot.mp4"
TargetPath := "H:\temp"
MsgBox, % SHFileOperation([FileToCopy], TargetPath, 2) ; 2 = copy  1=Move
;~ExitApp
; ==================================================================================================================================
; Copy or move files and folders using the SHFileOperation() function.
; SHFileOperation -> msdn.microsoft.com/en-us/library/bb762164(v=vs.85).aspx
; Parameters:
;     SourcesArray   -  Array of fully qualified source pathes.
;     TargetPath     -  Fully qualified path of the destination folder.
;     Operation      -  FO_MOVE = 1, FO_COPY = 2, other operations are not supported.
;     HWND           -  A handle to the window which will own the dialog.
;     Flags          -  Any combination of the FOF_ flags -> msdn.microsoft.com/en-us/library/bb759795(v=vs.85).aspx
;                       Default: FOF_NOCONFIRMMKDIR = 0x0200.
; Return values:
;     Returns 1 (True) if successful; otherwise 0 (False).
; ==================================================================================================================================
SHFileOperation(SourcesArray, TargetPath, Operation, HWND := 0, Flags := 0x0200) {
	Static TCS := A_IsUnicode ? 2 : 1 ; size of a TCHAR
	If Operation Not In 1,2
		Return False
	; Count files and total string length
	TotalLength := 0
	Files := []
	For Each, FilePath In SourcesArray {
		If (Length := StrLen(FilePath))
			Files.Push({Path: FilePath, Len: Length + 1})
		TotalLength += Length
	}
	FileCount := Files.Length()
	If !(FileCount && TotalLength)
		Return
	; Store the source pathes in Sources (the string must be double-null terminated)
	VarSetCapacity(Sources, (TotalLength + FileCount + 1) * TCS, 0)
	Offset := 0
	For Each, File In Files
		Offset += StrPut(File.Path, &Sources + Offset, File.Len) * TCS
	; Store the target path in Target (the string must be double-null terminated)
	TargetLen := StrLen(TargetPath) + 2
	VarSetCapacity(Target, TargetLen * TCS, 0)
	Target := TargetPath
	; Create and fill the SHFILEOPSTRUCT
	SHFOSLen := A_PtrSize * (A_PtrSize = 8 ? 7 : 8)
	VarSetCapacity(SHFOS, SHFOSLen, 0) ; SHFILEOPSTRUCT
	NumPut(HWND, SHFOS, 0, "UPtr") ; hwnd
	NumPut(Operation, SHFOS, A_PtrSize, "UInt") ; wFunc
	NumPut(&Sources, SHFOS, A_PtrSize * 2, "UPtr") ; pFrom
	NumPut(&Target, SHFOS, A_PtrSize * 3, "UPtr") ; pTo
	NumPut(Flags, SHFOS, A_PtrSize * 4, "UInt") ; fFlags
	If (A_IsUnicode)
		Return !DllCall("Shell32.dll\SHFileOperationW", "Ptr", &SHFOS, "Int")
	Else
		Return !DllCall("Shell32.dll\SHFileOperationA", "Ptr", &SHFOS, "Int")
}