/**
 * =========================================================================== *
 * Want a clear path for learning AutoHotkey?                                  *
 * Take a look at our AutoHotkey courses here: the-Automator.com/Discover      *
 * They're structured in a way to make learning AHK EASY                       *
 * And come with a 200% moneyback guarantee so you have NOTHING to risk!       *
 * =========================================================================== *
 * @author      Xeo786                                                 		   *
 * @version     0.2.0                                                          *
 * @copyright   Copyright (c) 2024 The Automator                               *
 * @link        https://www.the-automator.com/                                 *
 * @created     2024-10-05                                                     *
 * @modified    2024-12-15                                                     *
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
;@Ahk2Exe-SetVersion     "0.2.0"
;@Ahk2Exe-SetMainIcon    res\main.ico
#SingleInstance
#Requires AutoHotkey v2.0+ ; prefer 64-Bit
#include <Scintilla\SciAHK>  ;RunWait "S:\AHK Studio Backup Remover\src\StudioBackup Remover2.ahk" ;Remove Studio backups
#include <ScriptObject>
#Include <NotifyV2>

;query := '*.ahk'
locations := [
's:','g:' ; 'S:\path\to\folder'
]

daysBack := 7
last_modified := DateAdd(A_Now, -daysBack, 'Days')
; last_modified := DateAdd(A_Now, -365, 'Days')


;;;; Script Object ;;;;
script := {
	        base : ScriptObj(),
	     version : "0.1.0",
	        hwnd : 0,
	      author : "the-Automator",
	       email : "joe@the-automator.com",
	     crtdate : "2024-10-05",
	     moddate : "2024-12-15",
	   resfolder : A_ScriptDir "\res",
	    iconfile : '',
	      config : A_ScriptDir "\settings.ini",
	homepagetext : "Recently Modified Files",
	homepagelink : "the-automator.com/RecentlyModifiedFiles?src=app",
	VideoLink 	 : "https://www.youtube.com/watch?v=-rx05THO6mE",
	  	 DevPath : "S:\Recently Modified Files\Recently Modified Files.ahk",
	  donateLink : "", ; "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
}

;;;;; tray menu ;;;;
Tray := A_TrayMenu
Tray.Delete()
Tray.Add('Opens Folder`tAlt+Click',(*)=>a_now)
Tray.Add('Runs File`tDouble Click',(*)=>a_now)
Tray.Add()
Tray.add('Open Folder',(*)=>Run(A_ScriptDir))
Tray.SetIcon("Open Folder","shell32.dll",4)
Tray.Add("Intro Video",(*) => Run(script.VideoLink))
Tray.SetIcon("Intro Video","imageres.dll", 19)
tray.Add('About',(*) => Script.About())
Tray.Add()
Tray.AddStandard()


;;;;;;;; GUI ;;;;;;

LVWidth := 750
SciWidth := 740
LVRows := 20 ; same as scintilla height


main := gui()
script.hwnd := main.hwnd
sciGui := Gui('-border -caption')
sciGui.Opt('parent' main.hwnd )
sci := SCIahk(sciGui)

main.SetFont('s12')
;lv := main.AddListView('w1100 r20', ['File Name', 'Location', 'Size'])
lv := main.AddListView('w' LVWidth ' r' LVRows, ['Size', 'File Name', 'Location'])
lv.OnEvent('ContextMenu',LV_ContextMenu)

TotalIcon := []
IconPath := "res\*"
loop Files IconPath , "F"
	TotalIcon.Push(A_LoopFileFullPath)
ImageListID := IL_Create(TotalIcon.Length)  ; Create an ImageList to hold 10 small icons.

for k , PathIcon in TotalIcon
	iconIndex := IL_Add(ImageListID, PathIcon)

lv.SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.


;lv.OnEvent('DoubleClick', (*)=>Run(ListViewGetContent('Col2 Selected', lv)))
lv.OnEvent('DoubleClick', SelectAction)
lv.OnEvent('click',updatescintilla)

main.SetFont('s10')
main.AddText('', 'Extention')
ExtEdit := main.AddEdit('x+m-10 yp-2 w35',"ahk")
main.AddText('x+m+5  yp+3 right', 'Days :')
daysEdit := main.AddEdit('x+5 yp-2 w50 Number Center', daysBack)
daysUpDown := main.AddUpDown('', daysBack)
runBtn := main.AddButton('x+5 w50 h26', 'Run')
runBtn.OnEvent('Click', reloadFile)
main.SetFont('s12')
pg := main.AddProgress('x+m-10 yp+3 w' (LVWidth + SciWidth) - 360 ' r1') ; subtract checkbox width
main.AddCheckbox('x+m  +checked w' 105,'Wrap Lines').OnEvent('click',wrapSci)
sb := main.AddStatusBar()
sb.SetText(' Finding recently modified files...')
main.Show('hide')
ControlGetPos(&x,&y,&w,&h,lv,main)
sci.AddScintilla("vMyScintilla y9 w" SciWidth " h" h / A_ScreenDPI * 96 " DefaultOpt DefaultTheme")
sci.Ctrl.ReadOnly := true
sciGui.Show('x' x + w ' y0')
main.Show('AutoSize')
lv.Opt('-Redraw')

LV_ContextMenu(*)
{
    if !row  := LV.GetNext(0)
        return

    fileName := lv.GetText(row, 2)
    Location := lv.GetText(row, 3)
    filepath := Location "\" fileName
    editpath := 'edit "' filepath '"'
    ;;;;;;;; context menu ;;;;;;;;
    contextmenu :=menu()
    contextmenu.Add('Open Folder',(*)=>Run(Location))
    contextmenu.Add('Run',(*)=>Run(filepath))
    contextmenu.Add('Edit',(*)=>Run(editpath))
    ;;;;;;;; context menu ;;;;;;;;
    contextmenu.Show()

}

reloadFile(*)
{
	sb.text := "Searching..."
	pg.value := 0
	loadfiles()
}

loadfiles()

loadfiles(*)
{
    lv.Delete()
    lv.Opt('-Redraw')
    daysBack := daysUpDown.Value
    last_modified := DateAdd(A_Now, -daysBack, 'Days')
    query := "*" ExtEdit.text

    fCount := 0
    files := []
    for location in locations
    {
        if !FileExist(location)
            continue

        Sr := 0
        fold := 1
        loop files, location '\' query, 'FR' {
            if InStr(A_LoopFileFullPath, "\.git\") ; Skip .git folders and their contents
                continue
            if Instr(A_LoopFileFullPath, "AHK-Studio Backup") ; Skip AHK Studio backup files
                continue
            if InStr(A_LoopFileFullPath, "G:\_Shared_Clients\Danny_H\Backup") ; Skip Danny_H backups
                continue
            if InStr(A_LoopFileFullPath, "G:\Scripts_To_Work_On") ; Skip Danny_H backups
                continue

            modified_time := FileGetTime(A_LoopFileFullPath, 'M')
            if last_modified > modified_time
                continue
            fCount++

            sb.SetText(' ' fCount ' files found, listing files...')
            file_size := FileGetSize(A_LoopFileFullPath, 'KB')
            SplitPath A_LoopFileFullPath, &fName, &fDir
            if !(fold = fDir)
                Sr++
            if (Sr > TotalIcon.Length) and !(fold = fDir)
                Sr := 1
            fold := fDir
            files.Push('Icon' sr '`t' file_size ' KB`t' fName '`t' fDir)
        }
    }
    pg.Opt('Range1-' files.Length)

    for cFile in files {
        pg.Value += 1

        data := StrSplit(cFile, '`t')
        lv.Add(data*)
    }

    loop lv.GetCount('col')
        lv.ModifyCol(A_Index, 'AutoHdr')
    lv.ModifyCol()
    lv.ModifyCol(2, 240)
    lv.ModifyCol(3, '400 Sort')
    lv.Opt('+Redraw')
    sb.SetText(' ' lv.GetCount() ' files found')

}


; loadfiles(*)
; {
;     lv.Delete()
;     lv.Opt('-Redraw')
;     daysBack := daysUpDown.Value
;     last_modified := DateAdd(A_Now, -daysBack, 'Days')
;     query := "*" ExtEdit.text

;     fCount := 0
;     for location in locations
;     {
;         if !FileExist(location)
;             continue
;         loop files, location '\' query, 'FR' {
;             if InStr(A_LoopFileFullPath, "\.git\") ; Skip .git folders and their contents
;                 continue
;             if Instr(A_LoopFileFullPath, "AHK-Studio Backup") ; Skip AHK Studio backup files
;                 continue
;             if InStr(A_LoopFileFullPath, "G:\_Shared_Clients\Danny_H\Backup") ; Skip Danny_H backups
;                 continue
;             if InStr(A_LoopFileFullPath, "G:\Scripts_To_Work_On") ; Skip Danny_H backups
;                 continue

;             modified_time := FileGetTime(A_LoopFileFullPath, 'M')
;             if last_modified > modified_time
;                 continue
;             fCount++
;         }
;     }
;     pg.Opt('Range1-' fCount)
;     sb.SetText(' ' fCount ' files found, listing files...')

;     for location in locations
;     {
;         if !FileExist(location)
;             continue
;         Sr := 0
;         fold := 1
;         loop files, location '\' query, 'FR'
;         {
;             if InStr(A_LoopFileFullPath, "\.git\") ; Skip .git folders and their contents
;                 continue
;             if Instr(A_LoopFileFullPath, "AHK-Studio Backup") ; Skip AHK Studio backup files
;                 continue
;             if InStr(A_LoopFileFullPath, "G:\_Shared_Clients\Danny_H\Backup") ; Skip Danny_H backups
;                 continue
;             if InStr(A_LoopFileFullPath, "G:\Scripts_To_Work_On") ; Skip Danny_H backups
;                 continue

;             modified_time := FileGetTime(A_LoopFileFullPath, 'M')
;             if last_modified > modified_time
;                 continue

;             pg.Value += 1
;             file_size := FileGetSize(A_LoopFileFullPath, 'KB')
;             SplitPath A_LoopFileFullPath, &fName, &fDir
;             if !(fold = fDir)
;                 Sr++
;             if (Sr > TotalIcon.Length) and !(fold = fDir)
;                 Sr := 1
;             fold := fDir
;             lv.Add('Icon' Sr, file_size ' KB', fName, fDir)
;             fCount++
;         }
;     }

;     loop lv.GetCount('col')
;         lv.ModifyCol(A_Index, 'AutoHdr')
;     lv.ModifyCol()
;     lv.ModifyCol(2, 240)
;     lv.ModifyCol(3, '400 Sort')
;     lv.Opt('+Redraw')
;     sb.SetText(' ' lv.GetCount() ' files found')
; }

SelectAction(obj, row)
{
	fileName := lv.GetText(row, 2)
	filePath := lv.GetText(row, 3)

    if GetKeyState('Shift')
	    Run('"' filePath '"', filePath) ;
    else
	    Run('"' filePath  '\' fileName '"', filePath) ;
}


updatescintilla(*)
{
    if lv.GetCount() = 0
        return
    row := lv.GetNext(0)
    name := lv.GetText(row, 2)
    Path := lv.GetText(row, 3)
    sFile := Path '\' name
    if !FileExist(sFile)
        return

    try {
        ; Load the contents into Scintilla
        Sci.Open(sFile)
        Sci.Ctrl.ReadOnly := true
    } catch as err {
        ; Handle any errors (e.g., access denied)
        ;sb.SetText("Error reading file: " err.Message)

		;shows a default notification with simple text dissapearing in 5 seconds
		;Notify.Show({BDText: "this is a test that stays up for 5 seconds", GenDuration:5})
		; Creates a 3 Second Notification with Body and Header with color and Body font size
		Notify.Show({BDText:err.Message, HDText:'Error', GenBGcolor:'yellow', BDFontSize:'15'})
        return
    }

    if GetKeyState('Alt', 'P')
        Run(Path)
}

wrapSci(ctrl,*)
{
	sci.Wrap := ctrl.value
}