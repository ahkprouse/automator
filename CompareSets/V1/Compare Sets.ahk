#Requires Autohotkey v1.1.33+
;*******************************************************
; Want a clear path for learning AutoHotkey; Take a look at our AutoHotkey courses.  They're structured in a way to make learning AHK EASY
; Discover how easy AutoHotkey is here: https://the-Automator.com/Discover
; If you're wanting to learn more about GUIs, Our "GUIs are easy" course is a great place to start: https://the-Automator.com/GUIs
;*******************************************************
#SingleInstance, Force
#NoEnv
SetBatchLines -1
DetectHiddenWindows, On
;**********************gui*********************************
gui, +resize
gui, font, s11 bold, Verdana  ; Set 10-point Verdana.
Gui, add, Text,cRed  x20 y10  , A  ;Title for A
Gui, add, Text,cBlue x0  y460 , B  ;title for B
gui, font, ; reset to default
Gui, Add, Text,               cRed     x140  y15   R1 , Count: 
Gui, Add, Text, vA_Count_GUI  cRed     x180  y15   R1 , %A_Count% ;count A for update later
Gui, add, Edit, vA_Values cRed x0 y40  r30 w245,one`ntwo`nthree`nfour`nfive`nsix
Gui, Add, Text,               cblue   x140  y460 R1  , Count:
Gui, Add, Text, vB_Count_GUI  cblue   x180  y460 R1 , %B_Count%  ;add counts for B
Gui, add, Edit, vB_Values     cblue   x0 y480 r30 w245, six`nseven`neight`nnine`nten`neleven`ntwelve
gui, font, ;s9, Arial ; Set 10-point Verdana.

;**********************A_not_B listview*********************************
Gui, add, Text,                     cred x350  y10   R1 , Count:
Gui, Add, Text, vA_not_B_Count_GUI  cred x400  y10   R1 , %A_Not_B_count% ;count for A_not_B later
;~ guicontrol, hide, A_not_B_Count_GUI

Gui, Add, ListView, vA_not_B_LV  cred x250 y22  grid r23 , A Not B                     Control+shift+A  ;-Hdr
for k, v in data[2]
	LV_Add("", v)

;**********************B_not_A listview*********************************
Gui, Add, Text,                     cblue x350  y445   R1 , Count:
Gui, Add, Text, vB_not_A_Count_GUI  cblue x400  y445   R1 , %B_Not_A_count% ;count for A_not_B later

Gui, Add, ListView, vB_not_A_LV  cblue x250 y460 grid r23, B not A                     Control+shift+B  ; 
for k, v in data[3]
	LV_Add("", v)

;**********************A_and_B_Count******************* 
Gui, Add, Text,                     cpurple x600 y110 R1 ,  Count:
Gui, Add, Text, vA_and_B_count_GUI  cpurple x650 y110 R1 , %A_and_B_count% ;Control+shift+c


Gui, Add, ListView, vA_and_B_LV  cpurple x500 y125 grid r40 , A and B                  Control+shift+c ;-Hdr
for k, v in data[1]
	LV_Add("", v)
;*******************************************************
;**********************buttons*********************************
Gui, Add, Button, x550 y10 Default, Run
Gui, Submit, NoHide
Gui, Show,h900 w750, Compare
return

ButtonRun:
Gui, Submit ,NoHide
gosub Crunch_data
Gosub List_Data
return

ButtonCancel:
Gui, Destroy
Return

;**********************Extract groups*********************************
Crunch_Data:
A_not_B= , B_Not_A= , A_and_B= , A_Count= , B_Count= ;clear variables
D1 := Object(), D2 := Object() ;create empty objects
sort, A_Values, U ;remove duplicates
loop, parse, A_Values, `n, `r ;loop thru rows and covert to objects
	if A_Loopfield !=
		D1[A_index] := A_LoopField
		
A_Count:=d1.MaxIndex()

sort, B_Values, U ;remove duplicates
loop, parse, B_Values, `n, `r ;loop thru rows and covert to objects
	if A_Loopfield !=
		D2[A_index] := A_LoopField
B_Count:=d2.MaxIndex()
;*******************************************************
data := Compare_Sets(d1,d2) ;call function

;**********************breakout returned objects*********************************
for k, v in data[1]
	A_and_B.=v "`r"

