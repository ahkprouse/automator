#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#Persistent
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

OnExit, Aggregate

global currentTitle
global prevTitle
global stringbuild
global filepath

filepath := "contextswitch.txt"
prevtitle := ""
SecondsElapsed := 0


if FileExist(filepath)
{
    MsgBox, 0x24, Close, Do you want to delete the previous log?

    IfMsgBox, Yes
        FileDelete, %filepath%
}
SetTimer, CheckActiveWindow, 1000
return

CheckActiveWindow:
    SecondsElapsed ++
    WinGetTitle, currentTitle, A
    If (currentTitle != prevTitle) {
        currentTime := A_Now
        FormatTime, TimeString, , yyyyMMddHHmmss
        stringbuild := TimeString "`t"  SecondsElapsed "`t" prevTitle "`n"
        SecondsElapsed := 0
            ;tooltip, %stringbuild%
        FileAppend, %stringbuild%, %filepath%
        prevTitle := currentTitle
    }
Return

Aggregate:

data := {}
Loop, Read, %filepath%
{
    
    line := StrSplit(A_LoopReadLine, "`t")
    
    if !data.HasKey(line[3])
         data[line[3]] := 0
    
    data[line[3]] += line[2]
}

report := ""
for title,time in data
{
    if !title
        continue

    report .= time " sec`t" title "`n"
}

Sort, report, NR
MsgBox %report%
return