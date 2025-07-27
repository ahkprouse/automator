#Requires AutoHotkey v2.0

SingleLine(str,x)
{
    newstr := ''
    for i, line in removeDuplicates(StrSplit(str,'`n','`r'))
        newstr.= line '`n'

    str := Trim(newstr,'`n')
    return StrReplace(StrReplace(str,'`n','¶'),'`r')
}

MultiLine(str)  => StrReplace(str,'¶','`n')

GetList(str)
{
    str := StrReplace(str,"`t")
    str := StrSplit(MultiLine(str), "`n", "`r")
    return removeDuplicates(str)
}

removeDuplicates(inputList) {
    existingValues := map()
    outputList := []
    for each, value in inputList {
        if (existingValues.has(value))
            continue
        existingValues[value] := 0
        outputList.Push(value)
    }
    return outputList
}

changePOwerPlan(*)
{
    savedText := GetList(IniRead(script.config, "TextStorage", "Content", ""))
    newText := ""
    for k, v in savedText
        newText  .= v "`n"
    newText := RTrim(newText, "`n")  ; Remove the last newline
    TextMenu(newText)
}

TextMenu(TextOptions)
{
    MyMenu := Menu()
    For MenuItems in StrSplit(TextOptions,"`n")
        MyMenu.Add(MenuItems, Action)

    MyMenu.Show()
}

Action(ItemName, *)
{
    ; Store original clipboard
    OldClipboard := A_Clipboard
    
    ; Process the text - replace paragraph marks with newlines
    processedText := StrReplace(ItemName, "¶", "`n")
    
    ; Copy to clipboard
    A_Clipboard := processedText
    
    ; Send paste command
    Send("^v")
    
    ; Wait for paste to complete
    Sleep(1000)
    
    ; Restore original clipboard
    A_Clipboard := OldClipboard
    return
}