for k, v in data[2]
	A_not_B.=v "`r"

for k, v in data[3]
	B_not_A.=v "`r"

;~ clipboard:= B_Not_A
return

;***********Put on clipboard******************* 
^+a::
clipboard = ; Empty the clipboard
Clipboard:=A_not_B
return

^+b::
clipboard = ; Empty the clipboard
clipboard:= B_Not_A
return

^+c::
clipboard = ; Empty the clipboard
clipboard:= A_and_B
return


;**********************list views*********************************
List_Data:
A_Count:=d1.MaxIndex()
A_Not_B_count:=data[2].MaxIndex()

GuiControl, Move, A_Count_GUI       , W100      ;need w incase new text is wider
GuiControl,, A_Count_GUI            , %A_Count% ;updates count

GuiControl, Move, A_not_B_Count_GUI , W100 ;need W in case new text is wider
GuiControl,,A_not_B_Count_GUI       , %A_Not_B_count% ;updates count

Gui,  ListView, A_not_B_LV  ;      Count:%B_Not_A_count% ;-Hdr    
LV_Delete()
for k, v in data[2]
	LV_Add("", v)


;***********B_Count********************************************
B_Count:=d2.MaxIndex() ;count for list
B_Not_A_count:=data[3].MaxIndex()


GuiControl,,B_Not_A_count, %B_Not_A_count% ;updates count
;~ Gui, Add, Text,     cblue x350 y464 R1  , Count: %B_Not_A_count%  ;this overlays on lv. 

GuiControl, Move, B_Count_GUI   , W100      ;need W in case new text is wider
GuiControl,,      B_Count_GUI   , %B_Count% ;updates count

;***********B_not_A********************************************
Gui,  ListView, B_not_A_LV  ;      Count:%B_Not_A_count% ;-Hdr    
LV_Delete()
for k, v in data[3]
	LV_Add("", v)

GuiControl, Move, B_not_A_Count_GUI , W100 ;need W in case new text is wider
GuiControl,     , B_not_A_Count_GUI , %B_Not_A_count% ;updates count


;**********A_and_B*********************************************
A_and_B_count:=data[1].MaxIndex()

GuiControl, Move, A_and_B_count_GUI , W100 ;need W in case new text is wider
GuiControl,     , A_and_B_count_GUI , %A_and_B_Count% ;updates count


Gui,  ListView,  A_and_B_LV  ;
LV_Delete()
for k, v in data[1]
	LV_Add("", v)

Gui, Show,, Compare ;display the gui
return

;*******************************************************
GuiEscape:
GuiClose:
ExitApp
return

;**********************functions*********************************
Compare_Sets(SetA,SetB){
Temp:=[], Temp2:=[], B_not_A:=[], A_and_B:=[] , A_not_B:=[]
;**********************B not A*********************************    
for i, val in SetA
	Temp[val] := true ;create key with true / false
    

for i, val in SetB ;iterate through set b
	if !Temp[val] ;if the key does not exist
        B_not_A.Insert(val) ;add to B_not_A

;**********************A and B*********************************	
for i, val in SetB ;iterate through set b
    if Temp[val] ;if the key does exist
        A_and_B.Insert(val) ;add to A_and_B
        
;**********************A_not_B*********************************
for i, val in SetB
	Temp2[val] := true ;create key with true / false

for i, val in SetA ;iterate through set a
	if !Temp2[val] ;if the key does not exist
        A_not_B.Insert(val) ;insert into A_not_B

Return [A_and_B, A_not_B, B_Not_A]  ;returns multiple objects
}

;**********************Double clicking in A_and_B*********************************
A_and_B_LV:
if A_GuiEvent = DoubleClick
 { RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
Loop
{ RowNumber := LV_GetNext(RowNumber)  ; Resume the search at the row after that found by the previous iteration.
    if not RowNumber  ; The above returned zero, so there are no more selected rows.
        break
        
    LV_GetText(Text, RowNumber,1) ;changed to copy third column 8/25/2013
      AllSelect.=Text . "`n"
    }

NewList.=AllSelect . "`n"
AllSelect=
}

Clipboard :=NewList
MsgBox,,Clipboard- Number of items: %Count%, % "The following is now on the clipboard`n`n" NewList, 4
NewList=
return

