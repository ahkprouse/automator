#Requires AutoHotkey v2.0
#include WinClipAPI.ahk
#include Cjson.ahk
#include ObjectFromWindow.ahk
#include UIA.ahk
#include NotifyV2.ahk
; #include VSCodeHotkeyBind.ahk
#include WinClip.ahk

/**
 * 
 * @param {true|false} Quotes 
 * @param {true|false} TW_url 
 * @returns {String} 
 */
GetActivatePath(Quotes:=False,TW_url:=false)
{
	; ****** msgs *******
	static Protectedmsg := 'Document is Protected.`nPlease enable editing!`n<a href="https://youtu.be/JiHKmS-NMeI">Watch this Video</a> for more information'
	static StatusMsg := 'Program cannot accept Commands right now.`nTry changing the status of the program'
	static DialogMsg := 'Program is in a Dialog box.`nPlease close the dialog box and try again'
	;*********************
	Name := ProcessGetName(pid := WinGetPID("A"))
	
	if RegExMatch(Name, 'grepWin.*.exe') ; 'grepWin-.*_portable.exe'
		Name := 'grepWin.exe'

	if hwnd := WinActive('ahk_class #32770') ; in some cases winactive returned 1 but not hwnd 
	&& Name != 'grepWin.exe'
	{
		Hwnd := WinExist("A")                ; so we used this to get correct hwnd
		Filepath := GetOpenSaveDialogPath(hwnd)
		AppPath := ProcessGetPath(name)
		A_Clipboard  := Filepath
		ClipWait
		; Notify.show({BDText:Filepath,GenIcon:IsSet(AppPath)?AppPath:""})
		return Filepath
	}
	else
	{
		switch Name, false {
			;********************Chrome***********************************
			case "chrome.exe",'firefox.exe','msedge.exe','opera.exe','brave.exe':
			A_Clipboard := ''
			Send '^c'
			ClipWait(2)
			Btext := A_Clipboard
			text := A_Clipboard
			sleep 400
			A_Clipboard := ''
			Send( '^l')
			sleep 400
			Send( '^c')
			if !ClipWait(2)
			{
				Notify.show("Failed to get URL")
				return
			}
			url := A_Clipboard
			Full_url := url
			A_Clipboard := url := regexreplace(url,"^(https?:\/\/(www\.)?.*)\?(.*)","$1") ; disable this line to get full url
			AppPath := ProcessGetPath(name)
			
			if !text
			&& !url {
				Notify.show("Failed to get URL")
				return 
			}
			else if !text
				&& url {
				return url ; Notify.show({BDText:url,GenIcon:IsSet(AppPath)?AppPath:"",HDText:'URL Copied'})
			}
			
			wc := WinClip()
			if TW_url
			{
				html:= '<span><a href=' url '>' text '</a></span>' ;Build href
				guiCtrlHtml := '<a href="' url '">' text '</a>' ;Build href
				wc.Clear()
				wc.SetHTML( html ) ;set clipboard to be Hyperlink	
				return  guiCtrlHtml ; Notify.show({link:guiCtrlHtml,GenIcon:IsSet(AppPath)?AppPath:"",HDText:'HyperLink Copied'})
			}
			else
			{
				html:= '<span><a href=' Full_url '>' text '</a></span>' ;Build href
				guiCtrlHtml := '<a href="' Full_url '">' text '</a>' ;Build href
				wc.Clear()
				wc.SetHTML( html ) ;set clipboard to be Hyperlink
				return guiCtrlHtml ; Notify.show({link:guiCtrlHtml,GenIcon:IsSet(AppPath)?AppPath:"",HDText:'HyperLink Copied'})
			}			
			;********************Excel***********************************
			case "Excel.exe":
			NativeObj := ObjectFromWindow(OBJID_NATIVEOM, WinActive('a'), "EXCEL71")
			Info := ComObjType(NativeObj,'name')
			Switch info,0
			{
				Case 'ProtectedViewWindow': 
					Notify.show({link:Protectedmsg})
					return 
				Case '': 
					Notify.show(StatusMsg)
					return 
				Case 'IAccessible':
					Notify.show(DialogMsg)
					return 
			} 
			
			AppPath := NativeObj.Application.Path '\' Name
			file := NativeObj.Application.activeWorkBook
			Filepath := file.path "\" file.name
			
			;********************Word***********************************
			case "WinWord.exe","Word.exe":
			NativeObj := ObjectFromWindow(OBJID_NATIVEOM, WinActive('a'), "_WwG1") ; "ahk_exe " Name ' ahk_pid ' Pid
			;NativeObj := ComObjActive('word.application')
			Info := ComObjType(NativeObj,'name')
			Switch info,0
			{
				Case 'ProtectedViewWindow': 
					Notify.show({link:Protectedmsg})
					return 
				Case '': 
					Notify.show(StatusMsg)
					return 
				Case 'IAccessible':
					Notify.show(DialogMsg)
					return 
			} 
			
			file := NativeObj.Application.activedocument
			AppPath := NativeObj.Application.Path '\' Name
			Filepath := file.path "\" file.name
			
			;*********************PowerPoint**********************************
			case "PowerPnt.exe":
			; NativeObj := ObjectFromWindow(OBJID_NATIVEOM, WinActive('a'))
			NativeObj := ComObjActive("PowerPoint.Application")
			Info := ComObjType(NativeObj,'name')
			Switch info,0
			{
				Case 'ProtectedViewWindow': 
					Notify.show({link:Protectedmsg})
					return 
				Case '': 
					Notify.show(StatusMsg)
					return 
				Case 'IAccessible':
					Notify.show(DialogMsg)
					return 
				;Case '_Application': Notify.show("power point")
			} 
			
			file := NativeObj.ActivePresentation
			AppPath := NativeObj.Path '\' Name
			Filepath := file.path "\" file.name
			
			;********************Publisher***********************************
			case "MsPub.exe":
			NativeObj := ComObjActive("Publisher.Application")
			file := NativeObj.ActiveDocument
			AppPath := NativeObj.Path '\' Name
			Filepath := file.path "\" file.name
			
			;********************VS Code************************************
			case "Code.exe":
			A_Clipboard := ''
			SetKeyDelay(10,10)
			Send('{ctrl up}{shift up}{c up}')
			ControlSend('{f13}',,'ahk_exe ' name) ; this is the default hotkey, if you change yours, it would not work
			if ClipWait(2)
			{
				Filepath := A_Clipboard
				AppPath := ProcessGetPath(name)
			}
			
			;********************WinSCP*************************************
			Case 'WinSCP.exe':
			A_Clipboard := ''
			SetKeyDelay(50)
			Send('{ctrl up}{shift up}{c up}')
			ControlSend('^!c','a','ahk_exe' name)
			;Send('^!c')
			sleep 100
			if ClipWait(2)
			{
				Filepath := A_Clipboard
				FilePath := RegExReplace(FilePath,'\/(.*)\/public_html','https://$1') ; fixing fpt address
				AppPath := ProcessGetPath(name)
			}
			;********************Total Commander****************************
			Case 'TOTALCMD64.EXE','TOTALCMD32.EXE','TOTALCMD.EXE':
			A_Clipboard := ''
			PostMessage 0x111, 39, 0,,'ahk_exe ' name ; Runs --> Mark>Copy Names With Path To Clipboard
			if ClipWait(2)
			{
				Filepath := A_Clipboard
				AppPath := ProcessGetPath(name)
			}
			;********************Scite**************************************
			case "SciTE.exe":
			; NativeObj := ObjectFromWindow(OBJID_NATIVEOM, "ahk_exe " Name, "SciTeTabCtrl1")
			NativeObj := ComObjActive("SciTE4AHK.Application")
			Filepath := file := ComObjActive("SciTE4AHK.Application").CurrentFile
			AppPath := NativeObj.SciTEDir '\' Name
			;********************FileSearchEX*******************************
			case "FileSearchEX.exe":
			List := StrSplit(ListViewGetContent("Selected", 'TTntListView.UnicodeClass1', 'ahk_exe' name),'`n')
			path := ''
			for index, itemline in List
			{
				item := StrSplit(itemline, "`t") 
				path .= item[2] . item[1] '`n'
			}
			if List.length > 0
				Filepath := Trim(path ,'`n')
			AppPath := ProcessGetPath(name)
			;********************GrepWin************************************
			case "grepWin.exe":
			ptext := ControlGetText('Edit1','ahk_pid' pid)
			ControlFocus('SysListView321','ahk_pid ' pid)
			List := StrSplit(ListViewGetContent("Selected", 'SysListView321', 'ahk_pid' pid),'`n')
			sleep 100
			path := ''
			for index, itemline in List
			{
				item := StrSplit(itemline, "`t") 
				path .= ptext StrReplace(item[4],'\.','') . item[1] '`n'
			}

			if List.length > 0
				Filepath := Trim(path ,'`n')
			AppPath := ProcessGetPath(pid)
			;********************Directory Opus*****************************
			case "dopus.exe":
			A_Clipboard := ''
			
			SetKeyDelay(10,10)
			ControlSend('^+c',,'ahk_exe ' name)
			if ClipWait(2)
			{
				Filepath := A_Clipboard
				AppPath := ProcessGetPath(name)
			}
			
			;********************AHK STudio/ AHK program***********************************
			Case "AutoHotkey32.exe", "AutoHotkey64.exe" ,"AutoHotkeyU32.exe","AutoHotkeyU64.exe":
			;&& wingetTitle(x.hwnd(1)) ~= "AHK Studio"
			try x:=ComObjActive("{DBD5A90A-A85C-11E4-B0C7-43449580656B}")
			if IsSet(x) 
			&& IsObject(x)
			&& WinActive('ahk_id' x.hwnd(1))
			{
				Filepath := Trim(strreplace(WinGetTitle(x.hwnd(1)),'AHK Studio - '),'*')
				AppPath :=  x.path() '\AHKStudio.ico'
			}
			else
			{
				for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" name "'")
				{
					if process.processid = PID
					{
						if RegExMatch(var := process.CommandLine, Name '(\")?.*\"(?<path>.*)\"',&out)
							Filepath := out['path']			
						AppPath := ProcessGetPath(name)
					}
				}
			}
			
			;********************Explorer***********************************
			case "explorer.exe":
			Filepath := Explorer_GetSelection(,'string')
			AppPath := ExplorerIconNumber := 5
			
			;********************VLC***********************************
			case 'vlc.exe':
			SetKeyDelay(10,10)
			ControlSend('^i','a','ahk_exe ' name)
			WinWaitActive "Current Media Information ahk_exe vlc.exe"
			vlcEl := UIA.ElementFromHandle("Current Media Information ahk_exe vlc.exe")
			Filepath := vlcEl.ElementFromPath("4").Value
			Send('{Esc}')
			AppPath := ProcessGetPath(name)
			Default:
			for i, Title in StrSplit(WinGetTitle('a'),'-')
			{
				if RegExMatch(Trim(Title),'\d:\\',&regPath)
				{
					Filepath := regPath[1]
					AppPath := ProcessGetPath(name)
					break
				}
			}
		}
	}

	;*******************************************************
	;********************End of Case Statements***********************************
	;*******************************************************
	
	Notify.Default.HDText := Name ": Address Copied"
	if IsSet(Filepath)
	{
		if RegExMatch(Filepath,"^\\")
		{
			Notify.show("UnSaved File! - Save it first")
			return 
		}
		
		if !instr(Filepath,":\") and !instr(Filepath,"https")
		{
			Notify.show("Failed to get Path")
			return
		}
		A_Clipboard  := Filepath
		ClipWait
		if Quotes
		{
			for i, str in StrSplit(Filepath, "`n","`r")
				Filepathstr .= '"' str '"`n'
			Filepathstr := Trim(Filepathstr,'`n')
			return Filepathstr
			;Notify.show({BDText: Filepathstr,GenIcon:IsSet(AppPath)?AppPath:""})
			;A_Clipboard  := Filepathstr
		}	
		else
		{
			return Filepath
		}
		; 	Notify.show({BDText:Filepath,GenIcon:IsSet(AppPath)?AppPath:""})
		; return
	}
	else
	{
		Notify.show("Failed to get Path")
		return 
	}
}

/**
 * 
 * @param {Integer} hwnd 
 * @param {String} ReturnType 
 * @returns {String | Array} 
 */
Explorer_GetSelection(hwnd:='',ReturnType:="string")
{
	ToReturn := []
	process := WinGetProcessName('ahk_id' hwnd := hwnd? hwnd:WinExist('A'))
	class := WinGetClass('ahk_id' hwnd)
	if (process != 'explorer.exe')
		return (ToolTip('Nothing was Selected'), SetTimer((*)=>Tooltip, 2500), (ReturnType='string'?'':ToReturn))
	if (class ~= 'i)Progman|WorkerW')
	{
		files:=ListViewGetContent('Selected Col1', 'SysListView321', 'ahk_class' class)
		Loop Parse, files, '`n', '`r'
			ToReturn.Push(A_Desktop '\' A_LoopField)
	}
	else if (class ~= '(Cabinet|Explore)WClass')
	{
		for window in ComObject('Shell.Application').Windows
		{
			if (window.hwnd!=hwnd)
				continue
			sel := window.Document.SelectedItems
			break
		}
		if IsSet(sel)
			for item in sel
				ToReturn.Push(item.path)
	}
	if(ReturnType = "string")
	{
		paths := ""
		for path in ToReturn
			paths .= path "`n"
		return trim(paths,"`n")
	}
	return ToReturn
}

/**
 * 
 * @param {Integer} hwnd 
 * @returns {String} 
 */
GetOpenSaveDialogPath(hwnd)
{
	Send( '^l')
	sleep 400
	if !folderPath := ControlGetText( 'Edit2', 'ahk_id' hwnd)
		folderPath := ControlGetText( 'Edit3', 'ahk_id' hwnd)
	Send( '{esc}')
	Path := ControlGetText( 'Edit1', 'ahk_id' hwnd)
	switch folderPath
	{
		Case 'Documents'  : Path := A_MyDocuments '\' Path
		Case 'Desktop'    : Path := A_Desktop '\' Path
		Case 'Gallery'    : Path := 'C:\Users\' A_UserName '\Pictures\Screenshots\' Path
		Case 'Music'      : Path := 'C:\Users\' A_UserName '\Music\' Path
		Case 'Videos'     : Path := 'C:\Users\' A_UserName '\Videos\' Path
		Case 'Downloads'  : Path := 'C:\Users\' A_UserName '\Downloads\' Path
		Case 'Pictures'   : Path := 'C:\Users\' A_UserName '\Pictures\' Path
		Case 'OneDrive'   : Path := 'C:\Users\' A_UserName '\OneDrive\' Path
		Case '3D Objects' : Path := 'C:\Users\' A_UserName '\3D Objects\' Path
		Default           : Path := folderPath '\' Path
	}
	;FolderPath:=SubStr(FolderPath,10)
	return StrReplace(Path,'\\','\')
}