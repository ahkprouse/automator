;*******************************************************
; Want a clear path for learning AHK; Take a look at our AutoHotkey courses.
; They're structured in a way to make learning AHK EASY: https://the-Automator.com/Learn
;*******************************************************
#Requires Autohotkey v2.0+
#SingleInstance Force
A_TrayMenu.Add()
A_TrayMenu.Add("Ctl+Shift+m:Merge", mergexml)
A_TrayMenu.Add("Ctl+Esc:Exit", exitthis)

^Esc:: ;Control+Escape Exits the Application
{
     Exitapp
}

exitthis(*)
{
     exitapp
}

mergexml(*)
{
     send "^+m"
}

^+m:: ;Control+Shift+m to merge
{
     Selectedfiles := 0
     try Selectedfiles := Explorer_GetSelection()
     if InStr(Selectedfiles,"`n")
          XMLfiles := StrSplit(Selectedfiles,"`n")
     else
     {
          XMLfiles := FileSelect("M1",,"Select XML Files","*.xml")         
     }
     if XMLfiles.length < 1.1
          return
     oXML := ComObject("MSXML2.DOMDocument")
     oXML.async := False  
     doc := oXML.loadXML(FileRead(XMLfiles[1],"utf-8"))
     for i, file in XMLfiles
     {
          if i = 1
               continue
          SplitPath(file,,,&ext)
          if( ext = "xml")
               XMLMerge(&oXML,file)
     }
     Saveas := FileSelect("S16",A_ScriptDir,"Save as (XML merge loaction)","*.xml")
     if saveas = ""
          return
     SplitPath(saveas,,,&ext1)
     oXML.Save(Saveas (ext1 = "" ? ".xml" : "") )
}


XMLMerge(&oXML,XMLLocation) ; appand nodes to root of main oXML
{
     root := oXML.documentElement
     oXML1 := ComObject("MSXML2.DOMDocument")
     doc := oXML1.loadXML(FileRead(XMLLocation,"utf-8"))
     for child in oXML1.documentElement.childNodes
          root.appendChild(child)
}

Explorer_GetSelection(hwnd := '', selection := True) 
{
     ; https://www.autohotkey.com/boards/viewtopic.php?p=509165#p509165
     hwWindow := ''
     Switch window := explorerGetWindow(hwnd) {
      Case '': Return 'ERROR'
      Case 'desktop':
       Try hwWindow := ControlGetHwnd('SysListView321', 'ahk_class Progman')
       hwWindow := hwWindow || ControlGetHwnd('SysListView321', 'A')
       Loop Parse ListViewGetContent((selection ? 'Selected' : '') ' Col1', hwWindow), '`n', '`r'
        ret .= A_Desktop '\' A_LoopField '`n'
      Default:
       For item in selection ? window.document.SelectedItems : window.document.Folder.Items
        ret .= item.path '`n'
     }
     Return Trim(ret, '`n')
}
    
explorerGetWindow(hwnd := '') 
{
     class := WinGetClass(hwnd := hwnd || WinExist('A'))
     Switch {
      Case WinGetProcessName(hwnd) != 'explorer.exe': Return
      Case class ~= 'Progman|WorkerW': Return 'desktop'
      Case class ~= '(Cabinet|Explore)WClass':
       For window in ComObject('Shell.Application').Windows
        Try If window.hwnd = hwnd
         Return window
     }
}