#Requires AutoHotkey v2.0

; ^numpad1::
; {
;     fileSize1 := 3 
;     fileSize2 := 9
;     Calculation(fileSize1,fileSize2)    
; }

Calculation(fileSize1,fileSize2,SelectedFile1,SelectedFile2)
{
    File1 := SplitPaths(SelectedFile1)
    File2 := SplitPaths(SelectedFile2)

    if (fileSize1 >= FileSize2)
    {
        percentFile1 := (fileSize1 / Filesize2) * 100  - 100
        percentFile2 := (fileSize2 / Filesize1) * 100

        P1 := ((fileSize1 / Filesize2) * 100 / 100) * percentFile2

        AboveMention1 := File1.Filename " is " Round(percentFile1,1) "% larger compared to " File2.Filename
        AboveMention2 := File2.Filename " is " Round(percentFile2,1) "% of " File1.Filename
    }
    else
    {
        percentFile2 := (fileSize2 / Filesize1) * 100  - 100
        percentFile1 := (fileSize1 / Filesize2) * 100
        P2 := ((fileSize2 / Filesize1) * 100 / 100) * percentFile1

        AboveMention1 := File1.Filename " is " Round(percentFile1,1) "% of " File2.Filename
        AboveMention2 := File2.Filename " is " Round(percentFile2,1) "% larger compared to " File1.Filename
    }

    IF IsSet(P1)
        return {File1:P1,File2:percentFile2,A1:AboveMention1,A2:AboveMention2}
    Else
        return {File1:percentFile1,File2:P2,A1:AboveMention1,A2:AboveMention2}
}

/*
    totalSize := fileSize1 + fileSize2
    percent1 := (fileSize1 / totalSize) * 100
    percent2 := (fileSize2 / totalSize) * 100

    if (fileSize1 >= FileSize2)
    {
        percentFile1 := 100
        percentFile2 := (fileSize2 / Filesize1) * 100
        percentFile1 := (fileSize1 / Filesize2) * 100 ; this is 2nd file percent tage
        result := "" File1.Filename " is " File2.Filename " of " Round(percentFile1,1) "%"

        AboveMention1 := File1.Filename " is " Round(percentFile1,1) "% Compared to " File2.Filename
        AboveMention2 := File2.Filename " is " Round(percentFile2,1) "% Compared to " File1.Filename
        OnlyPercent := Round(percentFile2,1) "%"
    }
    else
    {
        percentFile2 := 100
        percentFile1 := (fileSize1 / Filesize2) * 100
        percentFile2 := (fileSize2 / Filesize1) * 100  ; this is 1st file percent tage
        result := "" File2.Filename " is " File1.Filename " of " Round(percentFile1,1) "%"

        AboveMention1 := File1.Filename " is " Round(percentFile1,1) "% Compared to " File2.Filename
        AboveMention2 := File2.Filename " is " Round(percentFile2,1) "% Compared to " File1.Filename

        OnlyPercent := Round(percentFile1,1) "%"
    }
*/


/*
;Notify.show({HDText : "FileCompare",BDText:result,GenDuration:0})
File1 := SplitPaths(SelectedFile1)
File2 := SplitPaths(SelectedFile2)
global Prog := Gui("-MinimizeBox -MaximizeBox -Caption +Owner +AlwaysOnTop")
Prog.add("Button", "h40 w" percentFile1*2  ,File1.NNE)
;Prog.add("Text", "x+m yp+3" , Round(percentFile1,0) "%`n" File1.NNE)

Prog.add("Button", "h40 xm w" percentFile2*2   ,File1.NNE)
;Prog.add("Text", "x+m yp+3" , Round(percentFile2,0) "%`n" File2.NNE)

Prog.add("Text", "xm Center" ,result)
Prog.Show()
OnMessage(0x0201, WM_LBUTTONDOWN)
*/
