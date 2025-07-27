:o:ftlc.::FindText_Left_Click(Ok,X_Adj:=0,Y_Adj:=0,MoveBack:=0) ;Left Click
:o:ftrc.::FindText_Right_Click(Ok,X_Adj:=0,Y_Adj:=0,MoveBack:=0) ;Right click
:o:ftdc.::FindText_Double_Click(Ok,X_Adj:=0,Y_Adj:=0,MoveBack:=0) ;Double click
:o:ftst.::FindText_Send_Text(Ok,"text sent",EnterKey:=1,X_Adj:=0,Y_Adj:=0,MoveBack:=0) ;Send text
:o:ftif.::if (ok:=FindText(0,0,150000,150000,0,0,"")) ;FindTExt if statement
:o:ftmm.::FindText_Move_Mouse(Ok,X_Adj:=0,Y_Adj:=0,MoveBack:=0) ;noIndex