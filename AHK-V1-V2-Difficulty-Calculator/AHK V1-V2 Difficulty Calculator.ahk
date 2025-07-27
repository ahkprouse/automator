;******************************************************************************
; Want a clear path for learning AutoHotkey?                                  *
; Take a look at our AutoHotkey Udemy courses.                                *
; They're structured in a way to make learning AHK EASY                       *
; Right now you can  get a coupon code here: https://the-Automator.com/Learn  *
;******************************************************************************
#SingleInstance
#Requires Autohotkey v1.1.36+ ; Prefer 64-Bit
;--
;@Ahk2Exe-SetVersion     0.2.1
;@Ahk2Exe-SetMainIcon    res\main.ico
;@Ahk2Exe-SetProductName AHK v1-v2 Difficulty Calculator
;@Ahk2Exe-SetDescription Gives a difficulty score to a v1 script based on how difficult it would be to convert to v2
/**
 * ============================================================================ *
 * @Author   : Irfan Arbab                                                      *
 * @Homepage :                                                                  *
 *                                                                              *
 * @Created  : May 02, 2023                                                     *
 * @Modified : May 04, 2023                                                     *
 * ============================================================================ *
 */

#Include <ScriptObject\ScriptObject>

global script := {base         : script
                 ,name          : regexreplace(A_ScriptName, "\.\w+")
                 ,version      : "0.2.1"
                 ,author       : "Irfan Arbab"
                 ,email        : ""
                 ,crtdate      : "May 02, 2023"
                 ,moddate      : "May 04, 2023"
                 ,homepagetext : ""
                 ,homepagelink : ""
                 ,donateLink   : "https://www.paypal.com/donate?hosted_button_id=MBT5HSD9G94N6"
                 ,resfolder    : A_ScriptDir "\res"
                 ,iconfile     : A_ScriptDir "\res\main.ico"
                 ,configfile   : A_ScriptDir "\settings.ini"
                 ,configfolder : A_ScriptDir ""}

Menu, Tray, Icon, % script.iconFile
Menu, Tray, NoStandard
Menu, Tray, Add, About, AboutGUI
Menu, Tray, Add
Menu, Tray, Standard

Gui +Resize
Gui Add, TreeView, w600 h400 r9 vTreeView gMyTreeView
Gui Add, ListView, x+m vListView, Difficulty Type|Count|Weighted
Gui Add, Button, w80 gSelectFile, Select File
Gui Add, Button, w80 gExitApp, Close
Gui, Add, StatusBar
SB_SetParts(300, 300, 100)
SB_SetText("Dropdown or load ahk file", 1)
Gui Show
;SysGet, VScroll, 20

if !FileExist(ini)
    DifficultyAnalyzer.CreateINI()
return

AboutGUI:
script.About()
return

GuiClose:
    ExitApp, 0

GuiDropFiles:
; GUI +Disabled
files := A_GuiEvent
SelectedFile := StrSplit(files, "`n")[1]


goto, filedroped
return

SelectFile:
; GUI +Disabled
FileSelectFile, SelectedFile, 3, ,Select AHK Script, Autohotkey Scripts (*.ahk)
if !FileExist(SelectedFile)
    return
if(PreviousFile = SelectedFile)
    return

filedroped:
SplitPath, SelectedFile,Name, workDir, ext
if !FileExist(SelectedFile) or (ext != "ahk")
    return

LV_Delete()
Gui +OwnDialogs
DC := new DifficultyAnalyzer(SelectedFile)
DC.AnalyzeAll()
DC.CalculateMain()

SB_SetText("Done. Click to analyze, Double Click to edit", 1)
SB_SetText("File: " Name, 2)
SB_SetText("Includes:" DC.Data.Count() - 2, 3)
Return

MyTreeView:
Gui +OwnDialogs
TV_GetText(selectedFile, A_EventInfo)
if( selectedFile = "Total")
    DC.SetLV("Main")
else if( selectedFile = "Unable to Locate")
    DC.LocateTV()
