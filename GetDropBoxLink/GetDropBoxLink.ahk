/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      the-Automtor                                                   *
 * @version     0.0.1                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2025-18-Feb                                                    *
 * @modified    2025-18-Feb                                                    *
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
   ;@Ahk2Exe-SetVersion     "0.0.1"
   ;@Ahk2Exe-SetMainIcon    res\main.ico
   ;@Ahk2Exe-SetProductName 
   ;@Ahk2Exe-SetDescription 
   #Requires Autohotkey v2.0+
   #SingleInstance
   #include <NotifyV2>
   #Include <Scriptobject>

   script := {
	base 	     : ScriptObj(),
	version      : "1.1.0",
	hwnd     	 : 0,
	author       : "the-Automator",
	email        : "joe@the-automator.com",
	crtdate      : "2025-18-feburary",
	moddate      : "2025-18-feburary",
	resfolder    : A_ScriptDir "\res",
	iconfile     : 'mmcndmgr.dll' , ;A_ScriptDir "\res\GetDropBoxLinkbg512.ico",
	config       : A_ScriptDir "\settings.ini",
	homepagetext : "GetDropBoxLink",
	homepagelink : "the-automator.com/GetDropBoxLink?src=app",
	donateLink   : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

tray := A_TrayMenu
tray.Delete()
tray.add('Open Folder',(*)=>Run(A_ScriptDir))
tray.SetIcon("Open Folder","shell32.dll",4)
tray.Add("About",(*) => Script.About())
; tray.Add("Donate",(*) => Run(script.donateLink))
tray.Add()
tray.AddStandard()
TraySetIcon(A_ScriptDir "\res\Dropbox.png")

^f1::GetDropBoxLink()
Browser_Back::
^f2::
{
	a_cLipboard  := ResolveDrive()
	Notify.show('Copied Path`nPath: ' a_cLipboard)
}

GetDropBoxLink()
{
    path := ResolveDrive()
    If InStr(FileExist(path),"D")
       link :=  ExecuteCopyVerb(path)
    else
    {
        SplitPath(path,&Name,&dir)
        link := ExecuteCopyVerb(dir,Name)
    }
	
	if !link 
		return Notify.show('could not performe the verb')

    Notify.Show("Dropbox Link copied!")
    return link
}

ExecuteCopyVerb(Folder,FileName:= "")
{
	static verbLookup := 'Copy Dropbox &link'
    shellapp := ComObject("Shell.Application")
    window := shellapp.NameSpace(Folder)
    if Filename
        for item in window.items
		{
			OutputDebug item.name '`n'
            if(item.name = FileName)
                for verb in item.Verbs
                    if verb.Name = verbLookup ; 'Copy Dropbox &link'
                        return link := DoVerb(verb)
		}

    for verb in window.self.Verbs
        if verb.Name = verbLookup ; 'Copy Dropbox &link'
            return  DoVerb(verb)
    DoVerb(verb)
    {
        A_Clipboard := ""
        verb.DoIt()
		if !clipwait(10)
			return ''
        return A_Clipboard
    }
}

ResolveDrive()
{
    static ExistingDrives := LoadDrives().existing
    for n, FilePath in Explorer_GetSelection(hwnd:='')
    {
        if !RegExMatch(ipath := FilePath, "^(\w:\\)", &DriveLetter)
        || !ExistingDrives.has(DriveLetter[1])
        || ExistingDrives[DriveLetter[1]] ~= "Temporal Virtual Drive|Local Drive"
            continue

        ;Notify.Show("It seems you are in '" DriveLetter[1] "' Drive which is a '" ExistingDrives[DriveLetter[1]] "'")
        ResolvedPath := RegExReplace(FilePath,"^" DriveLetter[1] "\",ExistingDrives[DriveLetter[1]] "\")
    }
	if !IsSet(ResolvedPath)
		return ipath
    return ResolvedPath
}

getDropboxpath()
{
    SplitPath A_AppData '\..\local\Dropbox\info.json',&name,&dir
    if !fileexist(dir  "\" name)
        return
    if !RegExMatch(FileRead(dir  "\" name),'\{"personal": \{"path": "(?<path>[\w:\\]+)",',&Dbox)
        return
    return Dbox.path
}


; incase someone need all resolved paths
GetallResolvedPaths(hwnd:='')
{
	ResolvedPaths := []
	ExistingDrives := LoadDrives().existing
	for n, FilePath in Explorer_GetSelection(hwnd)
	{
		if RegExMatch(FilePath,"^(\w:\\)",&DriveLetter)
		{
			if ExistingDrives.has(DriveLetter[1])
			{
				if ExistingDrives[DriveLetter[1]] = "Temporal Virtual Drive"
				|| ExistingDrives[DriveLetter[1]] = "Local Drive"
				{
					Notify.Show("It seems you are in '" DriveLetter[1] "' Drive which is a '" ExistingDrives[DriveLetter[1]] "'")
				}
				else
					ResolvedPaths.Push(RegExReplace(FilePath,"^" DriveLetter[1] "\",ExistingDrives[DriveLetter[1]] "\"))
			}
		}
	}
	return ResolvedPaths
}

Explorer_GetSelection(hwnd:='')
{
	ToReturn := []
	process := WinGetProcessName('ahk_id' hwnd := hwnd? hwnd:WinExist('A'))
	class := WinGetClass('ahk_id' hwnd)
	if (process != 'explorer.exe')
		return (ToolTip('Nothing was Selected'), SetTimer((*)=>Tooltip, 2500), ToReturn)

	if (class ~= 'i)Progman|WorkerW')
	{
		files:=ListViewGetContent('Selected Col1', 'SysListView321', 'ahk_class' class)
		Loop Parse, files, '`n', '`r'
			ToReturn.Push(A_Desktop '\' A_LoopField)
	}
	else if (class ~= '(Cabinet|Explore)WClass')
	{

		; for window in ComObject('Shell.Application').Windows
		; {
		; 	if (window.hwnd!=hwnd)
		; 		continue
		; 	sel := window.Document.SelectedItems
		; 	currentwindow := window
		; 	break
		; }

		; for item in sel
		; 	ToReturn.Push(item.path)

		folder := ExplorerTab(hwnd)
		folderpath := folder.Document.Folder.Self.Path
		for item in folder.Document.SelectedItems
				ToReturn.Push(item.path)

		if ToReturn.length = 0
		{
			; path := TextDecode(currentwindow.locationURL)
			path := TextDecode(folder.locationURL)
			path :=  strreplace(path,'file:///')
			path :=  strreplace(path,'/', '\')
			return [path]
		}
	}
	return ToReturn

	TextDecode(Url)
	{
		Pos := 1
		while Pos := RegExMatch(Url, "i)(%(?<val>[\da-f]{2}+))", &code, Pos++)
			Url := StrReplace(Url, code[0], Chr('0x' code.val))
		Return Url
	}
}

ExplorerTab(hwnd) {
	; Thanks Lexikos - https://www.autohotkey.com/boards/viewtopic.php?f=83&t=109907
	try activeTab := ControlGetHwnd("ShellTabWindowClass1", hwnd) ; File Explorer (Windows 11)
	catch
	try activeTab := ControlGetHwnd("TabWindowClass1", hwnd) ; IE
	for window in ComObject("Shell.Application").Windows {
		if (window.hwnd != hwnd)
			continue
		if IsSet(activeTab) { ; The window has tabs, so make sure this is the right one.
			static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
			IShellBrowser := ComObjQuery(window, IID_IShellBrowser, IID_IShellBrowser)
			ComCall(GetWindow := 3, IShellBrowser, "uint*", &thisTab := 0)
			if (thisTab != activeTab)
			continue
		}
		return window ; Returns a ComObject with a .hwnd property
	}
	throw Error("Could not locate active tab in Explorer window.")
}

LoadDrives()
{
	available_drives := []
	existing_drives := Map()

	static REGKey := 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices'
	loop 26
	{
		drive := Chr(A_Index + 64) ':\'
		if attr := FileExist(drive)
		{
			try
			{
				drive_path := RegRead(REGKey, Trim(drive, '\'), unset)
				drive_path := StrReplace(drive_path, '\??\')
				drive_path := StrReplace(drive_path, '\\', '\')
			}
			existing_drives.Set(drive, attr ~= 'S' ? 'Local Drive' : drive_path ?? 'Temporal Virtual Drive')
		}
		else if !FileExist(drive)
			available_drives.Push(drive)
	}

	return {available: available_drives, existing: existing_drives}
}