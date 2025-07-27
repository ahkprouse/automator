OnExit Aggregate

filepath := "contextswitch.txt"

if FileExist(filepath)
{
    if MsgBox("Do you want to delete the previous log?", "Close", "Y/N") = "Yes"
        FileDelete filepath
}
SetTimer CheckActiveWindow, 1000
return

CheckActiveWindow()
{
    static prevTitle := ''
    static SecondsElapsed := 0

    SecondsElapsed++
    currentTitle := WinGetTitle("A")
    If (currentTitle != prevTitle)
    {
        TimeString := FormatTime(A_Now, "yyyyMMddHHmmss")
        stringbuild := TimeString "`t"  SecondsElapsed "`t" prevTitle "`n"
        
        FileAppend stringbuild, filepath

        SecondsElapsed := 0
        prevTitle := currentTitle
    }
}

Aggregate(*)
{
    data := Map()
    Loop Read filepath
    {
        
        line := StrSplit(A_LoopReadLine, "`t")
        
        if !data.Has(line[3])
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

    MsgBox Sort(report, 'NR')
        ExitApp()
}