else if FileExist(selectedFile)
{
    SplitPath, SelectedFile, Name, workDir
    SB_SetText("File: '" Name "' is being analyzed....")
    DC.SetLV(selectedFile)
}
else
{
    child := TV_GetChild(A_EventInfo)
    TV_GetText(selectedFile, child)
    if FileExist(selectedFile)
    {
        SplitPath, SelectedFile,Name, workDir
        SB_SetText("File: '" Name "' is being analyzed....")
        DC.SetLV(selectedFile)
    }
}

if A_GuiEvent = DoubleClick
{
    if( selectedFile = "Total")
        return
    RegRead, editcom,  HKEY_CLASSES_ROOT, AutohotkeyScript\Shell\edit\command
    editcom := strreplace(editcom,"%1", Selectedfile)
    Run % trim(editcom)
}
SB_SetText("Done. Click to analyze, Double Click to edit", 1)
SB_SetText("File: " name, 2)
SB_SetText("Includes:" DC.Data.Count() - 2, 3)

Return

Class DifficultyAnalyzer
{
    static main := {}, i = 0, Data := {}, NewFiles := {}, UnabletoLocate := [], t := [".....",". ...",".. ..","... .",".... "," ...."]
    static Settingsini := A_ScriptDir "\Settings.ini"
    static gui_mult     := ""
    static Menu_mult    := ""
    static dll_mult     := ""
    static Removed_mult := ""
    static Re_mult      := ""
    static Lines_mult   := ""

    __new(File)
    {
        this.gui_mult     := DifficultyAnalyzer.IniRead("Gui"    )
        this.Menu_mult    := DifficultyAnalyzer.IniRead("Menu"   )
        this.dll_mult     := DifficultyAnalyzer.IniRead("Dll"    )
        this.Removed_mult := DifficultyAnalyzer.IniRead("Removed")
        this.Re_mult      := DifficultyAnalyzer.IniRead("Renamed")
        this.Lines_mult   := DifficultyAnalyzer.IniRead("Lines"  )
        
        this.UnabletoLocate := []
        TV_Delete()
        SplitPath, File ,name
        SB_SetText("Building Tree View.....")
        this.TV := TV_Add("Total",X,"Expand")

        This.Main.File := File
        This.NewFiles := {}
        This.NewFiles.push(file)
        this.BuilTreeview(File)
        SB_SetText("Done, Select form Tree view to analyze difficulty")
        for i, notfound in this.UnabletoLocate
        {
            F := StrSplit(notfound, "|")
            file := f[1]
            SplitPath, file ,name
            N := TV_Add("Unable to Locate",this.TV)
            TV_Add(Name " > from > " f[2] ,N)
        }
        this.UnabletoLocate := []
    }

    AnalyzeAll()
    {
        ItemID := 0  ; Causes the loop's first iteration to start the search at the top of the tree.
        Loop
        {
            ItemID := TV_GetNext(ItemID, "Full")  ; Replace "Full" with "Checked" to find all checkmarked items.
            if not ItemID  ; No more items in tree.
                break
            TV_GetText(ItemText, ItemID)
            if !instr(ItemText,"\")
                continue
            if !this.Data.haskey(ItemText)
                this.AnalyzeDifficulty(ItemText)
        }
    }

    CalculateMain()
    {
        gui := Menu := dll := Removed := Re := Lines := Total := 0
        for k, file in this.NewFiles
        {
            if(k = "Main")
                continue
            gui     := this.Data[File].gui     +   gui
            Menu    := this.Data[File].Menu    +   Menu
            dll     := this.Data[File].dll     +   dll
            Removed := this.Data[File].Removed +   Removed
            Re      := this.Data[File].Re      +   Re
            Lines   := this.Data[File].Lines   +   Lines
            Total   := this.Data[File].Total   +   Total
        }

        this.Data["Main"]         := {}
        this.Data["Main"].Total   := Total
        this.Data["Main"].gui     := gui     ;* 5
        this.Data["Main"].dll     := dll     ;* 4
        this.Data["Main"].Menu    := Menu    ;* 4
        this.Data["Main"].Re      := Re      ;* 2
        this.Data["Main"].Removed := Removed ;* 3
        this.Data["Main"].Lines   := Lines   ;* 1
        this.SetLV("Main")
    }

    IniRead(Key, Default := 0)
    {
        IniRead, OutputVar, % DifficultyAnalyzer.Settingsini,Difficulty, %Key%, %Default%
        return OutputVar
    }

    CreateINI()
    {
        IniWrite, 5, % DifficultyAnalyzer.Settingsini, Difficulty, Gui
        IniWrite, 4, % DifficultyAnalyzer.Settingsini, Difficulty, Menu
        IniWrite, 9, % DifficultyAnalyzer.Settingsini, Difficulty, Dll
        IniWrite, 2, % DifficultyAnalyzer.Settingsini, Difficulty, Removed
        IniWrite, 3, % DifficultyAnalyzer.Settingsini, Difficulty, Renamed
        IniWrite, 1, % DifficultyAnalyzer.Settingsini, Difficulty, Lines
    }
    
    SetLV(File)
    {   
        LV_Delete()
        if !this.Data.haskey(File)
            this.AnalyzeDifficulty(File)

        weighted_total := 0

        weighted_total += this.gui_mult     * this.Data[File].gui
        weighted_total += this.Menu_mult    * this.Data[File].Menu
        weighted_total += this.dll_mult     * this.Data[File].dll
        weighted_total += this.Removed_mult * this.Data[File].Removed
        weighted_total += this.Re_mult      * this.Data[File].Re
        weighted_total += this.Lines_mult   * this.Data[File].Lines

        LV_Add(,"GUIs :"              , this.Data[File].gui    , this.gui_mult     * this.Data[File].gui    )
        LV_Add(,"Menus :"             , this.Data[File].Menu   , this.Menu_mult    * this.Data[File].Menu   )
        LV_Add(,"DLLCalls :"          , this.Data[File].dll    , this.dll_mult     * this.Data[File].dll    )
        LV_Add(,"Removed Functions : ", this.Data[File].Removed, this.Removed_mult * this.Data[File].Removed)
        LV_Add(,"Renamed Functions : ", this.Data[File].Re     , this.Re_mult      * this.Data[File].Re     )
        LV_Add(,"Lines Count : "      , this.Data[File].Lines  , this.Lines_mult   * this.Data[File].Lines  )
        LV_Add(,"__________________"  , "_____"      , "________"  )
        LV_Add(,"Total :"             , this.Data[File].Total,  weighted_total)
        LV_ModifyCol()
    }

    BuilTreeview(AHKFile)
    {
        SplitPath, AHKFile,Name, workDir
        m := TV_Add(Name,this.TV)
        TV_Add(AHKFile,m)
        Includefiles := {}
        commentBlock := false
        FileRead, Text, % AHKFile
        Text := strreplace(Text,"`r","`n")
        if RegExMatch(Text,"i)#requires\s\w+\s+>?=?V?2")
        {
            Msgbox % "V2 Script Detected, Please select V1 Script"
            reload
        }

        SB_SetText("File: '" Name "' Building TreeView" this.Transitions(this.i := this.i  + 1) )
        for n, line in StrSplit(Text,"`n")
        {
            if this.IgnoreLine(line)
                continue

            if(regexMatch(line, "^\s*(\/\*|\((?!.*\)))"))
                commentBlock := true
            else if(regexMatch(line, "^(\s+)?(\*\/|\))"))
                commentBlock := false

            if(commentBlock || RegExMatch(line, "^(\s+)?;.*?$"))
                continue

            if (InStr(Line, "#include"))
            {
                line := StrReplace(Line, " *i ")
                line := RegExReplace(line, "i)%?A_ScriptDir%?\\")

                if regexMatch(Line, "iO)#include.*\<(?<path>.*?)\>$", incl)
                {
                    SplitPath, A_AhkPath,, InstallLoc
                    for each, libPath in [workDir, A_MyDocuments, InstallLoc]
                    {
                        ; OutputDebug, % incl.path
                        if FileExist(incLoc := libPath "\lib\" incl.path ".ahk")
                        {
                             Includefiles["LineNumber: " n] := incLoc
                             break
                        }
                    }
                }
                else if  regexMatch(Line, "iO)#include\s+(?<path>.*?)$", incl)
                {
                    Includefiles["LineNumber: " n] := workDir "\" incl.path
                }    
            }
        }

        if Includefiles
        {
            for n, ifile in Includefiles
            {
                if FileExist(ifile)
                {
                    if instr(ifile,".ahk")
                    {
                        this.BuilTreeview(ifile,this.TV)
                        this.Newfiles.push(ifile)
                    }
                }
                else
                {
                    this.UnabletoLocate.push(ifile "|" AHKFile " > " n)
                }
            }
        }
    }

    IgnoreLine(str)
    {
        ; if the line is empty
        if !str
            return true

        ; this is a hotstring
        if RegExMatch(str, "^::")
            return true

        return false
    }

    LocateTV()
    {
        Parent := A_EventInfo
        child := TV_GetChild(A_EventInfo)
        TV_GetText(childtext, child)
        RegExMatch(childtext, "(.*) > from > (.*) > (.*)", name)
        MsgBox, 4, , Would to Like to provide location for '%name1%' manually?`n(Press YES or NO)
        IfMsgBox No
            return
        FileSelectFile, SelectedFile, 3,,Looking for %name1%, % trim(name1) ; idk why extact file does not show
        if !FileExist(SelectedFile)
            return
        SplitPath, SelectedFile,NewName, workDir
        M := TV_GetParent(Parent)
        TV_Delete(child)
        TV_Delete(Parent)

        ;TV_Modify(Parent,, NewName)
        ;TV_Modify(child,, SelectedFile)

        this.BuilTreeview(SelectedFile)
        SB_SetText("Done, Select form Tree view to analyze difficulty")
        for i, notfound in this.UnabletoLocate
        {
            F := StrSplit(notfound, "|")
            file := f[1]
            SplitPath, file ,name
            N := TV_Add("Unable to Locate",M)
            TV_Add(Name " > from > " f[2] ,N)
        }
        this.UnabletoLocate := []
        this.AnalyzeAll() ;this.AnalyzeDifficulty(selectedFile)
        this.CalculateMain()
    }

    AnalyzeDifficulty(File)
    {
        if !fileexist(File)
            return
        SplitPath, File,Name, workDir
        Includefiles := []
        FileRead, Text, % File
        gui_R := dll_R := Menu_R := MenuBar_R := Re_R := Removed := Tab_R := Tab_R := LineN := 0
        commentBlock := false
        Text := strreplace(Text,"`r","`n")
        for n, line in StrSplit(Text,"`n")
        {
            if this.IgnoreLine(line)
                continue

            if(regexMatch(line, "^\s*(\/\*|\((?!.*\)))"))
                commentBlock := true
            else if(regexMatch(line, "^(\s+)?(\*\/|\))"))
                commentBlock := false

            if(commentBlock or RegExMatch(line, "^(\s+)?;.*?$"))
                continue

            gui_R   := gui_R   + this.FindbyCondition(line,"Gui")
            dll_R   := dll_R   + this.FindbyCondition(line,"DllCall")
            Menu_R  := Menu_R  + this.FindbyCondition(line,"menu")
            Re_R    := Re_R    + this.FindCommandsRenamed(line)
            Removed := Removed + this.Funcremoved(line)
            LineN++
            if (25 = Mod(n,25) + 1)
                SB_SetText("File: '" Name "' is being analyzed" this.Transitions(this.i := this.i  + 1) )
            Total_R := gui_R + dll_R + Menu_R + Removed + Tab_R + LineN + Re_R
            this.Data[File] := {}
            this.Data[File].Total  := total_R
            this.Data[File].gui    := gui_R
            this.Data[File].dll    := dll_R
            this.Data[File].Menu   := Menu_R
            this.Data[File].Re     := Re_R
            this.Data[File].Removed := Removed
            this.Data[File].Lines   := LineN
        }

        sleep 10
    }

    Transitions(n)
    {
        return this.t[Mod(n, 5) + 1]
    }

    FindbyCondition(text,condition)
    {
        text := strreplace(text,a_tab,a_space)
        if RegExMatch(Text, "i)\b\Q" condition "\E\b")
            return 1
        else
            return 0
    }

    FindCommandsRenamed(text)
    {
        CR := ["ComObjCreate"
        ,"ComObjParameter"
        ,"DriveSpaceFree"
        ,"EnvAdd"
        ,"EnvSub"
        ,"FileCopyDir"
        ,"FileCreateDir"
        ,"FileMoveDir"
        ,"FileRemoveDir"
        ,"FileSelectFile"
        ,"FileSelectFolder"
        ,"#If"
        ,"#IfTimeout"
        ,"StringLower"
        ,"StringUpper"
        ,"UrlDownloadToFile"
        ,"WinMenuSelectItem"
        ,"LV"]

        L := 0 ; linecount
        ;R := 0
        for k, v in CR
        {
            if RegExMatch(Text, "i).*(" v ").*")
                L++
        }
        return L
    }

    Funcremoved(Text)
    {
        CR := ["Asc"
        ,"AutoTrim"
        ,"ComObjMissing"
        ,"ComObjUnwrap"
        ,"ComObjEnwrap"
        ,"ComObjError"
        ,"ComObj.*"   ; "ComObjXXX"
        ,"ControlSendRaw"
        ,"EnvDi"
        ,"EnvMul"
        ,"EnvUpdate"
        ,"Exception"
        ,"FileReadLine"
        ,"Func"
        ,"Gosu"
        ,"Gui"
        ,"IfEqua"
        ,"IfExis"
        ,"IfGreate"
        ,"IfGreaterOrEqua"
        ,"IfInStrin"
        ,"IfLes"
        ,"IfLessOrEqua"
        ,"IfMsgBox"
        ,"IfNotEqua"
        ,"IfNotExis"
        ,"IfNotInStrin"
        ,"IfWinActiv"
        ,"IfWinExis"
        ,"IfWinNotActiv"
        ,"IfWinNotExis"
        ,"If"
        ,"Input"
        ,"IsFun"
        ,"Menu"
        ,"MenuGetHandle"
        ,"MenuGetName"
        ,"Progress"
        ,"SendRaw"
        ,"SetBatchLines"
        ,"SetEn"
        ,"SetFormat"
        ,"SoundGet"
        ,"SoundGetWaveVolume"
        ,"SplashImage"
        ,"SplashTextOn"
        ,"StringCaseSense"
        ,"StringGetPos"
        ,"StringLef"
        ,"StringLe"
        ,"StringMi"
        ,"StringRigh"
        ,"StringTrimLef"
        ,"StringTrimRight"
        ,"StringReplace"
        ,"StringSplit"
        ,"Transfor"
        ,"VarSetCapacity"
        ,"WinGetActiveStat"
        ,"WinGetActiveTitl"
        ,"#CommentFla"
        ,"#Delimite"
        ,"#DerefCha"
        ,"#EscapeCha"
        ,"#HotkeyInterval"
        ,"#HotkeyModifierTimeout"
        ,"#IfWinActive"
        ,"#InstallKeybdHook"
        ,"#InstallMouseHook"
        ,"#KeyHistory"
        ,"#LTri"
        ,"#MaxHotkeysPerInterval"
        ,"#MaxMem"
        ,"#MenuMaskKey"
        ,"#NoEnv"]
        L := 0 ; linecount
        R := 0
        for k, v in CR
        {
            if RegExMatch(Text, "i).*(" v ").*")
                L := L + R++
        }
        return L
    }
}

ExitApp:
Gui Destroy
DC := ""
ExitApp
Return


GuiSize:
GuiControl, Move, TreeView, % " w"  a_GuiWidth - a_GuiWidth / 3 -10 " h" a_GuiHeight -60
GuiControl, Move, ListView, % "x" a_GuiWidth - a_GuiWidth / 3 + 5 " w" a_GuiWidth / 3 - 15  " h" a_GuiHeight -60
GuiControl, Move, Select File, % "x" a_GuiWidth - 180 " y" a_GuiHeight - 50
GuiControl, Move, Close, % "x" a_GuiWidth - 90 " y" a_GuiHeight - 50
Return



